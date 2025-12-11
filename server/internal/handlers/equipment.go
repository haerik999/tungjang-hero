package handlers

import (
	"encoding/json"
	"math/rand"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/tungjang-hero/server/internal/database"
	"github.com/tungjang-hero/server/internal/domain/models"
	"github.com/tungjang-hero/server/internal/middleware"
)

type EquipmentHandler struct{}

func NewEquipmentHandler() *EquipmentHandler {
	return &EquipmentHandler{}
}

// GetEquipments returns all equipment in inventory
func (h *EquipmentHandler) GetEquipments(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var equipments []models.Equipment
	database.DB.Preload("Template").Where("hero_id = ?", hero.ID).Find(&equipments)

	// Separate equipped and inventory
	var equipped []models.Equipment
	var inventory []models.Equipment

	for _, eq := range equipments {
		if eq.IsEquipped {
			equipped = append(equipped, eq)
		} else {
			inventory = append(inventory, eq)
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"equipped":  equipped,
		"inventory": inventory,
	})
}

// GetEquipment returns a single equipment
func (h *EquipmentHandler) GetEquipment(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var equipment models.Equipment
	if err := database.DB.Preload("Template").Where("id = ? AND hero_id = ?", id, hero.ID).First(&equipment).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Equipment not found"})
		return
	}

	c.JSON(http.StatusOK, equipment)
}

// EquipItem equips an item
func (h *EquipmentHandler) EquipItem(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var req models.EquipRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get equipment to equip
	var equipment models.Equipment
	if err := database.DB.Where("id = ? AND hero_id = ?", req.EquipmentID, hero.ID).First(&equipment).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Equipment not found"})
		return
	}

	// Unequip current item in that slot
	database.DB.Model(&models.Equipment{}).
		Where("hero_id = ? AND slot = ? AND is_equipped = true", hero.ID, equipment.Slot).
		Update("is_equipped", false)

	// Equip new item
	equipment.IsEquipped = true
	database.DB.Save(&equipment)

	c.JSON(http.StatusOK, gin.H{
		"message":   "Equipment equipped successfully",
		"equipment": equipment,
	})
}

// UnequipItem unequips an item
func (h *EquipmentHandler) UnequipItem(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var equipment models.Equipment
	if err := database.DB.Where("id = ? AND hero_id = ?", id, hero.ID).First(&equipment).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Equipment not found"})
		return
	}

	equipment.IsEquipped = false
	database.DB.Save(&equipment)

	c.JSON(http.StatusOK, gin.H{
		"message":   "Equipment unequipped successfully",
		"equipment": equipment,
	})
}

// EnhanceEquipment enhances an equipment
func (h *EquipmentHandler) EnhanceEquipment(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var req models.EnhanceRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get equipment
	var equipment models.Equipment
	if err := database.DB.Where("id = ? AND hero_id = ?", req.EquipmentID, hero.ID).First(&equipment).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Equipment not found"})
		return
	}

	// Check max level
	if equipment.EnhanceLevel >= 10 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Equipment already at max enhancement level"})
		return
	}

	// Determine stone type needed
	stoneType := models.ItemTypeEnhanceStone
	if equipment.EnhanceLevel >= 7 {
		stoneType = models.ItemTypeAdvancedStone
	}

	// Check if user has enough stones
	stoneCost := models.EnhanceStoneCost[equipment.EnhanceLevel]
	var stoneItem models.Item
	if err := database.DB.Where("hero_id = ? AND item_type = ?", hero.ID, stoneType).First(&stoneItem).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Not enough enhancement stones"})
		return
	}

	if stoneItem.Quantity < stoneCost {
		c.JSON(http.StatusBadRequest, gin.H{
			"error":    "Not enough enhancement stones",
			"required": stoneCost,
			"have":     stoneItem.Quantity,
		})
		return
	}

	// Consume stones
	stoneItem.Quantity -= stoneCost
	if stoneItem.Quantity <= 0 {
		database.DB.Delete(&stoneItem)
	} else {
		database.DB.Save(&stoneItem)
	}

	// Roll for success
	successRate := models.EnhanceSuccessRate[equipment.EnhanceLevel]
	success := rand.Float64() < successRate

	result := models.EnhanceResult{
		Success:      success,
		StonesUsed:   stoneCost,
		StonesRemain: stoneItem.Quantity,
	}

	if success {
		equipment.EnhanceLevel++

		// Increase stats by 5% per level
		multiplier := 1.0 + float64(equipment.EnhanceLevel)*0.05
		equipment.ATK = int(float64(equipment.ATK) * multiplier)
		equipment.DEF = int(float64(equipment.DEF) * multiplier)
		equipment.MAG = int(float64(equipment.MAG) * multiplier)
		equipment.HP = int(float64(equipment.HP) * multiplier)

		database.DB.Save(&equipment)
		result.NewLevel = equipment.EnhanceLevel
		result.Equipment = &equipment
	}

	c.JSON(http.StatusOK, result)
}

// SellEquipment sells equipment for gold
func (h *EquipmentHandler) SellEquipment(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	id, _ := strconv.ParseUint(c.Param("id"), 10, 64)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var equipment models.Equipment
	if err := database.DB.Where("id = ? AND hero_id = ?", id, hero.ID).First(&equipment).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Equipment not found"})
		return
	}

	if equipment.IsEquipped {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot sell equipped item"})
		return
	}

	// Calculate sell price based on grade and enhancement
	basePrice := map[models.EquipmentGrade]int64{
		models.GradeNormal:    100,
		models.GradeUncommon:  500,
		models.GradeRare:      2000,
		models.GradeEpic:      10000,
		models.GradeLegendary: 50000,
		models.GradeMythic:    200000,
	}

	price := basePrice[equipment.Grade]
	price = int64(float64(price) * (1.0 + float64(equipment.EnhanceLevel)*0.1))

	hero.Gold += price
	database.DB.Save(&hero)
	database.DB.Delete(&equipment)

	c.JSON(http.StatusOK, gin.H{
		"message":    "Equipment sold successfully",
		"gold":       price,
		"total_gold": hero.Gold,
	})
}

// GenerateEquipmentDrop generates a random equipment drop
func GenerateEquipmentDrop(heroID uint, stageLevel int, grade models.EquipmentGrade) *models.Equipment {
	// Get random template for this grade
	var templates []models.EquipmentTemplate
	database.DB.Where("grade = ? AND drop_stage_min <= ?", grade, stageLevel).Find(&templates)

	if len(templates) == 0 {
		return nil
	}

	template := templates[rand.Intn(len(templates))]

	// Apply grade multiplier
	multiplier := models.GradeMultiplier[grade]

	equipment := models.Equipment{
		HeroID:       heroID,
		TemplateID:   template.ID,
		Slot:         template.Slot,
		Grade:        grade,
		EnhanceLevel: 0,
		ATK:          int(float64(template.BaseATK) * multiplier),
		DEF:          int(float64(template.BaseDEF) * multiplier),
		MAG:          int(float64(template.BaseMAG) * multiplier),
		MDF:          int(float64(template.BaseMDF) * multiplier),
		HP:           int(float64(template.BaseHP) * multiplier),
		MP:           int(float64(template.BaseMP) * multiplier),
		SPD:          int(float64(template.BaseSPD) * multiplier),
		LUK:          int(float64(template.BaseLUK) * multiplier),
		IsEquipped:   false,
	}

	// Generate extra options
	optionCount := models.GradeOptionCount[grade]
	if optionCount > 0 {
		options := generateExtraOptions(optionCount)
		optionsJSON, _ := json.Marshal(options)
		equipment.ExtraOptions = string(optionsJSON)
	}

	database.DB.Create(&equipment)
	return &equipment
}

// generateExtraOptions generates random extra options for equipment
func generateExtraOptions(count int) []models.ExtraOption {
	possibleStats := []string{"atk", "def", "mag", "mdf", "hp", "mp", "spd", "luk", "crit", "crit_dmg"}
	var options []models.ExtraOption

	usedStats := make(map[string]bool)

	for i := 0; i < count; i++ {
		// Pick random stat that hasn't been used
		var stat string
		for {
			stat = possibleStats[rand.Intn(len(possibleStats))]
			if !usedStats[stat] {
				usedStats[stat] = true
				break
			}
		}

		// Random type and value
		optionType := "flat"
		var value float64

		if rand.Float64() < 0.5 {
			optionType = "percent"
			value = float64(rand.Intn(10) + 3) // 3-12%
		} else {
			value = float64(rand.Intn(30) + 10) // 10-40 flat
		}

		options = append(options, models.ExtraOption{
			Stat:  stat,
			Type:  optionType,
			Value: value,
		})
	}

	return options
}
