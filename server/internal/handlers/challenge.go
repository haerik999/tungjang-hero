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

type ChallengeHandler struct{}

func NewChallengeHandler() *ChallengeHandler {
	return &ChallengeHandler{}
}

// GetChallenges returns available challenges
func (h *ChallengeHandler) GetChallenges(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var req models.ChallengeListRequest
	if err := c.ShouldBindQuery(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Refresh solo challenges if needed
	h.refreshSoloChallenges(userID)

	query := database.DB.Model(&models.Challenge{})

	// Apply filters
	if req.Type != "" {
		query = query.Where("type = ?", req.Type)
	}
	if req.Status != "" {
		query = query.Where("status = ?", req.Status)
	}
	if req.Category != "" {
		query = query.Where("category = ?", req.Category)
	}

	// For community challenges, only show active/waiting
	if req.Type == string(models.ChallengeTypeCommunity) {
		query = query.Where("status IN ?", []models.ChallengeStatus{
			models.ChallengeStatusWaiting,
			models.ChallengeStatusActive,
		})
	}

	// Pagination
	if req.Page < 1 {
		req.Page = 1
	}
	if req.Limit < 1 || req.Limit > 50 {
		req.Limit = 20
	}
	offset := (req.Page - 1) * req.Limit

	var challenges []models.Challenge
	var total int64

	query.Count(&total)
	query.Preload("Participants").
		Order("created_at DESC").
		Offset(offset).Limit(req.Limit).
		Find(&challenges)

	// Build response with user-specific info
	var response []models.ChallengeResponse
	for _, ch := range challenges {
		resp := models.ChallengeResponse{
			Challenge:        ch,
			ParticipantCount: len(ch.Participants),
		}

		// Calculate completion rate
		completedCount := 0
		for _, p := range ch.Participants {
			if p.IsCompleted {
				completedCount++
			}
		}
		if len(ch.Participants) > 0 {
			resp.CompletionRate = float64(completedCount) / float64(len(ch.Participants)) * 100
		}

		// Check user participation
		for _, p := range ch.Participants {
			if p.UserID == userID {
				resp.UserProgress = &p.CurrentValue
				resp.UserCompleted = &p.IsCompleted
				break
			}
		}

		response = append(response, resp)
	}

	c.JSON(http.StatusOK, gin.H{
		"challenges":  response,
		"total":       total,
		"page":        req.Page,
		"limit":       req.Limit,
		"total_pages": (total + int64(req.Limit) - 1) / int64(req.Limit),
	})
}

// refreshSoloChallenges creates daily solo challenges
func (h *ChallengeHandler) refreshSoloChallenges(userID uint) {
	now := time.Now()
	today := now.Truncate(24 * time.Hour)

	// Check if daily challenges exist for today
	var count int64
	database.DB.Model(&models.Challenge{}).
		Where("type = ? AND start_date >= ?", models.ChallengeTypeSolo, today).
		Count(&count)

	if count == 0 {
		// Create daily challenges
		for i, ch := range models.SoloDailyChallenges {
			if i >= 3 { // Max 3 daily challenges
				break
			}

			challenge := ch
			challenge.StartDate = today
			challenge.EndDate = today.AddDate(0, 0, 1)
			challenge.Status = models.ChallengeStatusActive

			database.DB.Create(&challenge)
		}
	}

	// Create weekly challenges on Monday
	if now.Weekday() == time.Monday {
		weekStart := today
		var weekCount int64
		database.DB.Model(&models.Challenge{}).
			Where("type = ? AND duration = ? AND start_date >= ?",
				models.ChallengeTypeSolo, models.ChallengeDuration7Days, weekStart).
			Count(&weekCount)

		if weekCount == 0 {
			for i, ch := range models.SoloWeeklyChallenges {
				if i >= 2 { // Max 2 weekly challenges
					break
				}

				challenge := ch
				challenge.StartDate = weekStart
				challenge.EndDate = weekStart.AddDate(0, 0, 7)
				challenge.Status = models.ChallengeStatusActive

				database.DB.Create(&challenge)
			}
		}
	}
}

// GetChallenge returns a single challenge
func (h *ChallengeHandler) GetChallenge(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)

	var challenge models.Challenge
	if err := database.DB.Preload("Participants").First(&challenge, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Challenge not found"})
		return
	}

	resp := models.ChallengeResponse{
		Challenge:        challenge,
		ParticipantCount: len(challenge.Participants),
	}

	completedCount := 0
	for _, p := range challenge.Participants {
		if p.IsCompleted {
			completedCount++
		}
		if p.UserID == userID {
			resp.UserProgress = &p.CurrentValue
			resp.UserCompleted = &p.IsCompleted
		}
	}
	if len(challenge.Participants) > 0 {
		resp.CompletionRate = float64(completedCount) / float64(len(challenge.Participants)) * 100
	}

	c.JSON(http.StatusOK, resp)
}

// CreateChallenge creates a new community challenge
func (h *ChallengeHandler) CreateChallenge(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	// Check user eligibility (7 days + 20 records)
	var user models.User
	database.DB.First(&user, userID)

	if time.Since(user.CreatedAt).Hours() < 7*24 {
		c.JSON(http.StatusForbidden, gin.H{"error": "Account must be at least 7 days old"})
		return
	}

	var recordCount int64
	database.DB.Model(&models.Transaction{}).Where("user_id = ?", userID).Count(&recordCount)
	if recordCount < 20 {
		c.JSON(http.StatusForbidden, gin.H{"error": "Must have at least 20 records"})
		return
	}

	// Check daily creation limit
	today := time.Now().Truncate(24 * time.Hour)
	var todayCount int64
	database.DB.Model(&models.Challenge{}).
		Where("creator_id = ? AND created_at >= ?", userID, today).
		Count(&todayCount)

	if todayCount >= 2 {
		c.JSON(http.StatusTooManyRequests, gin.H{"error": "Daily challenge creation limit reached (2)"})
		return
	}

	var req models.ChallengeCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Calculate start and end dates
	startDate := time.Now().Add(24 * time.Hour).Truncate(24 * time.Hour) // Start tomorrow
	var endDate time.Time

	switch req.Duration {
	case models.ChallengeDuration1Day:
		endDate = startDate.AddDate(0, 0, 1)
	case models.ChallengeDuration3Days:
		endDate = startDate.AddDate(0, 0, 3)
	case models.ChallengeDuration7Days:
		endDate = startDate.AddDate(0, 0, 7)
	case models.ChallengeDuration14Days:
		endDate = startDate.AddDate(0, 0, 14)
	case models.ChallengeDuration30Days:
		endDate = startDate.AddDate(0, 0, 30)
	}

	// Get default rewards
	rewards := models.CommunityRewardByDuration[req.Duration]

	challenge := models.Challenge{
		Type:            models.ChallengeTypeCommunity,
		Title:           req.Title,
		Description:     req.Description,
		Category:        req.Category,
		TargetType:      req.TargetType,
		TargetValue:     req.TargetValue,
		Duration:        req.Duration,
		StartDate:       startDate,
		EndDate:         endDate,
		CreatorID:       &userID,
		MaxParticipants: req.MaxParticipants,
		MinParticipants: 2,
		RewardItems:     rewards,
		Status:          models.ChallengeStatusWaiting,
	}

	if err := database.DB.Create(&challenge).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create challenge"})
		return
	}

	// Auto-join creator
	participation := models.ChallengeParticipation{
		ChallengeID: challenge.ID,
		UserID:      userID,
		JoinedAt:    time.Now(),
	}
	database.DB.Create(&participation)

	c.JSON(http.StatusCreated, challenge)
}

// JoinChallenge joins a community challenge
func (h *ChallengeHandler) JoinChallenge(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)

	var challenge models.Challenge
	if err := database.DB.Preload("Participants").First(&challenge, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Challenge not found"})
		return
	}

	// Check if already joined
	for _, p := range challenge.Participants {
		if p.UserID == userID {
			c.JSON(http.StatusConflict, gin.H{"error": "Already joined this challenge"})
			return
		}
	}

	// Check max participants
	if challenge.MaxParticipants > 0 && len(challenge.Participants) >= challenge.MaxParticipants {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Challenge is full"})
		return
	}

	// Check status
	if challenge.Status != models.ChallengeStatusWaiting && challenge.Status != models.ChallengeStatusActive {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot join this challenge"})
		return
	}

	participation := models.ChallengeParticipation{
		ChallengeID: challenge.ID,
		UserID:      userID,
		JoinedAt:    time.Now(),
	}

	if err := database.DB.Create(&participation).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to join challenge"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Successfully joined challenge"})
}

// ClaimChallengeReward claims reward for completed challenge
func (h *ChallengeHandler) ClaimChallengeReward(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)

	var participation models.ChallengeParticipation
	if err := database.DB.Preload("Challenge").
		Where("challenge_id = ? AND user_id = ?", id, userID).
		First(&participation).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Not participating in this challenge"})
		return
	}

	if !participation.IsCompleted {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Challenge not completed"})
		return
	}

	if participation.RewardClaimed {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Reward already claimed"})
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
	if err := json.Unmarshal([]byte(participation.Challenge.RewardItems), &rewardItems); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to parse rewards"})
		return
	}

	// Create reward record
	reward := models.Reward{
		UserID:      userID,
		Type:        models.RewardTypeChallenge,
		ChallengeID: &participation.ChallengeID,
	}
	database.DB.Create(&reward)

	// Give items
	for _, item := range rewardItems {
		item.RewardID = reward.ID
		database.DB.Create(&item)

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

	participation.RewardClaimed = true
	database.DB.Save(&participation)

	c.JSON(http.StatusOK, gin.H{
		"message": "Reward claimed successfully",
		"items":   rewardItems,
	})
}

// GetMyChallenges returns user's challenges
func (h *ChallengeHandler) GetMyChallenges(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var participations []models.ChallengeParticipation
	database.DB.Preload("Challenge").
		Where("user_id = ?", userID).
		Order("joined_at DESC").
		Find(&participations)

	c.JSON(http.StatusOK, participations)
}
