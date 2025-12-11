package models

import (
	"time"
)

type AchievementCategory string

const (
	AchievementCategoryRecord    AchievementCategory = "record"
	AchievementCategoryHero      AchievementCategory = "hero"
	AchievementCategoryChallenge AchievementCategory = "challenge"
	AchievementCategorySaving    AchievementCategory = "saving"
	AchievementCategoryCollection AchievementCategory = "collection"
)

type Achievement struct {
	ID          uint                `json:"id" gorm:"primaryKey"`
	Name        string              `json:"name" gorm:"not null"`
	Description string              `json:"description"`
	Category    AchievementCategory `json:"category" gorm:"not null"`
	Icon        string              `json:"icon"`

	// Condition
	ConditionType  string `json:"condition_type"`  // total_records, streak_days, hero_level, etc.
	ConditionValue int64  `json:"condition_value"`

	// Rewards (JSON)
	RewardItems string `json:"reward_items" gorm:"type:text"`

	// Tier (for progressive achievements)
	Tier int `json:"tier" gorm:"default:1"`

	IsHidden  bool      `json:"is_hidden" gorm:"default:false"`
	CreatedAt time.Time `json:"created_at"`
}

type UserAchievement struct {
	ID            uint       `json:"id" gorm:"primaryKey"`
	UserID        uint       `json:"user_id" gorm:"index;not null"`
	AchievementID uint       `json:"achievement_id" gorm:"index;not null"`
	Progress      int64      `json:"progress" gorm:"default:0"`
	UnlockedAt    *time.Time `json:"unlocked_at,omitempty"`
	ClaimedAt     *time.Time `json:"claimed_at,omitempty"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`

	// Relations
	User        *User        `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Achievement *Achievement `json:"achievement,omitempty" gorm:"foreignKey:AchievementID"`
}

type AchievementResponse struct {
	Achievement
	Progress   int64   `json:"progress"`
	IsUnlocked bool    `json:"is_unlocked"`
	IsClaimed  bool    `json:"is_claimed"`
	ProgressPct float64 `json:"progress_pct"`
}

// 업적 정의
var Achievements = []Achievement{
	// 기록 관련
	{Name: "첫 기록", Description: "첫 거래 기록을 남기세요", Category: AchievementCategoryRecord,
		ConditionType: "total_records", ConditionValue: 1, Tier: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":5}]`},
	{Name: "기록의 시작", Description: "거래 10건 기록", Category: AchievementCategoryRecord,
		ConditionType: "total_records", ConditionValue: 10, Tier: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":10}]`},
	{Name: "성실한 기록자", Description: "거래 100건 기록", Category: AchievementCategoryRecord,
		ConditionType: "total_records", ConditionValue: 100, Tier: 2,
		RewardItems: `[{"item_type":"gacha_ticket","quantity":2}]`},
	{Name: "기록의 달인", Description: "거래 1,000건 기록", Category: AchievementCategoryRecord,
		ConditionType: "total_records", ConditionValue: 1000, Tier: 3,
		RewardItems: `[{"item_type":"premium_ticket","quantity":3}]`},
	{Name: "기록의 전설", Description: "거래 10,000건 기록", Category: AchievementCategoryRecord,
		ConditionType: "total_records", ConditionValue: 10000, Tier: 4,
		RewardItems: `[{"item_type":"awakening_stone","quantity":5}]`},

	// 연속 기록
	{Name: "3일 연속", Description: "3일 연속 기록", Category: AchievementCategoryRecord,
		ConditionType: "streak_days", ConditionValue: 3, Tier: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":5}]`},
	{Name: "1주일 연속", Description: "7일 연속 기록", Category: AchievementCategoryRecord,
		ConditionType: "streak_days", ConditionValue: 7, Tier: 1,
		RewardItems: `[{"item_type":"gacha_ticket","quantity":1}]`},
	{Name: "한 달 연속", Description: "30일 연속 기록", Category: AchievementCategoryRecord,
		ConditionType: "streak_days", ConditionValue: 30, Tier: 2,
		RewardItems: `[{"item_type":"awakening_stone","quantity":1}]`},
	{Name: "100일의 기적", Description: "100일 연속 기록", Category: AchievementCategoryRecord,
		ConditionType: "streak_days", ConditionValue: 100, Tier: 3,
		RewardItems: `[{"item_type":"premium_ticket","quantity":5}]`},
	{Name: "365일의 전설", Description: "1년 연속 기록", Category: AchievementCategoryRecord,
		ConditionType: "streak_days", ConditionValue: 365, Tier: 4,
		RewardItems: `[{"item_type":"awakening_stone","quantity":10}]`},

	// 히어로 관련
	{Name: "모험의 시작", Description: "레벨 10 달성", Category: AchievementCategoryHero,
		ConditionType: "hero_level", ConditionValue: 10, Tier: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":10}]`},
	{Name: "성장하는 영웅", Description: "레벨 30 달성", Category: AchievementCategoryHero,
		ConditionType: "hero_level", ConditionValue: 30, Tier: 2,
		RewardItems: `[{"item_type":"gacha_ticket","quantity":3}]`},
	{Name: "숙련된 영웅", Description: "레벨 50 달성", Category: AchievementCategoryHero,
		ConditionType: "hero_level", ConditionValue: 50, Tier: 3,
		RewardItems: `[{"item_type":"premium_ticket","quantity":2}]`},
	{Name: "전설적 영웅", Description: "레벨 100 달성", Category: AchievementCategoryHero,
		ConditionType: "hero_level", ConditionValue: 100, Tier: 4,
		RewardItems: `[{"item_type":"awakening_stone","quantity":5}]`},

	// 챌린지 관련
	{Name: "첫 챌린지", Description: "챌린지 1회 완료", Category: AchievementCategoryChallenge,
		ConditionType: "challenge_completed", ConditionValue: 1, Tier: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":5}]`},
	{Name: "챌린지 도전자", Description: "챌린지 10회 완료", Category: AchievementCategoryChallenge,
		ConditionType: "challenge_completed", ConditionValue: 10, Tier: 2,
		RewardItems: `[{"item_type":"gacha_ticket","quantity":2}]`},
	{Name: "챌린지 마스터", Description: "챌린지 50회 완료", Category: AchievementCategoryChallenge,
		ConditionType: "challenge_completed", ConditionValue: 50, Tier: 3,
		RewardItems: `[{"item_type":"premium_ticket","quantity":3}]`},

	// 저축 관련
	{Name: "첫 저축", Description: "첫 저축 기록", Category: AchievementCategorySaving,
		ConditionType: "total_savings", ConditionValue: 1, Tier: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":5}]`},
	{Name: "10만원 저축", Description: "총 저축액 10만원 달성", Category: AchievementCategorySaving,
		ConditionType: "total_savings_amount", ConditionValue: 100000, Tier: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":10}]`},
	{Name: "100만원 저축", Description: "총 저축액 100만원 달성", Category: AchievementCategorySaving,
		ConditionType: "total_savings_amount", ConditionValue: 1000000, Tier: 2,
		RewardItems: `[{"item_type":"gacha_ticket","quantity":3}]`},
	{Name: "1000만원 저축", Description: "총 저축액 1000만원 달성", Category: AchievementCategorySaving,
		ConditionType: "total_savings_amount", ConditionValue: 10000000, Tier: 3,
		RewardItems: `[{"item_type":"awakening_stone","quantity":3}]`},

	// 컬렉션 관련
	{Name: "첫 장비", Description: "첫 장비 획득", Category: AchievementCategoryCollection,
		ConditionType: "equipment_count", ConditionValue: 1, Tier: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":3}]`},
	{Name: "희귀 장비", Description: "희귀 등급 장비 획득", Category: AchievementCategoryCollection,
		ConditionType: "rare_equipment", ConditionValue: 1, Tier: 2,
		RewardItems: `[{"item_type":"enhance_stone","quantity":10}]`},
	{Name: "전설의 무기", Description: "전설 등급 장비 획득", Category: AchievementCategoryCollection,
		ConditionType: "legendary_equipment", ConditionValue: 1, Tier: 3,
		RewardItems: `[{"item_type":"premium_ticket","quantity":2}]`},
}
