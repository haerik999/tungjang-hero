package models

import (
	"time"
)

type ChallengeType string
type ChallengeDuration string
type ChallengeStatus string
type ChallengeTargetType string

const (
	ChallengeTypeSolo      ChallengeType = "solo"
	ChallengeTypeCommunity ChallengeType = "community"
)

const (
	ChallengeDuration1Day   ChallengeDuration = "1d"
	ChallengeDuration3Days  ChallengeDuration = "3d"
	ChallengeDuration7Days  ChallengeDuration = "7d"
	ChallengeDuration14Days ChallengeDuration = "14d"
	ChallengeDuration30Days ChallengeDuration = "30d"
)

const (
	ChallengeStatusWaiting   ChallengeStatus = "waiting"
	ChallengeStatusActive    ChallengeStatus = "active"
	ChallengeStatusCompleted ChallengeStatus = "completed"
	ChallengeStatusFailed    ChallengeStatus = "failed"
)

const (
	TargetAmountUnder ChallengeTargetType = "amount_under"
	TargetCountUnder  ChallengeTargetType = "count_under"
	TargetZero        ChallengeTargetType = "zero"
)

type Challenge struct {
	ID          uint              `json:"id" gorm:"primaryKey"`
	Type        ChallengeType     `json:"type" gorm:"not null"`
	Title       string            `json:"title" gorm:"not null"`
	Description string            `json:"description"`
	Category    string            `json:"category,omitempty"` // null = all categories

	// Target
	TargetType  ChallengeTargetType `json:"target_type" gorm:"not null"`
	TargetValue int64               `json:"target_value"`

	// Duration
	Duration  ChallengeDuration `json:"duration" gorm:"not null"`
	StartDate time.Time         `json:"start_date"`
	EndDate   time.Time         `json:"end_date"`

	// Community specific
	CreatorID       *uint `json:"creator_id,omitempty"`
	MaxParticipants int   `json:"max_participants,omitempty"`
	MinParticipants int   `json:"min_participants,omitempty" gorm:"default:2"`

	// Rewards (JSON)
	RewardItems string `json:"reward_items" gorm:"type:text"`

	Status    ChallengeStatus `json:"status" gorm:"default:waiting"`
	CreatedAt time.Time       `json:"created_at"`
	UpdatedAt time.Time       `json:"updated_at"`

	// Relations
	Creator       *User                    `json:"creator,omitempty" gorm:"foreignKey:CreatorID"`
	Participants  []ChallengeParticipation `json:"participants,omitempty" gorm:"foreignKey:ChallengeID"`
}

type ChallengeParticipation struct {
	ID           uint            `json:"id" gorm:"primaryKey"`
	ChallengeID  uint            `json:"challenge_id" gorm:"index;not null"`
	UserID       uint            `json:"user_id" gorm:"index;not null"`
	CurrentValue int64           `json:"current_value" gorm:"default:0"`
	IsCompleted  bool            `json:"is_completed" gorm:"default:false"`
	RewardClaimed bool           `json:"reward_claimed" gorm:"default:false"`
	JoinedAt     time.Time       `json:"joined_at"`
	CompletedAt  *time.Time      `json:"completed_at,omitempty"`

	// Relations
	Challenge *Challenge `json:"challenge,omitempty" gorm:"foreignKey:ChallengeID"`
	User      *User      `json:"user,omitempty" gorm:"foreignKey:UserID"`
}

type ChallengeCreateRequest struct {
	Title           string              `json:"title" binding:"required,min=2,max=50"`
	Description     string              `json:"description"`
	Category        string              `json:"category"`
	TargetType      ChallengeTargetType `json:"target_type" binding:"required"`
	TargetValue     int64               `json:"target_value" binding:"required"`
	Duration        ChallengeDuration   `json:"duration" binding:"required"`
	MaxParticipants int                 `json:"max_participants" binding:"min=2,max=50"`
}

type ChallengeListRequest struct {
	Type     string `form:"type"` // solo, community
	Status   string `form:"status"`
	Category string `form:"category"`
	Page     int    `form:"page,default=1"`
	Limit    int    `form:"limit,default=20"`
}

type ChallengeResponse struct {
	Challenge
	ParticipantCount int     `json:"participant_count"`
	CompletionRate   float64 `json:"completion_rate"`
	UserProgress     *int64  `json:"user_progress,omitempty"`
	UserCompleted    *bool   `json:"user_completed,omitempty"`
}

// 솔로 챌린지 풀
var SoloDailyChallenges = []Challenge{
	{Type: ChallengeTypeSolo, Title: "오늘 커피 안 사먹기", Category: "cafe",
		TargetType: TargetZero, TargetValue: 0, Duration: ChallengeDuration1Day,
		RewardItems: `[{"item_type":"enhance_stone","quantity":5}]`},
	{Type: ChallengeTypeSolo, Title: "점심 만원 이하", Category: "food",
		TargetType: TargetAmountUnder, TargetValue: 10000, Duration: ChallengeDuration1Day,
		RewardItems: `[{"item_type":"enhance_stone","quantity":3}]`},
	{Type: ChallengeTypeSolo, Title: "교통비 절약", Category: "transport",
		TargetType: TargetAmountUnder, TargetValue: 5000, Duration: ChallengeDuration1Day,
		RewardItems: `[{"item_type":"enhance_stone","quantity":3}]`},
	{Type: ChallengeTypeSolo, Title: "무지출 도전",
		TargetType: TargetZero, TargetValue: 0, Duration: ChallengeDuration1Day,
		RewardItems: `[{"item_type":"enhance_stone","quantity":10},{"item_type":"skill_book","quantity":1}]`},
}

var SoloWeeklyChallenges = []Challenge{
	{Type: ChallengeTypeSolo, Title: "식비 15만원 이하", Category: "food",
		TargetType: TargetAmountUnder, TargetValue: 150000, Duration: ChallengeDuration7Days,
		RewardItems: `[{"item_type":"enhance_stone","quantity":20},{"item_type":"skill_book","quantity":1}]`},
	{Type: ChallengeTypeSolo, Title: "배달 3회 이하", Category: "food",
		TargetType: TargetCountUnder, TargetValue: 3, Duration: ChallengeDuration7Days,
		RewardItems: `[{"item_type":"enhance_stone","quantity":15}]`},
	{Type: ChallengeTypeSolo, Title: "쇼핑 5만원 이하", Category: "shopping",
		TargetType: TargetAmountUnder, TargetValue: 50000, Duration: ChallengeDuration7Days,
		RewardItems: `[{"item_type":"enhance_stone","quantity":15},{"item_type":"gacha_ticket","quantity":1}]`},
}

// 커뮤니티 챌린지 기본 보상
var CommunityRewardByDuration = map[ChallengeDuration]string{
	ChallengeDuration1Day:   `[{"item_type":"enhance_stone","quantity":5}]`,
	ChallengeDuration3Days:  `[{"item_type":"enhance_stone","quantity":10}]`,
	ChallengeDuration7Days:  `[{"item_type":"enhance_stone","quantity":20}]`,
	ChallengeDuration14Days: `[{"item_type":"enhance_stone","quantity":40},{"item_type":"skill_book","quantity":1}]`,
	ChallengeDuration30Days: `[{"item_type":"enhance_stone","quantity":75},{"item_type":"awakening_stone","quantity":1}]`,
}
