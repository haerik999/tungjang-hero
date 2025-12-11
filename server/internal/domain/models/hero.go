package models

import (
	"time"
)

type Hero struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id" gorm:"uniqueIndex;not null"`
	Name      string    `json:"name" gorm:"not null"`
	Level     int       `json:"level" gorm:"default:1"`
	Exp       int64     `json:"exp" gorm:"default:0"`
	Gold      int64     `json:"gold" gorm:"default:0"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Base Stats
	HP  int `json:"hp" gorm:"default:100"`
	MP  int `json:"mp" gorm:"default:50"`
	ATK int `json:"atk" gorm:"default:10"`
	DEF int `json:"def" gorm:"default:5"`
	MAG int `json:"mag" gorm:"default:10"`
	MDF int `json:"mdf" gorm:"default:5"`
	SPD int `json:"spd" gorm:"default:10"`
	LUK int `json:"luk" gorm:"default:5"`

	// Stat Points
	StatPoints      int `json:"stat_points" gorm:"default:0"`
	AllocatedHP     int `json:"allocated_hp" gorm:"default:0"`
	AllocatedMP     int `json:"allocated_mp" gorm:"default:0"`
	AllocatedATK    int `json:"allocated_atk" gorm:"default:0"`
	AllocatedDEF    int `json:"allocated_def" gorm:"default:0"`
	AllocatedMAG    int `json:"allocated_mag" gorm:"default:0"`
	AllocatedMDF    int `json:"allocated_mdf" gorm:"default:0"`
	AllocatedSPD    int `json:"allocated_spd" gorm:"default:0"`
	AllocatedLUK    int `json:"allocated_luk" gorm:"default:0"`

	// Hunting
	CurrentStageID   int       `json:"current_stage_id" gorm:"default:1"`
	LastHuntingTime  time.Time `json:"last_hunting_time"`
	OfflineGold      int64     `json:"offline_gold" gorm:"default:0"`
	OfflineExp       int64     `json:"offline_exp" gorm:"default:0"`

	// Streak
	RecordStreak     int        `json:"record_streak" gorm:"default:0"`
	LastRecordDate   *time.Time `json:"last_record_date"`
	StreakProtection int        `json:"streak_protection" gorm:"default:0"`

	// Relations
	User       *User       `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Equipments []Equipment `json:"equipments,omitempty" gorm:"foreignKey:HeroID"`
	Inventory  []Item      `json:"inventory,omitempty" gorm:"foreignKey:HeroID"`
	Skills     []HeroSkill `json:"skills,omitempty" gorm:"foreignKey:HeroID"`
	Presets    []Preset    `json:"presets,omitempty" gorm:"foreignKey:HeroID"`
}

// 총 스탯 계산 (기본 + 레벨업 + 배분)
func (h *Hero) TotalHP() int {
	return h.HP + (h.Level-1)*15 + h.AllocatedHP*30
}

func (h *Hero) TotalMP() int {
	return h.MP + (h.Level-1)*8 + h.AllocatedMP*15
}

func (h *Hero) TotalATK() int {
	return h.ATK + h.AllocatedATK*3
}

func (h *Hero) TotalDEF() int {
	return h.DEF + h.AllocatedDEF*2
}

func (h *Hero) TotalMAG() int {
	return h.MAG + h.AllocatedMAG*3
}

func (h *Hero) TotalMDF() int {
	return h.MDF + h.AllocatedMDF*2
}

func (h *Hero) TotalSPD() int {
	return h.SPD + h.AllocatedSPD*2
}

func (h *Hero) TotalLUK() int {
	return h.LUK + h.AllocatedLUK*1
}

// 레벨업에 필요한 경험치: 100 * Level^1.8
func (h *Hero) ExpToNextLevel() int64 {
	return int64(100 * float64(h.Level) * float64(h.Level) * 0.8)
}

type HeroCreateRequest struct {
	Name      string `json:"name" binding:"required,min=2,max=12"`
	BuildType string `json:"build_type" binding:"required,oneof=physical magic tank balance"`
}

type HeroStatsResponse struct {
	Hero
	TotalHP  int   `json:"total_hp"`
	TotalMP  int   `json:"total_mp"`
	TotalATK int   `json:"total_atk"`
	TotalDEF int   `json:"total_def"`
	TotalMAG int   `json:"total_mag"`
	TotalMDF int   `json:"total_mdf"`
	TotalSPD int   `json:"total_spd"`
	TotalLUK int   `json:"total_luk"`
	ExpToNext int64 `json:"exp_to_next"`
}

type AllocateStatRequest struct {
	Stat   string `json:"stat" binding:"required,oneof=hp mp atk def mag mdf spd luk"`
	Points int    `json:"points" binding:"required,min=1"`
}

type HuntingRewardResponse struct {
	Gold       int64       `json:"gold"`
	Exp        int64       `json:"exp"`
	LeveledUp  bool        `json:"leveled_up"`
	NewLevel   int         `json:"new_level,omitempty"`
	DroppedItems []Item    `json:"dropped_items,omitempty"`
}
