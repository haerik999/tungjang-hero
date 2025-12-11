package handlers

import (
	"encoding/json"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/tungjang-hero/server/internal/database"
	"github.com/tungjang-hero/server/internal/domain/models"
	"github.com/tungjang-hero/server/internal/middleware"
)

type QuestHandler struct{}

func NewQuestHandler() *QuestHandler {
	return &QuestHandler{}
}

// GetActiveQuests returns current active quests for the user
func (h *QuestHandler) GetActiveQuests(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	// Refresh daily/weekly quests if needed
	h.refreshQuests(userID)

	var userQuests []models.UserQuest
	database.DB.Preload("Quest").
		Where("user_id = ? AND status IN ?", userID, []models.QuestStatus{models.QuestStatusActive, models.QuestStatusCompleted}).
		Find(&userQuests)

	var response []models.UserQuestResponse
	for _, uq := range userQuests {
		progressPct := float64(uq.Progress) / float64(uq.Quest.TargetValue) * 100
		if progressPct > 100 {
			progressPct = 100
		}
		response = append(response, models.UserQuestResponse{
			UserQuest:   uq,
			Quest:       *uq.Quest,
			ProgressPct: progressPct,
		})
	}

	c.JSON(http.StatusOK, response)
}

// refreshQuests creates/resets quests based on period
func (h *QuestHandler) refreshQuests(userID uint) {
	now := time.Now()
	today := now.Truncate(24 * time.Hour)
	weekStart := today.AddDate(0, 0, -int(today.Weekday()))
	monthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, time.Local)

	// Check and create daily quests
	var dailyCount int64
	database.DB.Model(&models.UserQuest{}).
		Joins("JOIN quests ON user_quests.quest_id = quests.id").
		Where("user_quests.user_id = ? AND quests.period = ? AND user_quests.start_date >= ?",
			userID, models.QuestPeriodDaily, today).
		Count(&dailyCount)

	if dailyCount == 0 {
		h.assignQuests(userID, models.QuestPeriodDaily, today, today.AddDate(0, 0, 1))
	}

	// Check and create weekly quests
	var weeklyCount int64
	database.DB.Model(&models.UserQuest{}).
		Joins("JOIN quests ON user_quests.quest_id = quests.id").
		Where("user_quests.user_id = ? AND quests.period = ? AND user_quests.start_date >= ?",
			userID, models.QuestPeriodWeekly, weekStart).
		Count(&weeklyCount)

	if weeklyCount == 0 {
		h.assignQuests(userID, models.QuestPeriodWeekly, weekStart, weekStart.AddDate(0, 0, 7))
	}

	// Check and create monthly quests
	var monthlyCount int64
	database.DB.Model(&models.UserQuest{}).
		Joins("JOIN quests ON user_quests.quest_id = quests.id").
		Where("user_quests.user_id = ? AND quests.period = ? AND user_quests.start_date >= ?",
			userID, models.QuestPeriodMonthly, monthStart).
		Count(&monthlyCount)

	if monthlyCount == 0 {
		h.assignQuests(userID, models.QuestPeriodMonthly, monthStart, monthStart.AddDate(0, 1, 0))
	}
}

// assignQuests assigns quests of a specific period to user
func (h *QuestHandler) assignQuests(userID uint, period models.QuestPeriod, startDate, endDate time.Time) {
	var quests []models.Quest
	database.DB.Where("period = ? AND is_active = true", period).Find(&quests)

	// Select 3 daily, 2 weekly, or 1 monthly quest randomly
	maxQuests := 3
	switch period {
	case models.QuestPeriodWeekly:
		maxQuests = 2
	case models.QuestPeriodMonthly:
		maxQuests = 1
	}

	count := 0
	for _, quest := range quests {
		if count >= maxQuests {
			break
		}

		userQuest := models.UserQuest{
			UserID:    userID,
			QuestID:   quest.ID,
			Status:    models.QuestStatusActive,
			Progress:  0,
			StartDate: startDate,
			EndDate:   endDate,
		}
		database.DB.Create(&userQuest)
		count++
	}
}

// ClaimQuestReward claims reward for a completed quest
func (h *QuestHandler) ClaimQuestReward(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	questID, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid quest ID"})
		return
	}

	var userQuest models.UserQuest
	if err := database.DB.Preload("Quest").
		Where("user_id = ? AND quest_id = ?", userID, questID).
		First(&userQuest).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Quest not found"})
		return
	}

	if userQuest.Status != models.QuestStatusCompleted {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Quest not completed"})
		return
	}

	// Get hero
	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Hero not found"})
		return
	}

	// Parse and give rewards
	var rewardItems []models.RewardItem
	if err := json.Unmarshal([]byte(userQuest.Quest.RewardItems), &rewardItems); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse rewards"})
		return
	}

	// Create reward record
	reward := models.Reward{
		UserID:  userID,
		Type:    models.RewardTypeQuest,
		QuestID: &userQuest.QuestID,
	}
	database.DB.Create(&reward)

	// Give items
	for _, item := range rewardItems {
		item.RewardID = reward.ID
		database.DB.Create(&item)

		// Add to inventory
		var existingItem models.Item
		if err := database.DB.Where("hero_id = ? AND item_type = ?", hero.ID, item.ItemType).First(&existingItem).Error; err == nil {
			existingItem.Quantity += item.Quantity
			database.DB.Save(&existingItem)
		} else {
			newItem := models.Item{
				HeroID:   hero.ID,
				ItemType: item.ItemType,
				Quantity: item.Quantity,
			}
			database.DB.Create(&newItem)
		}
	}

	// Update quest status
	now := time.Now()
	userQuest.Status = models.QuestStatusClaimed
	userQuest.ClaimedAt = &now
	database.DB.Save(&userQuest)

	c.JSON(http.StatusOK, gin.H{
		"message": "Reward claimed successfully",
		"items":   rewardItems,
	})
}

// GetAllQuests returns all available quests (for admin/reference)
func (h *QuestHandler) GetAllQuests(c *gin.Context) {
	var quests []models.Quest
	database.DB.Where("is_active = true").Order("period, id").Find(&quests)

	c.JSON(http.StatusOK, quests)
}

// GetQuestHistory returns completed quests history
func (h *QuestHandler) GetQuestHistory(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "20"))
	offset := (page - 1) * limit

	var userQuests []models.UserQuest
	var total int64

	database.DB.Model(&models.UserQuest{}).
		Where("user_id = ? AND status = ?", userID, models.QuestStatusClaimed).
		Count(&total)

	database.DB.Preload("Quest").
		Where("user_id = ? AND status = ?", userID, models.QuestStatusClaimed).
		Order("claimed_at DESC").
		Offset(offset).Limit(limit).
		Find(&userQuests)

	c.JSON(http.StatusOK, gin.H{
		"quests":      userQuests,
		"total":       total,
		"page":        page,
		"limit":       limit,
		"total_pages": (total + int64(limit) - 1) / int64(limit),
	})
}
