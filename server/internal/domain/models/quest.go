package models

import (
	"time"
)

type QuestType string
type QuestPeriod string
type QuestStatus string

const (
	QuestTypeRecord    QuestType = "record"     // 기록 관련
	QuestTypeReceipt   QuestType = "receipt"    // 영수증 인증
	QuestTypeSpending  QuestType = "spending"   // 지출 관련
	QuestTypeSaving    QuestType = "saving"     // 저축 관련
	QuestTypeBudget    QuestType = "budget"     // 예산 관련
)

const (
	QuestPeriodDaily   QuestPeriod = "daily"
	QuestPeriodWeekly  QuestPeriod = "weekly"
	QuestPeriodMonthly QuestPeriod = "monthly"
)

const (
	QuestStatusActive    QuestStatus = "active"
	QuestStatusCompleted QuestStatus = "completed"
	QuestStatusFailed    QuestStatus = "failed"
	QuestStatusClaimed   QuestStatus = "claimed"
)

type Quest struct {
	ID          uint        `json:"id" gorm:"primaryKey"`
	Title       string      `json:"title" gorm:"not null"`
	Description string      `json:"description"`
	Type        QuestType   `json:"type" gorm:"not null"`
	Period      QuestPeriod `json:"period" gorm:"not null"`

	// Condition
	TargetType  string `json:"target_type"`  // record_count, receipt_count, spending_under, etc.
	TargetValue int64  `json:"target_value"` // 목표 값
	Category    string `json:"category,omitempty"` // 특정 카테고리 (optional)

	// Rewards (JSON stored)
	RewardItems string `json:"reward_items" gorm:"type:text"` // JSON array of RewardItem

	IsActive  bool      `json:"is_active" gorm:"default:true"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type UserQuest struct {
	ID          uint        `json:"id" gorm:"primaryKey"`
	UserID      uint        `json:"user_id" gorm:"index;not null"`
	QuestID     uint        `json:"quest_id" gorm:"index;not null"`
	Status      QuestStatus `json:"status" gorm:"default:active"`
	Progress    int64       `json:"progress" gorm:"default:0"`
	StartDate   time.Time   `json:"start_date"`
	EndDate     time.Time   `json:"end_date"`
	CompletedAt *time.Time  `json:"completed_at,omitempty"`
	ClaimedAt   *time.Time  `json:"claimed_at,omitempty"`
	CreatedAt   time.Time   `json:"created_at"`
	UpdatedAt   time.Time   `json:"updated_at"`

	// Relations
	User  *User  `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Quest *Quest `json:"quest,omitempty" gorm:"foreignKey:QuestID"`
}

type UserQuestResponse struct {
	UserQuest
	Quest       Quest   `json:"quest"`
	ProgressPct float64 `json:"progress_pct"`
}

// 기본 퀘스트 정의
var DailyQuests = []Quest{
	{
		Title:       "오늘의 기록",
		Description: "거래 1건 기록",
		Type:        QuestTypeRecord,
		Period:      QuestPeriodDaily,
		TargetType:  "record_count",
		TargetValue: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":3}]`,
	},
	{
		Title:       "성실한 기록",
		Description: "거래 5건 기록",
		Type:        QuestTypeRecord,
		Period:      QuestPeriodDaily,
		TargetType:  "record_count",
		TargetValue: 5,
		RewardItems: `[{"item_type":"enhance_stone","quantity":5},{"item_type":"skill_book","quantity":1}]`,
	},
	{
		Title:       "인증왕",
		Description: "영수증 인증 3건",
		Type:        QuestTypeReceipt,
		Period:      QuestPeriodDaily,
		TargetType:  "receipt_count",
		TargetValue: 3,
		RewardItems: `[{"item_type":"gacha_ticket","quantity":1},{"item_type":"advanced_stone","quantity":2}]`,
	},
	{
		Title:       "알뜰한 하루",
		Description: "일일 지출 3만원 이하",
		Type:        QuestTypeSpending,
		Period:      QuestPeriodDaily,
		TargetType:  "spending_under",
		TargetValue: 30000,
		RewardItems: `[{"item_type":"enhance_stone","quantity":5}]`,
	},
	{
		Title:       "무지출 도전",
		Description: "오늘 지출 0원",
		Type:        QuestTypeSpending,
		Period:      QuestPeriodDaily,
		TargetType:  "spending_zero",
		TargetValue: 0,
		RewardItems: `[{"item_type":"premium_ticket","quantity":1}]`,
	},
	{
		Title:       "저축 기록",
		Description: "수입 기록 1건",
		Type:        QuestTypeSaving,
		Period:      QuestPeriodDaily,
		TargetType:  "income_count",
		TargetValue: 1,
		RewardItems: `[{"item_type":"enhance_stone","quantity":3},{"item_type":"pet_food","quantity":5}]`,
	},
}

var WeeklyQuests = []Quest{
	{
		Title:       "7일 연속 기록",
		Description: "7일 연속 기록 달성",
		Type:        QuestTypeRecord,
		Period:      QuestPeriodWeekly,
		TargetType:  "streak",
		TargetValue: 7,
		RewardItems: `[{"item_type":"gacha_ticket","quantity":3},{"item_type":"advanced_skill_book","quantity":1}]`,
	},
	{
		Title:       "인증 마스터",
		Description: "주간 영수증 인증 20건",
		Type:        QuestTypeReceipt,
		Period:      QuestPeriodWeekly,
		TargetType:  "receipt_count",
		TargetValue: 20,
		RewardItems: `[{"item_type":"premium_ticket","quantity":2},{"item_type":"awakening_stone","quantity":1}]`,
	},
	{
		Title:       "예산 수호자",
		Description: "주간 예산 준수",
		Type:        QuestTypeBudget,
		Period:      QuestPeriodWeekly,
		TargetType:  "budget_kept",
		TargetValue: 1,
		RewardItems: `[{"item_type":"gacha_ticket","quantity":2},{"item_type":"advanced_stone","quantity":5}]`,
	},
}

var MonthlyQuests = []Quest{
	{
		Title:       "30일 연속 기록",
		Description: "30일 연속 기록 달성",
		Type:        QuestTypeRecord,
		Period:      QuestPeriodMonthly,
		TargetType:  "streak",
		TargetValue: 30,
		RewardItems: `[{"item_type":"awakening_stone","quantity":2},{"item_type":"premium_ticket","quantity":5}]`,
	},
	{
		Title:       "인증 달인",
		Description: "월간 영수증 인증 50건",
		Type:        QuestTypeReceipt,
		Period:      QuestPeriodMonthly,
		TargetType:  "receipt_count",
		TargetValue: 50,
		RewardItems: `[{"item_type":"awakening_stone","quantity":3},{"item_type":"premium_ticket","quantity":3}]`,
	},
}
