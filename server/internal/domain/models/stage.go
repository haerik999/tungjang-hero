package models

type Stage struct {
	ID           uint   `json:"id" gorm:"primaryKey"`
	Chapter      int    `json:"chapter" gorm:"not null"`
	StageNumber  int    `json:"stage_number" gorm:"not null"`
	Name         string `json:"name" gorm:"not null"`
	Description  string `json:"description"`
	RequiredLvl  int    `json:"required_lvl" gorm:"default:1"`

	// Monster info
	MonsterName  string `json:"monster_name"`
	MonsterHP    int    `json:"monster_hp"`
	MonsterATK   int    `json:"monster_atk"`
	MonsterDEF   int    `json:"monster_def"`

	// Rewards per minute
	GoldPerMin   int `json:"gold_per_min"`
	ExpPerMin    int `json:"exp_per_min"`

	// Drop rates
	NormalDropRate  float64 `json:"normal_drop_rate"`  // 일반 장비
	UncommonDropRate float64 `json:"uncommon_drop_rate"` // 고급 장비
	RareDropRate    float64 `json:"rare_drop_rate"`    // 희귀 장비

	// Boss (every 10 minutes)
	BossName    string `json:"boss_name,omitempty"`
	BossHP      int    `json:"boss_hp"`
	BossATK     int    `json:"boss_atk"`
	BossDEF     int    `json:"boss_def"`
	BossGold    int    `json:"boss_gold"`
}

// 스테이지 데이터
var Stages = []Stage{
	// Chapter 1: 시작의 숲 (Lv 1~15)
	{Chapter: 1, StageNumber: 1, Name: "숲 입구", RequiredLvl: 1,
		MonsterName: "슬라임", MonsterHP: 50, MonsterATK: 5, MonsterDEF: 2,
		GoldPerMin: 5, ExpPerMin: 10,
		NormalDropRate: 0.05, UncommonDropRate: 0.01, RareDropRate: 0.001,
		BossName: "킹 슬라임", BossHP: 500, BossATK: 20, BossDEF: 10, BossGold: 100},
	{Chapter: 1, StageNumber: 2, Name: "작은 길", RequiredLvl: 3,
		MonsterName: "고블린", MonsterHP: 80, MonsterATK: 8, MonsterDEF: 3,
		GoldPerMin: 8, ExpPerMin: 15,
		NormalDropRate: 0.05, UncommonDropRate: 0.01, RareDropRate: 0.001,
		BossName: "고블린 대장", BossHP: 800, BossATK: 30, BossDEF: 15, BossGold: 150},
	{Chapter: 1, StageNumber: 3, Name: "깊은 숲", RequiredLvl: 5,
		MonsterName: "늑대", MonsterHP: 120, MonsterATK: 12, MonsterDEF: 5,
		GoldPerMin: 12, ExpPerMin: 22,
		NormalDropRate: 0.05, UncommonDropRate: 0.01, RareDropRate: 0.001,
		BossName: "늑대 우두머리", BossHP: 1200, BossATK: 45, BossDEF: 20, BossGold: 220},
	{Chapter: 1, StageNumber: 4, Name: "늪지대", RequiredLvl: 8,
		MonsterName: "거미", MonsterHP: 160, MonsterATK: 15, MonsterDEF: 6,
		GoldPerMin: 18, ExpPerMin: 30,
		NormalDropRate: 0.05, UncommonDropRate: 0.01, RareDropRate: 0.001,
		BossName: "거대 거미", BossHP: 1600, BossATK: 55, BossDEF: 25, BossGold: 300},
	{Chapter: 1, StageNumber: 5, Name: "고대 나무", RequiredLvl: 10,
		MonsterName: "트렌트", MonsterHP: 250, MonsterATK: 18, MonsterDEF: 10,
		GoldPerMin: 25, ExpPerMin: 40,
		NormalDropRate: 0.05, UncommonDropRate: 0.01, RareDropRate: 0.001,
		BossName: "고대 트렌트", BossHP: 2500, BossATK: 70, BossDEF: 40, BossGold: 400},
	{Chapter: 1, StageNumber: 6, Name: "숲의 심연", RequiredLvl: 13,
		MonsterName: "오크", MonsterHP: 350, MonsterATK: 25, MonsterDEF: 12,
		GoldPerMin: 35, ExpPerMin: 55,
		NormalDropRate: 0.05, UncommonDropRate: 0.015, RareDropRate: 0.002,
		BossName: "오크 전사장", BossHP: 3500, BossATK: 90, BossDEF: 50, BossGold: 550},

	// Chapter 2: 잊혀진 광산 (Lv 16~30)
	{Chapter: 2, StageNumber: 1, Name: "광산 입구", RequiredLvl: 16,
		MonsterName: "박쥐", MonsterHP: 400, MonsterATK: 30, MonsterDEF: 14,
		GoldPerMin: 45, ExpPerMin: 70,
		NormalDropRate: 0.05, UncommonDropRate: 0.015, RareDropRate: 0.002,
		BossName: "흡혈 박쥐", BossHP: 4000, BossATK: 110, BossDEF: 55, BossGold: 700},
	{Chapter: 2, StageNumber: 2, Name: "갱도", RequiredLvl: 19,
		MonsterName: "코볼트", MonsterHP: 500, MonsterATK: 38, MonsterDEF: 18,
		GoldPerMin: 60, ExpPerMin: 90,
		NormalDropRate: 0.05, UncommonDropRate: 0.02, RareDropRate: 0.003,
		BossName: "코볼트 주술사", BossHP: 5000, BossATK: 130, BossDEF: 60, BossGold: 900},
	{Chapter: 2, StageNumber: 3, Name: "채굴장", RequiredLvl: 22,
		MonsterName: "골렘", MonsterHP: 800, MonsterATK: 45, MonsterDEF: 30,
		GoldPerMin: 80, ExpPerMin: 115,
		NormalDropRate: 0.05, UncommonDropRate: 0.02, RareDropRate: 0.003,
		BossName: "스톤 골렘", BossHP: 8000, BossATK: 150, BossDEF: 100, BossGold: 1150},
	{Chapter: 2, StageNumber: 4, Name: "지하 호수", RequiredLvl: 25,
		MonsterName: "슬라임 킹", MonsterHP: 600, MonsterATK: 55, MonsterDEF: 20,
		GoldPerMin: 100, ExpPerMin: 145,
		NormalDropRate: 0.05, UncommonDropRate: 0.025, RareDropRate: 0.005,
		BossName: "엘더 슬라임", BossHP: 6000, BossATK: 180, BossDEF: 70, BossGold: 1450},
	{Chapter: 2, StageNumber: 5, Name: "심층부", RequiredLvl: 28,
		MonsterName: "드워프 망령", MonsterHP: 700, MonsterATK: 65, MonsterDEF: 25,
		GoldPerMin: 130, ExpPerMin: 180,
		NormalDropRate: 0.05, UncommonDropRate: 0.03, RareDropRate: 0.005,
		BossName: "드워프 왕의 혼백", BossHP: 7000, BossATK: 200, BossDEF: 85, BossGold: 1800},

	// Chapter 3~7 would follow similar pattern...
}

type StageListResponse struct {
	Stages        []Stage `json:"stages"`
	CurrentStage  int     `json:"current_stage"`
	UnlockedUntil int     `json:"unlocked_until"`
}

type StageChangeRequest struct {
	StageID uint `json:"stage_id" binding:"required"`
}
