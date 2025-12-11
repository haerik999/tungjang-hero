package models

import (
	"time"
)

type RewardType string

const (
	RewardTypeTransaction RewardType = "transaction"
	RewardTypeReceipt     RewardType = "receipt"
	RewardTypeQuest       RewardType = "quest"
	RewardTypeStreak      RewardType = "streak"
	RewardTypeChallenge   RewardType = "challenge"
	RewardTypeAchievement RewardType = "achievement"
	RewardTypeBoss        RewardType = "boss"
)

type ItemType string

const (
	ItemTypeEnhanceStone       ItemType = "enhance_stone"        // 강화석
	ItemTypeAdvancedStone      ItemType = "advanced_stone"       // 고급 강화석
	ItemTypeSkillBook          ItemType = "skill_book"           // 스킬북
	ItemTypeAdvancedSkillBook  ItemType = "advanced_skill_book"  // 고급 스킬북
	ItemTypeRareSkillBook      ItemType = "rare_skill_book"      // 희귀 스킬북
	ItemTypeGachaTicket        ItemType = "gacha_ticket"         // 가챠 티켓
	ItemTypePremiumTicket      ItemType = "premium_ticket"       // 프리미엄 티켓
	ItemTypeAwakeningStone     ItemType = "awakening_stone"      // 각성석
	ItemTypePetFood            ItemType = "pet_food"             // 펫 먹이
	ItemTypeGold               ItemType = "gold"                 // 골드
	ItemTypeExp                ItemType = "exp"                  // 경험치
)

type Reward struct {
	ID            uint       `json:"id" gorm:"primaryKey"`
	UserID        uint       `json:"user_id" gorm:"index;not null"`
	Type          RewardType `json:"type" gorm:"not null"`
	TransactionID *uint      `json:"transaction_id,omitempty"`
	QuestID       *uint      `json:"quest_id,omitempty"`
	ChallengeID   *uint      `json:"challenge_id,omitempty"`
	AchievementID *uint      `json:"achievement_id,omitempty"`
	CreatedAt     time.Time  `json:"created_at"`

	// Reward Items
	Items []RewardItem `json:"items" gorm:"foreignKey:RewardID"`
}

type RewardItem struct {
	ID       uint     `json:"id" gorm:"primaryKey"`
	RewardID uint     `json:"reward_id" gorm:"index;not null"`
	ItemType ItemType `json:"item_type" gorm:"not null"`
	Quantity int      `json:"quantity" gorm:"not null"`
}

// 기본 거래 기록 보상 확률
type TransactionRewardProbability struct {
	ItemType    ItemType
	Probability float64 // 0.0 ~ 1.0
	MinQuantity int
	MaxQuantity int
}

var BasicTransactionRewards = []TransactionRewardProbability{
	{ItemTypeEnhanceStone, 0.60, 1, 2},
	{ItemTypeSkillBook, 0.20, 1, 1},
	{ItemTypeGachaTicket, 0.10, 1, 1},
	{ItemTypePetFood, 0.10, 1, 3},
}

var ReceiptBonusRewards = []TransactionRewardProbability{
	{ItemTypeEnhanceStone, 0.50, 2, 3},
	{ItemTypeAdvancedStone, 0.20, 1, 1},
	{ItemTypeAdvancedSkillBook, 0.15, 1, 1},
	{ItemTypeGachaTicket, 0.10, 1, 1},
	{ItemTypePremiumTicket, 0.05, 1, 1},
}

// 일일 보상 상한
type DailyRewardLimit struct {
	MaxRecords           int `json:"max_records"`
	MaxEnhanceStones     int `json:"max_enhance_stones"`
	MaxSkillBooks        int `json:"max_skill_books"`
	MaxGachaTickets      int `json:"max_gacha_tickets"`
}

var BasicDailyLimit = DailyRewardLimit{
	MaxRecords:       10,
	MaxEnhanceStones: 10,
	MaxSkillBooks:    2,
	MaxGachaTickets:  1,
}

var WithReceiptDailyLimit = DailyRewardLimit{
	MaxRecords:       20,
	MaxEnhanceStones: 25,
	MaxSkillBooks:    5,
	MaxGachaTickets:  3,
}

// 연속 기록 보상
type StreakReward struct {
	Days    int
	Rewards []RewardItem
}

var StreakRewards = []StreakReward{
	{3, []RewardItem{{ItemType: ItemTypeEnhanceStone, Quantity: 5}}},
	{7, []RewardItem{{ItemType: ItemTypeGachaTicket, Quantity: 1}}},
	{14, []RewardItem{{ItemType: ItemTypeAdvancedSkillBook, Quantity: 1}, {ItemType: ItemTypeEnhanceStone, Quantity: 10}}},
	{21, []RewardItem{{ItemType: ItemTypePremiumTicket, Quantity: 1}}},
	{30, []RewardItem{{ItemType: ItemTypeAwakeningStone, Quantity: 1}, {ItemType: ItemTypeGachaTicket, Quantity: 3}}},
	{60, []RewardItem{{ItemType: ItemTypeRareSkillBook, Quantity: 1}, {ItemType: ItemTypeAwakeningStone, Quantity: 2}}},
	{100, []RewardItem{{ItemType: ItemTypePremiumTicket, Quantity: 5}, {ItemType: ItemTypeAwakeningStone, Quantity: 3}}},
}
