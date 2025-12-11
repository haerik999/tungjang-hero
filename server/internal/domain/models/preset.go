package models

import (
	"time"
)

type Preset struct {
	ID     uint   `json:"id" gorm:"primaryKey"`
	HeroID uint   `json:"hero_id" gorm:"index;not null"`
	Name   string `json:"name" gorm:"not null"`
	Icon   string `json:"icon,omitempty"`

	// Stat allocation
	AllocatedHP  int `json:"allocated_hp"`
	AllocatedMP  int `json:"allocated_mp"`
	AllocatedATK int `json:"allocated_atk"`
	AllocatedDEF int `json:"allocated_def"`
	AllocatedMAG int `json:"allocated_mag"`
	AllocatedMDF int `json:"allocated_mdf"`
	AllocatedSPD int `json:"allocated_spd"`
	AllocatedLUK int `json:"allocated_luk"`

	// Skill slots (skill IDs)
	Skill1ID *uint `json:"skill_1_id,omitempty"`
	Skill2ID *uint `json:"skill_2_id,omitempty"`

	IsActive  bool      `json:"is_active" gorm:"default:false"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Relations
	Hero *Hero `json:"hero,omitempty" gorm:"foreignKey:HeroID"`
}

type PresetCreateRequest struct {
	Name string `json:"name" binding:"required,min=1,max=20"`
	Icon string `json:"icon"`
}

type PresetUpdateRequest struct {
	Name         string `json:"name" binding:"omitempty,min=1,max=20"`
	Icon         string `json:"icon"`
	AllocatedHP  int    `json:"allocated_hp"`
	AllocatedMP  int    `json:"allocated_mp"`
	AllocatedATK int    `json:"allocated_atk"`
	AllocatedDEF int    `json:"allocated_def"`
	AllocatedMAG int    `json:"allocated_mag"`
	AllocatedMDF int    `json:"allocated_mdf"`
	AllocatedSPD int    `json:"allocated_spd"`
	AllocatedLUK int    `json:"allocated_luk"`
	Skill1ID     *uint  `json:"skill_1_id"`
	Skill2ID     *uint  `json:"skill_2_id"`
}

type PresetSwitchRequest struct {
	PresetID uint `json:"preset_id" binding:"required"`
}

// 기본 프리셋 템플릿
var DefaultPresets = []Preset{
	{Name: "물리형", Icon: "⚔️"},
	{Name: "마법형", Icon: "🔮"},
	{Name: "밸런스", Icon: "⚖️"},
}

const MaxFreePresets = 3
const MaxPremiumPresets = 5
