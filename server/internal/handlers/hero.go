package handlers

import (
	"math"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/tungjang-hero/server/internal/database"
	"github.com/tungjang-hero/server/internal/domain/models"
	"github.com/tungjang-hero/server/internal/middleware"
)

type HeroHandler struct{}

func NewHeroHandler() *HeroHandler {
	return &HeroHandler{}
}

// CreateHero creates a new hero for the user
func (h *HeroHandler) CreateHero(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	// Check if hero already exists
	var existingHero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&existingHero).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Hero already exists"})
		return
	}

	var req models.HeroCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Create hero with initial stats based on build type
	hero := models.Hero{
		UserID:          userID,
		Name:            req.Name,
		Level:           1,
		Exp:             0,
		Gold:            1000, // Starting gold
		HP:              100,
		MP:              50,
		ATK:             10,
		DEF:             5,
		MAG:             10,
		MDF:             5,
		SPD:             10,
		LUK:             5,
		StatPoints:      5, // Initial stat points
		CurrentStageID:  1,
		LastHuntingTime: time.Now(),
	}

	// Apply build type bonuses
	switch req.BuildType {
	case "physical":
		hero.AllocatedATK = 2
		hero.AllocatedHP = 2
		hero.AllocatedSPD = 1
	case "magic":
		hero.AllocatedMAG = 2
		hero.AllocatedMP = 2
		hero.AllocatedMDF = 1
	case "tank":
		hero.AllocatedHP = 2
		hero.AllocatedDEF = 2
		hero.AllocatedMDF = 1
	case "balance":
		hero.AllocatedHP = 1
		hero.AllocatedATK = 1
		hero.AllocatedMAG = 1
		hero.AllocatedDEF = 1
		hero.AllocatedSPD = 1
	}

	if err := database.DB.Create(&hero).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create hero"})
		return
	}

	// Create default presets
	for i, preset := range models.DefaultPresets {
		p := models.Preset{
			HeroID:   hero.ID,
			Name:     preset.Name,
			Icon:     preset.Icon,
			IsActive: i == 0, // First preset is active
		}
		database.DB.Create(&p)
	}

	c.JSON(http.StatusCreated, hero)
}

// GetHero returns the user's hero information
func (h *HeroHandler) GetHero(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	c.JSON(http.StatusOK, hero)
}

// GetHeroStats returns detailed hero stats
func (h *HeroHandler) GetHeroStats(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	response := models.HeroStatsResponse{
		Hero:      hero,
		TotalHP:   hero.TotalHP(),
		TotalMP:   hero.TotalMP(),
		TotalATK:  hero.TotalATK(),
		TotalDEF:  hero.TotalDEF(),
		TotalMAG:  hero.TotalMAG(),
		TotalMDF:  hero.TotalMDF(),
		TotalSPD:  hero.TotalSPD(),
		TotalLUK:  hero.TotalLUK(),
		ExpToNext: hero.ExpToNextLevel(),
	}

	c.JSON(http.StatusOK, response)
}

// AllocateStat allocates stat points
func (h *HeroHandler) AllocateStat(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var req models.AllocateStatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if hero.StatPoints < req.Points {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Not enough stat points"})
		return
	}

	// Allocate points
	switch req.Stat {
	case "hp":
		hero.AllocatedHP += req.Points
	case "mp":
		hero.AllocatedMP += req.Points
	case "atk":
		hero.AllocatedATK += req.Points
	case "def":
		hero.AllocatedDEF += req.Points
	case "mag":
		hero.AllocatedMAG += req.Points
	case "mdf":
		hero.AllocatedMDF += req.Points
	case "spd":
		hero.AllocatedSPD += req.Points
	case "luk":
		hero.AllocatedLUK += req.Points
	}

	hero.StatPoints -= req.Points

	if err := database.DB.Save(&hero).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to allocate stats"})
		return
	}

	c.JSON(http.StatusOK, hero)
}

// ResetStats resets all stat allocations
func (h *HeroHandler) ResetStats(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	// Calculate total allocated points
	totalAllocated := hero.AllocatedHP + hero.AllocatedMP + hero.AllocatedATK +
		hero.AllocatedDEF + hero.AllocatedMAG + hero.AllocatedMDF +
		hero.AllocatedSPD + hero.AllocatedLUK

	// Reset all allocations
	hero.AllocatedHP = 0
	hero.AllocatedMP = 0
	hero.AllocatedATK = 0
	hero.AllocatedDEF = 0
	hero.AllocatedMAG = 0
	hero.AllocatedMDF = 0
	hero.AllocatedSPD = 0
	hero.AllocatedLUK = 0

	// Return points
	hero.StatPoints += totalAllocated

	if err := database.DB.Save(&hero).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to reset stats"})
		return
	}

	c.JSON(http.StatusOK, hero)
}

// CollectOfflineRewards collects accumulated offline rewards
func (h *HeroHandler) CollectOfflineRewards(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	// Get current stage info
	var stage models.Stage
	if err := database.DB.First(&stage, hero.CurrentStageID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Stage not found"})
		return
	}

	// Calculate offline time (max 24 hours)
	now := time.Now()
	offlineDuration := now.Sub(hero.LastHuntingTime)
	maxOffline := 24 * time.Hour
	if offlineDuration > maxOffline {
		offlineDuration = maxOffline
	}

	// Calculate rewards (30% of normal rate for offline)
	offlineMinutes := offlineDuration.Minutes()
	goldReward := int64(float64(stage.GoldPerMin) * offlineMinutes * 0.3)
	expReward := int64(float64(stage.ExpPerMin) * offlineMinutes * 0.3)

	// Add accumulated offline rewards
	goldReward += hero.OfflineGold
	expReward += hero.OfflineExp

	// Apply rewards
	hero.Gold += goldReward
	hero.Exp += expReward
	hero.OfflineGold = 0
	hero.OfflineExp = 0
	hero.LastHuntingTime = now

	// Check for level up
	leveledUp := false
	newLevel := hero.Level
	for hero.Exp >= hero.ExpToNextLevel() && hero.Level < 100 {
		hero.Exp -= hero.ExpToNextLevel()
		hero.Level++
		hero.StatPoints += 5 // 5 stat points per level
		leveledUp = true
		newLevel = hero.Level
	}

	if err := database.DB.Save(&hero).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to collect rewards"})
		return
	}

	response := models.HuntingRewardResponse{
		Gold:      goldReward,
		Exp:       expReward,
		LeveledUp: leveledUp,
	}
	if leveledUp {
		response.NewLevel = newLevel
	}

	c.JSON(http.StatusOK, response)
}

// ChangeStage changes the hunting stage
func (h *HeroHandler) ChangeStage(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var req models.StageChangeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get stage info
	var stage models.Stage
	if err := database.DB.First(&stage, req.StageID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Stage not found"})
		return
	}

	// Check level requirement
	if hero.Level < stage.RequiredLvl {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":          "Level too low",
			"required_level": stage.RequiredLvl,
		})
		return
	}

	hero.CurrentStageID = int(req.StageID)

	if err := database.DB.Save(&hero).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to change stage"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Stage changed successfully",
		"stage":   stage,
	})
}

// GetStages returns all available stages
func (h *HeroHandler) GetStages(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var stages []models.Stage
	database.DB.Order("chapter, stage_number").Find(&stages)

	// Find highest unlocked stage
	unlockedUntil := 1
	for _, stage := range stages {
		if hero.Level >= stage.RequiredLvl {
			unlockedUntil = int(stage.ID)
		}
	}

	c.JSON(http.StatusOK, models.StageListResponse{
		Stages:        stages,
		CurrentStage:  hero.CurrentStageID,
		UnlockedUntil: unlockedUntil,
	})
}

// SimulateHunting simulates hunting for real-time display (called periodically by client)
func (h *HeroHandler) SimulateHunting(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var stage models.Stage
	if err := database.DB.First(&stage, hero.CurrentStageID).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Stage not found"})
		return
	}

	// Calculate rewards for 1 minute of hunting
	goldReward := int64(stage.GoldPerMin)
	expReward := int64(stage.ExpPerMin)

	// Random drops
	var droppedItems []models.Item
	if rand := math.Floor(float64(time.Now().UnixNano()%1000) / 1000); rand < stage.NormalDropRate {
		// Would create equipment here
	}

	// Apply rewards
	hero.Gold += goldReward
	hero.Exp += expReward
	hero.LastHuntingTime = time.Now()

	// Check for level up
	leveledUp := false
	newLevel := hero.Level
	for hero.Exp >= hero.ExpToNextLevel() && hero.Level < 100 {
		hero.Exp -= hero.ExpToNextLevel()
		hero.Level++
		hero.StatPoints += 5
		leveledUp = true
		newLevel = hero.Level
	}

	database.DB.Save(&hero)

	response := models.HuntingRewardResponse{
		Gold:         goldReward,
		Exp:          expReward,
		LeveledUp:    leveledUp,
		DroppedItems: droppedItems,
	}
	if leveledUp {
		response.NewLevel = newLevel
	}

	c.JSON(http.StatusOK, response)
}
