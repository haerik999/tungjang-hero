package models

import (
	"time"
)

type EquipmentSlot string
type EquipmentGrade string
type WeaponType string

const (
	SlotWeapon   EquipmentSlot = "weapon"
	SlotArmor    EquipmentSlot = "armor"
	SlotHelmet   EquipmentSlot = "helmet"
	SlotGloves   EquipmentSlot = "gloves"
	SlotBoots    EquipmentSlot = "boots"
	SlotRing     EquipmentSlot = "ring"
	SlotNecklace EquipmentSlot = "necklace"
)

const (
	GradeNormal    EquipmentGrade = "normal"    // 일반 (흰색)
	GradeUncommon  EquipmentGrade = "uncommon"  // 고급 (초록)
	GradeRare      EquipmentGrade = "rare"      // 희귀 (파랑)
	GradeEpic      EquipmentGrade = "epic"      // 영웅 (보라)
	GradeLegendary EquipmentGrade = "legendary" // 전설 (주황)
	GradeMythic    EquipmentGrade = "mythic"    // 신화 (빨강)
)

const (
	WeaponSword      WeaponType = "sword"
	WeaponGreatsword WeaponType = "greatsword"
	WeaponDagger     WeaponType = "dagger"
	WeaponStaff      WeaponType = "staff"
	WeaponWand       WeaponType = "wand"
	WeaponMace       WeaponType = "mace"
	WeaponBow        WeaponType = "bow"
)

// 장비 등급별 스탯 배율
var GradeMultiplier = map[EquipmentGrade]float64{
	GradeNormal:    1.0,
	GradeUncommon:  1.3,
	GradeRare:      1.7,
	GradeEpic:      2.2,
	GradeLegendary: 3.0,
	GradeMythic:    4.0,
}

// 장비 등급별 추가 옵션 개수
var GradeOptionCount = map[EquipmentGrade]int{
	GradeNormal:    0,
	GradeUncommon:  1,
	GradeRare:      2,
	GradeEpic:      3,
	GradeLegendary: 4,
	GradeMythic:    5,
}

type EquipmentTemplate struct {
	ID          uint           `json:"id" gorm:"primaryKey"`
	Name        string         `json:"name" gorm:"not null"`
	Slot        EquipmentSlot  `json:"slot" gorm:"not null"`
	Grade       EquipmentGrade `json:"grade" gorm:"not null"`
	WeaponType  WeaponType     `json:"weapon_type,omitempty"`
	RequiredLvl int            `json:"required_lvl" gorm:"default:1"`

	// Base Stats
	BaseATK int `json:"base_atk"`
	BaseDEF int `json:"base_def"`
	BaseMAG int `json:"base_mag"`
	BaseMDF int `json:"base_mdf"`
	BaseHP  int `json:"base_hp"`
	BaseMP  int `json:"base_mp"`
	BaseSPD int `json:"base_spd"`
	BaseLUK int `json:"base_luk"`

	// Skill (for weapons and armor)
	SkillName   string `json:"skill_name,omitempty"`
	SkillDesc   string `json:"skill_desc,omitempty"`
	SkillEffect string `json:"skill_effect,omitempty"` // JSON

	// Drop info
	DropStageMin int     `json:"drop_stage_min"`
	DropStageMax int     `json:"drop_stage_max"`
	DropRate     float64 `json:"drop_rate"`

	CreatedAt time.Time `json:"created_at"`
}

type Equipment struct {
	ID         uint           `json:"id" gorm:"primaryKey"`
	HeroID     uint           `json:"hero_id" gorm:"index;not null"`
	TemplateID uint           `json:"template_id" gorm:"not null"`
	Slot       EquipmentSlot  `json:"slot" gorm:"not null"`
	Grade      EquipmentGrade `json:"grade" gorm:"not null"`

	// Enhancement
	EnhanceLevel int `json:"enhance_level" gorm:"default:0"`

	// Awakening
	AwakeningLevel int `json:"awakening_level" gorm:"default:0"`

	// Final Stats (after grade multiplier)
	ATK int `json:"atk"`
	DEF int `json:"def"`
	MAG int `json:"mag"`
	MDF int `json:"mdf"`
	HP  int `json:"hp"`
	MP  int `json:"mp"`
	SPD int `json:"spd"`
	LUK int `json:"luk"`

	// Extra Options (JSON)
	ExtraOptions string `json:"extra_options" gorm:"type:text"` // JSON array

	// Equipped status
	IsEquipped bool      `json:"is_equipped" gorm:"default:false"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`

	// Relations
	Hero     *Hero              `json:"hero,omitempty" gorm:"foreignKey:HeroID"`
	Template *EquipmentTemplate `json:"template,omitempty" gorm:"foreignKey:TemplateID"`
}

type ExtraOption struct {
	Stat  string  `json:"stat"`  // atk, def, mag, etc.
	Type  string  `json:"type"`  // flat or percent
	Value float64 `json:"value"`
}

type EquipRequest struct {
	EquipmentID uint `json:"equipment_id" binding:"required"`
}

type EnhanceRequest struct {
	EquipmentID uint `json:"equipment_id" binding:"required"`
}

type EnhanceResult struct {
	Success      bool       `json:"success"`
	NewLevel     int        `json:"new_level"`
	Equipment    *Equipment `json:"equipment"`
	StonesUsed   int        `json:"stones_used"`
	StonesRemain int        `json:"stones_remain"`
}

// 강화 확률 (레벨별)
var EnhanceSuccessRate = map[int]float64{
	0: 1.0, 1: 1.0, 2: 1.0, 3: 0.9, 4: 0.8,
	5: 0.7, 6: 0.5, 7: 0.3, 8: 0.2, 9: 0.1,
	10: 0.05,
}

// 강화 필요 강화석 (레벨별)
var EnhanceStoneCost = map[int]int{
	0: 1, 1: 1, 2: 2, 3: 3, 4: 4,
	5: 5, 6: 7, 7: 10, 8: 15, 9: 20,
}
