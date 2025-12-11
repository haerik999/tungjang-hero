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

type AchievementHandler struct{}

func NewAchievementHandler() *AchievementHandler {
	return &AchievementHandler{}
}

// GetAchievements returns all achievements with user progress
func (h *AchievementHandler) GetAchievements(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	// Refresh achievement progress
	h.refreshAchievementProgress(userID)

	var achievements []models.Achievement
	database.DB.Order("category, tier, id").Find(&achievements)

	// Get user achievement progress
	var userAchievements []models.UserAchievement
	database.DB.Where("user_id = ?", userID).Find(&userAchievements)

	// Create map for quick lookup
	progressMap := make(map[uint]*models.UserAchievement)
	for i := range userAchievements {
		progressMap[userAchievements[i].AchievementID] = &userAchievements[i]
	}

	// Build response
	var response []models.AchievementResponse
	for _, achievement := range achievements {
		resp := models.AchievementResponse{
			Achievement: achievement,
			Progress:    0,
			IsUnlocked:  false,
			IsClaimed:   false,
			ProgressPct: 0,
		}

		if ua, exists := progressMap[achievement.ID]; exists {
			resp.Progress = ua.Progress
			resp.IsUnlocked = ua.UnlockedAt != nil
			resp.IsClaimed = ua.ClaimedAt != nil
			resp.ProgressPct = float64(ua.Progress) / float64(achievement.ConditionValue) * 100
			if resp.ProgressPct > 100 {
				resp.ProgressPct = 100
			}
		}

		// Hide hidden achievements that aren't unlocked
		if achievement.IsHidden && !resp.IsUnlocked {
			continue
		}

		response = append(response, resp)
	}

	c.JSON(http.StatusOK, response)
}

// refreshAchievementProgress updates achievement progress based on current data
func (h *AchievementHandler) refreshAchievementProgress(userID uint) {
	var achievements []models.Achievement
	database.DB.Find(&achievements)

	for _, achievement := range achievements {
		// Get or create user achievement
		var userAchievement models.UserAchievement
		if err := database.DB.Where("user_id = ? AND achievement_id = ?", userID, achievement.ID).First(&userAchievement).Error; err != nil {
			userAchievement = models.UserAchievement{
				UserID:        userID,
				AchievementID: achievement.ID,
				Progress:      0,
			}
			database.DB.Create(&userAchievement)
		}

		// Skip if already unlocked
		if userAchievement.UnlockedAt != nil {
			continue
		}

		// Calculate progress based on condition type
		var progress int64

		switch achievement.ConditionType {
		case "total_records":
			database.DB.Model(&models.Transaction{}).Where("user_id = ?", userID).Count(&progress)

		case "streak_days":
			var hero models.Hero
			if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err == nil {
				progress = int64(hero.RecordStreak)
			}

		case "hero_level":
			var hero models.Hero
			if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err == nil {
				progress = int64(hero.Level)
			}

		case "challenge_completed":
			database.DB.Model(&models.ChallengeParticipation{}).
				Where("user_id = ? AND is_completed = true", userID).
				Count(&progress)

		case "total_savings":
			database.DB.Model(&models.Transaction{}).
				Where("user_id = ? AND category = ?", userID, models.CategorySavings).
				Count(&progress)

		case "total_savings_amount":
			database.DB.Model(&models.Transaction{}).
				Where("user_id = ? AND category = ?", userID, models.CategorySavings).
				Select("COALESCE(SUM(amount), 0)").Scan(&progress)

		case "equipment_count":
			var hero models.Hero
			if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err == nil {
				database.DB.Model(&models.Equipment{}).Where("hero_id = ?", hero.ID).Count(&progress)
			}

		case "rare_equipment":
			var hero models.Hero
			if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err == nil {
				database.DB.Model(&models.Equipment{}).
					Where("hero_id = ? AND grade IN ?", hero.ID,
						[]models.EquipmentGrade{models.GradeRare, models.GradeEpic, models.GradeLegendary, models.GradeMythic}).
					Count(&progress)
			}

		case "legendary_equipment":
			var hero models.Hero
			if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err == nil {
				database.DB.Model(&models.Equipment{}).
					Where("hero_id = ? AND grade IN ?", hero.ID,
						[]models.EquipmentGrade{models.GradeLegendary, models.GradeMythic}).
					Count(&progress)
			}
		}

		// Update progress
		userAchievement.Progress = progress

		// Check if achievement unlocked
		if progress >= achievement.ConditionValue {
			now := time.Now()
			userAchievement.UnlockedAt = &now
		}

		database.DB.Save(&userAchievement)
	}
}

// ClaimAchievementReward claims reward for an unlocked achievement
func (h *AchievementHandler) ClaimAchievementReward(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	achievementID, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid achievement ID"})
		return
	}

	var userAchievement models.UserAchievement
	if err := database.DB.Where("user_id = ? AND achievement_id = ?", userID, achievementID).First(&userAchievement).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Achievement not found"})
		return
	}

	if userAchievement.UnlockedAt == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Achievement not unlocked"})
		return
	}

	if userAchievement.ClaimedAt != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Reward already claimed"})
		return
	}

	// Get achievement details
	var achievement models.Achievement
	if err := database.DB.First(&achievement, achievementID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Achievement not found"})
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
	if err := json.Unmarshal([]byte(achievement.RewardItems), &rewardItems); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse rewards"})
		return
	}

	// Create reward record
	reward := models.Reward{
		UserID:        userID,
		Type:          models.RewardTypeAchievement,
		AchievementID: &userAchievement.AchievementID,
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

	// Update achievement status
	now := time.Now()
	userAchievement.ClaimedAt = &now
	database.DB.Save(&userAchievement)

	c.JSON(http.StatusOK, gin.H{
		"message":     "Reward claimed successfully",
		"achievement": achievement.Name,
		"items":       rewardItems,
	})
}

// GetAchievementsByCategory returns achievements grouped by category
func (h *AchievementHandler) GetAchievementsByCategory(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	category := c.Param("category")

	h.refreshAchievementProgress(userID)

	var achievements []models.Achievement
	database.DB.Where("category = ?", category).Order("tier, id").Find(&achievements)

	var userAchievements []models.UserAchievement
	database.DB.Where("user_id = ?", userID).Find(&userAchievements)

	progressMap := make(map[uint]*models.UserAchievement)
	for i := range userAchievements {
		progressMap[userAchievements[i].AchievementID] = &userAchievements[i]
	}

	var response []models.AchievementResponse
	for _, achievement := range achievements {
		resp := models.AchievementResponse{
			Achievement: achievement,
			Progress:    0,
			IsUnlocked:  false,
			IsClaimed:   false,
			ProgressPct: 0,
		}

		if ua, exists := progressMap[achievement.ID]; exists {
			resp.Progress = ua.Progress
			resp.IsUnlocked = ua.UnlockedAt != nil
			resp.IsClaimed = ua.ClaimedAt != nil
			resp.ProgressPct = float64(ua.Progress) / float64(achievement.ConditionValue) * 100
			if resp.ProgressPct > 100 {
				resp.ProgressPct = 100
			}
		}

		if achievement.IsHidden && !resp.IsUnlocked {
			continue
		}

		response = append(response, resp)
	}

	c.JSON(http.StatusOK, response)
}
