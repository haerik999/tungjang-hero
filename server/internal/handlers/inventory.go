package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/tungjang-hero/server/internal/database"
	"github.com/tungjang-hero/server/internal/domain/models"
	"github.com/tungjang-hero/server/internal/middleware"
)

type InventoryHandler struct{}

func NewInventoryHandler() *InventoryHandler {
	return &InventoryHandler{}
}

// GetInventory returns user's inventory
func (h *InventoryHandler) GetInventory(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var items []models.Item
	database.DB.Where("hero_id = ?", hero.ID).Find(&items)

	c.JSON(http.StatusOK, models.InventoryResponse{
		Items:      items,
		Gold:       hero.Gold,
		TotalSlots: 100, // Default inventory size
		UsedSlots:  len(items),
	})
}

// GetItemInfo returns information about an item type
func (h *InventoryHandler) GetItemInfo(c *gin.Context) {
	itemType := models.ItemType(c.Param("type"))

	info, exists := models.ItemInfoMap[itemType]
	if !exists {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item type not found"})
		return
	}

	c.JSON(http.StatusOK, info)
}

// UseItem uses an item from inventory
func (h *InventoryHandler) UseItem(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var req models.UseItemRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if item exists in inventory
	var item models.Item
	if err := database.DB.Where("hero_id = ? AND item_type = ?", hero.ID, req.ItemType).First(&item).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found in inventory"})
		return
	}

	if item.Quantity < req.Quantity {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Not enough items"})
		return
	}

	// Process item usage based on type
	result := h.processItemUsage(&hero, req.ItemType, req.Quantity)

	// Update inventory
	item.Quantity -= req.Quantity
	if item.Quantity <= 0 {
		database.DB.Delete(&item)
	} else {
		database.DB.Save(&item)
	}

	database.DB.Save(&hero)

	c.JSON(http.StatusOK, gin.H{
		"message":        "Item used successfully",
		"result":         result,
		"remaining_qty":  item.Quantity,
	})
}

// processItemUsage handles the effect of using an item
func (h *InventoryHandler) processItemUsage(hero *models.Hero, itemType models.ItemType, quantity int) map[string]interface{} {
	result := make(map[string]interface{})

	switch itemType {
	case models.ItemTypePetFood:
		// TODO: Apply to pet when pet system is implemented
		result["effect"] = "Pet experience gained"
		result["amount"] = quantity * 10

	case models.ItemTypeSkillBook, models.ItemTypeAdvancedSkillBook, models.ItemTypeRareSkillBook:
		// Skill learning is handled by skill handler
		result["effect"] = "Use through skill menu"

	case models.ItemTypeGachaTicket, models.ItemTypePremiumTicket:
		// Gacha is handled by gacha handler
		result["effect"] = "Use through gacha menu"

	case models.ItemTypeEnhanceStone, models.ItemTypeAdvancedStone:
		// Enhancement is handled by equipment handler
		result["effect"] = "Use through equipment enhancement menu"

	case models.ItemTypeAwakeningStone:
		// Awakening is handled by equipment handler
		result["effect"] = "Use through equipment awakening menu"
	}

	return result
}

// SellItems sells items for gold
func (h *InventoryHandler) SellItems(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var hero models.Hero
	if err := database.DB.Where("user_id = ?", userID).First(&hero).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Hero not found"})
		return
	}

	var req struct {
		ItemType models.ItemType `json:"item_type" binding:"required"`
		Quantity int             `json:"quantity" binding:"required,min=1"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if item exists
	var item models.Item
	if err := database.DB.Where("hero_id = ? AND item_type = ?", hero.ID, req.ItemType).First(&item).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Item not found"})
		return
	}

	if item.Quantity < req.Quantity {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Not enough items"})
		return
	}

	// Calculate sell price (based on item rarity)
	pricePerItem := int64(10) // Default
	if info, exists := models.ItemInfoMap[req.ItemType]; exists {
		switch info.Rarity {
		case "common":
			pricePerItem = 10
		case "rare":
			pricePerItem = 50
		case "epic":
			pricePerItem = 200
		}
	}

	totalGold := pricePerItem * int64(req.Quantity)

	// Update inventory and gold
	item.Quantity -= req.Quantity
	if item.Quantity <= 0 {
		database.DB.Delete(&item)
	} else {
		database.DB.Save(&item)
	}

	hero.Gold += totalGold
	database.DB.Save(&hero)

	c.JSON(http.StatusOK, gin.H{
		"message":       "Items sold successfully",
		"gold_earned":   totalGold,
		"total_gold":    hero.Gold,
		"remaining_qty": item.Quantity,
	})
}
