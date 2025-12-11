package models

import (
	"time"
)

type SkillType string
type SkillCategory string

const (
	SkillTypeActive  SkillType = "active"
	SkillTypePassive SkillType = "passive"
)

const (
	SkillCategoryCommon   SkillCategory = "common"   // 공용 스킬
	SkillCategoryEquipment SkillCategory = "equipment" // 장비 스킬
)

type Skill struct {
	ID          uint          `json:"id" gorm:"primaryKey"`
	Name        string        `json:"name" gorm:"not null"`
	Description string        `json:"description"`
	Type        SkillType     `json:"type" gorm:"not null"`
	Category    SkillCategory `json:"category" gorm:"not null"`

	// For common skills
	SkillBookGrade string `json:"skill_book_grade,omitempty"` // normal, advanced, rare

	// Resource cost
	MPCost   int `json:"mp_cost"`
	Cooldown int `json:"cooldown"` // seconds

	// Effect (JSON)
	Effect string `json:"effect" gorm:"type:text"` // JSON

	CreatedAt time.Time `json:"created_at"`
}

type HeroSkill struct {
	ID       uint `json:"id" gorm:"primaryKey"`
	HeroID   uint `json:"hero_id" gorm:"index;not null"`
	SkillID  uint `json:"skill_id" gorm:"index;not null"`
	Level    int  `json:"level" gorm:"default:1"`
	SlotNum  int  `json:"slot_num,omitempty"` // 0 = not equipped, 1-2 = slot number

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Relations
	Hero  *Hero  `json:"hero,omitempty" gorm:"foreignKey:HeroID"`
	Skill *Skill `json:"skill,omitempty" gorm:"foreignKey:SkillID"`
}

type SkillEffect struct {
	Type       string  `json:"type"`       // damage, heal, buff, debuff
	Stat       string  `json:"stat"`       // atk, def, hp, etc.
	ValueType  string  `json:"value_type"` // flat, percent
	Value      float64 `json:"value"`
	Duration   int     `json:"duration,omitempty"`   // seconds, for buffs
	TargetType string  `json:"target_type,omitempty"` // self, enemy, all_enemies
}

// 공용 스킬 목록
var CommonSkills = []Skill{
	// 일반 스킬북
	{Name: "집중", Description: "10초간 크리티컬 +20%", Type: SkillTypeActive, Category: SkillCategoryCommon,
		SkillBookGrade: "normal", MPCost: 15, Cooldown: 30,
		Effect: `{"type":"buff","stat":"crit","value_type":"percent","value":20,"duration":10}`},
	{Name: "응급 치료", Description: "HP 25% 회복", Type: SkillTypeActive, Category: SkillCategoryCommon,
		SkillBookGrade: "normal", MPCost: 25, Cooldown: 45,
		Effect: `{"type":"heal","stat":"hp","value_type":"percent","value":25}`},
	{Name: "회피 기동", Description: "다음 공격 회피", Type: SkillTypeActive, Category: SkillCategoryCommon,
		SkillBookGrade: "normal", MPCost: 20, Cooldown: 60,
		Effect: `{"type":"buff","stat":"dodge","value_type":"flat","value":1,"duration":5}`},

	// 고급 스킬북
	{Name: "전투 함성", Description: "30초간 ATK +20%", Type: SkillTypeActive, Category: SkillCategoryCommon,
		SkillBookGrade: "advanced", MPCost: 30, Cooldown: 90,
		Effect: `{"type":"buff","stat":"atk","value_type":"percent","value":20,"duration":30}`},
	{Name: "마력 충전", Description: "MP 30% 회복", Type: SkillTypeActive, Category: SkillCategoryCommon,
		SkillBookGrade: "advanced", MPCost: 0, Cooldown: 60,
		Effect: `{"type":"heal","stat":"mp","value_type":"percent","value":30}`},
	{Name: "철벽 방어", Description: "5초간 피해 80% 감소", Type: SkillTypeActive, Category: SkillCategoryCommon,
		SkillBookGrade: "advanced", MPCost: 40, Cooldown: 120,
		Effect: `{"type":"buff","stat":"damage_reduction","value_type":"percent","value":80,"duration":5}`},

	// 희귀 스킬북
	{Name: "광폭화", Description: "30초간 ATK +40%, DEF -20%", Type: SkillTypeActive, Category: SkillCategoryCommon,
		SkillBookGrade: "rare", MPCost: 50, Cooldown: 180,
		Effect: `{"type":"buff","stat":"atk","value_type":"percent","value":40,"duration":30,"side_effect":{"stat":"def","value":-20}}`},
	{Name: "생명력 폭발", Description: "HP 50% 회복 + 10초간 회복량 2배", Type: SkillTypeActive, Category: SkillCategoryCommon,
		SkillBookGrade: "rare", MPCost: 60, Cooldown: 240,
		Effect: `{"type":"heal","stat":"hp","value_type":"percent","value":50,"buff":{"stat":"healing","value":100,"duration":10}}`},
	{Name: "시간 가속", Description: "20초간 쿨타임 50% 감소", Type: SkillTypeActive, Category: SkillCategoryCommon,
		SkillBookGrade: "rare", MPCost: 70, Cooldown: 300,
		Effect: `{"type":"buff","stat":"cooldown_reduction","value_type":"percent","value":50,"duration":20}`},
}

// 스킬 강화 필요 스킬북
var SkillUpgradeCost = map[int]int{
	1: 1, // 레벨 1 -> 2
	2: 2,
	3: 4,
	4: 8,
	5: 16, // 레벨 5 (최대)
}

// 스킬 레벨별 효과 증가
var SkillLevelBonus = map[int]float64{
	1: 1.0,
	2: 1.1,
	3: 1.2,
	4: 1.35,
	5: 1.5,
}

type EquipSkillRequest struct {
	SkillID uint `json:"skill_id" binding:"required"`
	SlotNum int  `json:"slot_num" binding:"required,min=1,max=2"`
}

type LearnSkillRequest struct {
	SkillBookGrade string `json:"skill_book_grade" binding:"required,oneof=normal advanced rare"`
}

type SkillListResponse struct {
	LearnedSkills []HeroSkill `json:"learned_skills"`
	AvailableSlots int       `json:"available_slots"`
	EquippedSkills []HeroSkill `json:"equipped_skills"`
}
