package models

import (
	"time"
)

type Item struct {
	ID       uint     `json:"id" gorm:"primaryKey"`
	HeroID   uint     `json:"hero_id" gorm:"index;not null"`
	ItemType ItemType `json:"item_type" gorm:"not null"`
	Quantity int      `json:"quantity" gorm:"default:1"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Relations
	Hero *Hero `json:"hero,omitempty" gorm:"foreignKey:HeroID"`
}

// Item 정보
type ItemInfo struct {
	Type        ItemType `json:"type"`
	Name        string   `json:"name"`
	Description string   `json:"description"`
	Rarity      string   `json:"rarity"` // common, rare, epic
	MaxStack    int      `json:"max_stack"`
}

var ItemInfoMap = map[ItemType]ItemInfo{
	ItemTypeEnhanceStone: {
		Type:        ItemTypeEnhanceStone,
		Name:        "강화석",
		Description: "장비를 강화하는 데 사용됩니다.",
		Rarity:      "common",
		MaxStack:    9999,
	},
	ItemTypeAdvancedStone: {
		Type:        ItemTypeAdvancedStone,
		Name:        "고급 강화석",
		Description: "+7 이상 고강화에 필요합니다.",
		Rarity:      "rare",
		MaxStack:    999,
	},
	ItemTypeSkillBook: {
		Type:        ItemTypeSkillBook,
		Name:        "스킬북",
		Description: "공용 스킬을 습득합니다.",
		Rarity:      "common",
		MaxStack:    99,
	},
	ItemTypeAdvancedSkillBook: {
		Type:        ItemTypeAdvancedSkillBook,
		Name:        "고급 스킬북",
		Description: "고급 공용 스킬을 습득합니다.",
		Rarity:      "rare",
		MaxStack:    99,
	},
	ItemTypeRareSkillBook: {
		Type:        ItemTypeRareSkillBook,
		Name:        "희귀 스킬북",
		Description: "희귀 공용 스킬을 습득합니다.",
		Rarity:      "epic",
		MaxStack:    99,
	},
	ItemTypeGachaTicket: {
		Type:        ItemTypeGachaTicket,
		Name:        "가챠 티켓",
		Description: "일반 가챠를 1회 진행합니다.",
		Rarity:      "common",
		MaxStack:    999,
	},
	ItemTypePremiumTicket: {
		Type:        ItemTypePremiumTicket,
		Name:        "프리미엄 티켓",
		Description: "프리미엄 가챠를 1회 진행합니다.",
		Rarity:      "rare",
		MaxStack:    999,
	},
	ItemTypeAwakeningStone: {
		Type:        ItemTypeAwakeningStone,
		Name:        "각성석",
		Description: "장비를 각성하는 데 사용됩니다.",
		Rarity:      "epic",
		MaxStack:    99,
	},
	ItemTypePetFood: {
		Type:        ItemTypePetFood,
		Name:        "펫 먹이",
		Description: "펫의 경험치를 올립니다.",
		Rarity:      "common",
		MaxStack:    9999,
	},
}

type InventoryResponse struct {
	Items      []Item `json:"items"`
	Gold       int64  `json:"gold"`
	TotalSlots int    `json:"total_slots"`
	UsedSlots  int    `json:"used_slots"`
}

type UseItemRequest struct {
	ItemType ItemType `json:"item_type" binding:"required"`
	Quantity int      `json:"quantity" binding:"required,min=1"`
}
