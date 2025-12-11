package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/tungjang-hero/server/internal/database"
	"github.com/tungjang-hero/server/internal/domain/models"
	"github.com/tungjang-hero/server/internal/middleware"
)

type UserHandler struct{}

func NewUserHandler() *UserHandler {
	return &UserHandler{}
}

// GetMe returns the current user's information
func (h *UserHandler) GetMe(c *gin.Context) {
	user := middleware.GetCurrentUser(c)
	if user == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return
	}

	// Load hero if exists
	var hero models.Hero
	if err := database.DB.Where("user_id = ?", user.ID).First(&hero).Error; err == nil {
		user.Hero = &hero
	}

	c.JSON(http.StatusOK, user)
}

// UpdateMe updates the current user's information
func (h *UserHandler) UpdateMe(c *gin.Context) {
	user := middleware.GetCurrentUser(c)
	if user == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return
	}

	var req models.UserUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update fields
	if req.Nickname != "" {
		user.Nickname = req.Nickname
	}

	if err := database.DB.Save(user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update user"})
		return
	}

	c.JSON(http.StatusOK, user)
}

// GetUserStats returns user statistics
func (h *UserHandler) GetUserStats(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	// Get transaction count
	var transactionCount int64
	database.DB.Model(&models.Transaction{}).Where("user_id = ?", userID).Count(&transactionCount)

	// Get receipt count
	var receiptCount int64
	database.DB.Model(&models.Transaction{}).Where("user_id = ? AND has_receipt = true", userID).Count(&receiptCount)

	// Get hero info
	var hero models.Hero
	database.DB.Where("user_id = ?", userID).First(&hero)

	// Get achievement count
	var achievementCount int64
	database.DB.Model(&models.UserAchievement{}).Where("user_id = ? AND unlocked_at IS NOT NULL", userID).Count(&achievementCount)

	// Get quest completion count
	var questCount int64
	database.DB.Model(&models.UserQuest{}).Where("user_id = ? AND status = ?", userID, models.QuestStatusClaimed).Count(&questCount)

	c.JSON(http.StatusOK, gin.H{
		"total_transactions": transactionCount,
		"total_receipts":     receiptCount,
		"hero_level":         hero.Level,
		"record_streak":      hero.RecordStreak,
		"achievements":       achievementCount,
		"quests_completed":   questCount,
	})
}
