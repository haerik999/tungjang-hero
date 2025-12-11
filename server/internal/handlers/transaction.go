package handlers

import (
	"math/rand"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/tungjang-hero/server/internal/database"
	"github.com/tungjang-hero/server/internal/domain/models"
	"github.com/tungjang-hero/server/internal/middleware"
)

type TransactionHandler struct{}

func NewTransactionHandler() *TransactionHandler {
	return &TransactionHandler{}
}

// CreateTransaction creates a new transaction and gives rewards
func (h *TransactionHandler) CreateTransaction(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var req models.TransactionCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get hero for streak tracking
	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Hero not found. Please create a hero first."})
		return
	}

	// Create transaction
	transaction := models.Transaction{
		UserID:          userID,
		Type:            req.Type,
		Amount:          req.Amount,
		Category:        req.Category,
		Description:     req.Description,
		TransactionDate: req.TransactionDate,
		HasReceipt:      req.ReceiptImage != "",
	}

	if req.ReceiptImage != "" {
		// TODO: Process receipt image, OCR verification
		transaction.ReceiptVerified = true // Simplified for now
	}

	if err := database.DB.Create(&transaction).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create transaction"})
		return
	}

	// Process rewards
	reward, rewardItems := h.processRewards(userID, &hero, &transaction)

	// Update streak
	h.updateStreak(&hero, req.TransactionDate)

	// Update quest progress
	h.updateQuestProgress(userID, &transaction)

	database.DB.Save(&hero)

	c.JSON(http.StatusCreated, gin.H{
		"transaction": transaction,
		"reward":      reward,
		"items":       rewardItems,
		"streak":      hero.RecordStreak,
	})
}

// processRewards generates rewards for a transaction
func (h *TransactionHandler) processRewards(userID uint, hero *models.Hero, transaction *models.Transaction) (*models.Reward, []models.RewardItem) {
	// Check daily limits
	today := time.Now().Truncate(24 * time.Hour)
	var todayRecordCount int64
	database.DB.Model(&models.Transaction{}).
		Where("user_id = ? AND DATE(created_at) = DATE(?)", userID, today).
		Count(&todayRecordCount)

	limit := models.BasicDailyLimit
	if transaction.HasReceipt {
		limit = models.WithReceiptDailyLimit
	}

	if int(todayRecordCount) >= limit.MaxRecords {
		return nil, nil // Exceeded daily limit
	}

	// Create reward
	reward := models.Reward{
		UserID:        userID,
		Type:          models.RewardTypeTransaction,
		TransactionID: &transaction.ID,
	}
	database.DB.Create(&reward)

	var rewardItems []models.RewardItem

	// Basic reward (random pick)
	basicReward := h.rollReward(models.BasicTransactionRewards)
	if basicReward != nil {
		item := models.RewardItem{
			RewardID: reward.ID,
			ItemType: basicReward.ItemType,
			Quantity: basicReward.MinQuantity + rand.Intn(basicReward.MaxQuantity-basicReward.MinQuantity+1),
		}
		database.DB.Create(&item)
		rewardItems = append(rewardItems, item)

		// Add to inventory
		h.addToInventory(hero.ID, item.ItemType, item.Quantity)
	}

	// Receipt bonus reward
	if transaction.HasReceipt && transaction.ReceiptVerified {
		bonusReward := h.rollReward(models.ReceiptBonusRewards)
		if bonusReward != nil {
			item := models.RewardItem{
				RewardID: reward.ID,
				ItemType: bonusReward.ItemType,
				Quantity: bonusReward.MinQuantity + rand.Intn(bonusReward.MaxQuantity-bonusReward.MinQuantity+1),
			}
			database.DB.Create(&item)
			rewardItems = append(rewardItems, item)

			h.addToInventory(hero.ID, item.ItemType, item.Quantity)
		}
	}

	transaction.RewardClaimed = true
	database.DB.Save(transaction)

	return &reward, rewardItems
}

// rollReward randomly selects a reward based on probabilities
func (h *TransactionHandler) rollReward(rewards []models.TransactionRewardProbability) *models.TransactionRewardProbability {
	roll := rand.Float64()
	cumulative := 0.0

	for _, reward := range rewards {
		cumulative += reward.Probability
		if roll < cumulative {
			return &reward
		}
	}

	return &rewards[0] // Fallback to first
}

// addToInventory adds items to hero's inventory
func (h *TransactionHandler) addToInventory(heroID uint, itemType models.ItemType, quantity int) {
	var existingItem models.Item
	if err := database.DB.Where("hero_id = ? AND item_type = ?", heroID, itemType).First(&existingItem).Error; err == nil {
		existingItem.Quantity += quantity
		database.DB.Save(&existingItem)
	} else {
		newItem := models.Item{
			HeroID:   heroID,
			ItemType: itemType,
			Quantity: quantity,
		}
		database.DB.Create(&newItem)
	}
}

// updateStreak updates the recording streak
func (h *TransactionHandler) updateStreak(hero *models.Hero, transactionDate time.Time) {
	today := time.Now().Truncate(24 * time.Hour)
	txDate := transactionDate.Truncate(24 * time.Hour)

	if hero.LastRecordDate == nil {
		hero.RecordStreak = 1
	} else {
		lastDate := hero.LastRecordDate.Truncate(24 * time.Hour)
		daysDiff := int(today.Sub(lastDate).Hours() / 24)

		if daysDiff == 0 {
			// Same day, no streak change
			return
		} else if daysDiff == 1 {
			// Consecutive day
			hero.RecordStreak++

			// Check streak rewards
			for _, streakReward := range models.StreakRewards {
				if hero.RecordStreak == streakReward.Days {
					reward := models.Reward{
						UserID: hero.UserID,
						Type:   models.RewardTypeStreak,
					}
					database.DB.Create(&reward)

					for _, item := range streakReward.Rewards {
						rewardItem := models.RewardItem{
							RewardID: reward.ID,
							ItemType: item.ItemType,
							Quantity: item.Quantity,
						}
						database.DB.Create(&rewardItem)
						h.addToInventory(hero.ID, item.ItemType, item.Quantity)
					}
					break
				}
			}
		} else {
			// Streak broken
			if hero.StreakProtection > 0 {
				hero.StreakProtection--
			} else {
				hero.RecordStreak = 1
			}
		}
	}

	hero.LastRecordDate = &txDate
}

// updateQuestProgress updates quest progress based on transaction
func (h *TransactionHandler) updateQuestProgress(userID uint, transaction *models.Transaction) {
	var activeQuests []models.UserQuest
	database.DB.Preload("Quest").
		Where("user_id = ? AND status = ?", userID, models.QuestStatusActive).
		Find(&activeQuests)

	for _, userQuest := range activeQuests {
		quest := userQuest.Quest
		updated := false

		switch quest.TargetType {
		case "record_count":
			userQuest.Progress++
			updated = true
		case "receipt_count":
			if transaction.HasReceipt {
				userQuest.Progress++
				updated = true
			}
		case "income_count":
			if transaction.Type == models.TransactionTypeIncome {
				userQuest.Progress++
				updated = true
			}
		}

		if updated {
			if userQuest.Progress >= quest.TargetValue {
				userQuest.Status = models.QuestStatusCompleted
				now := time.Now()
				userQuest.CompletedAt = &now
			}
			database.DB.Save(&userQuest)
		}
	}
}

// GetTransactions returns a list of transactions
func (h *TransactionHandler) GetTransactions(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var req models.TransactionListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	query := database.DB.Where("user_id = ?", userID)

	// Apply filters
	if req.Year > 0 && req.Month > 0 {
		startDate := time.Date(req.Year, time.Month(req.Month), 1, 0, 0, 0, 0, time.Local)
		endDate := startDate.AddDate(0, 1, 0)
		query = query.Where("transaction_date >= ? AND transaction_date < ?", startDate, endDate)
	}
	if req.Type != "" {
		query = query.Where("type = ?", req.Type)
	}
	if req.Category != "" {
		query = query.Where("category = ?", req.Category)
	}

	// Pagination
	if req.Page < 1 {
		req.Page = 1
	}
	if req.Limit < 1 || req.Limit > 100 {
		req.Limit = 20
	}
	offset := (req.Page - 1) * req.Limit

	var transactions []models.Transaction
	var total int64

	query.Model(&models.Transaction{}).Count(&total)
	query.Order("transaction_date DESC, created_at DESC").
		Offset(offset).Limit(req.Limit).
		Find(&transactions)

	c.JSON(http.StatusOK, gin.H{
		"transactions": transactions,
		"total":        total,
		"page":         req.Page,
		"limit":        req.Limit,
		"total_pages":  (total + int64(req.Limit) - 1) / int64(req.Limit),
	})
}

// GetTransaction returns a single transaction
func (h *TransactionHandler) GetTransaction(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid transaction ID"})
		return
	}

	var transaction models.Transaction
	if err := database.DB.Where("id = ? AND user_id = ?", id, userID).First(&transaction).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Transaction not found"})
		return
	}

	c.JSON(http.StatusOK, transaction)
}

// UpdateTransaction updates a transaction
func (h *TransactionHandler) UpdateTransaction(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid transaction ID"})
		return
	}

	var transaction models.Transaction
	if err := database.DB.Where("id = ? AND user_id = ?", id, userID).First(&transaction).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Transaction not found"})
		return
	}

	var req models.TransactionUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update fields
	if req.Type != "" {
		transaction.Type = req.Type
	}
	if req.Amount > 0 {
		transaction.Amount = req.Amount
	}
	if req.Category != "" {
		transaction.Category = req.Category
	}
	transaction.Description = req.Description
	if !req.TransactionDate.IsZero() {
		transaction.TransactionDate = req.TransactionDate
	}

	if err := database.DB.Save(&transaction).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update transaction"})
		return
	}

	c.JSON(http.StatusOK, transaction)
}

// DeleteTransaction deletes a transaction
func (h *TransactionHandler) DeleteTransaction(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	id, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid transaction ID"})
		return
	}

	var transaction models.Transaction
	if err := database.DB.Where("id = ? AND user_id = ?", id, userID).First(&transaction).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Transaction not found"})
		return
	}

	if err := database.DB.Delete(&transaction).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete transaction"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Transaction deleted successfully"})
}

// GetSummary returns transaction summary for a period
func (h *TransactionHandler) GetSummary(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	year, _ := strconv.Atoi(c.Query("year"))
	month, _ := strconv.Atoi(c.Query("month"))

	if year == 0 {
		year = time.Now().Year()
	}
	if month == 0 {
		month = int(time.Now().Month())
	}

	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := startDate.AddDate(0, 1, 0)

	var totalIncome, totalExpense int64

	// Get income sum
	database.DB.Model(&models.Transaction{}).
		Where("user_id = ? AND type = ? AND transaction_date >= ? AND transaction_date < ?",
			userID, models.TransactionTypeIncome, startDate, endDate).
		Select("COALESCE(SUM(amount), 0)").Scan(&totalIncome)

	// Get expense sum
	database.DB.Model(&models.Transaction{}).
		Where("user_id = ? AND type = ? AND transaction_date >= ? AND transaction_date < ?",
			userID, models.TransactionTypeExpense, startDate, endDate).
		Select("COALESCE(SUM(amount), 0)").Scan(&totalExpense)

	// Get category breakdown
	type CategorySum struct {
		Category string `json:"category"`
		Amount   int64  `json:"amount"`
		Count    int    `json:"count"`
	}
	var categoryBreakdown []CategorySum
	database.DB.Model(&models.Transaction{}).
		Where("user_id = ? AND type = ? AND transaction_date >= ? AND transaction_date < ?",
			userID, models.TransactionTypeExpense, startDate, endDate).
		Select("category, SUM(amount) as amount, COUNT(*) as count").
		Group("category").
		Order("amount DESC").
		Scan(&categoryBreakdown)

	// Calculate percentages
	var categorySummary []models.CategorySummary
	for _, cat := range categoryBreakdown {
		percent := 0.0
		if totalExpense > 0 {
			percent = float64(cat.Amount) / float64(totalExpense) * 100
		}
		categorySummary = append(categorySummary, models.CategorySummary{
			Category: models.Category(cat.Category),
			Amount:   cat.Amount,
			Count:    cat.Count,
			Percent:  percent,
		})
	}

	c.JSON(http.StatusOK, gin.H{
		"year":              year,
		"month":             month,
		"total_income":      totalIncome,
		"total_expense":     totalExpense,
		"balance":           totalIncome - totalExpense,
		"category_breakdown": categorySummary,
	})
}
