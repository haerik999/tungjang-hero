package database

import (
	"fmt"
	"log"

	"github.com/tungjang-hero/server/internal/config"
	"github.com/tungjang-hero/server/internal/domain/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func Initialize(cfg *config.Config) error {
	dsn := fmt.Sprintf(
		"host=%s port=%d user=%s password=%s dbname=%s sslmode=%s TimeZone=Asia/Seoul",
		cfg.Database.Host,
		cfg.Database.Port,
		cfg.Database.User,
		cfg.Database.Password,
		cfg.Database.DBName,
		cfg.Database.SSLMode,
	)

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	log.Println("Database connected successfully")
	return nil
}

func AutoMigrate() error {
	return DB.AutoMigrate(
		// User & Auth
		&models.User{},

		// Hero & Character
		&models.Hero{},
		&models.Preset{},
		&models.HeroSkill{},

		// Equipment & Items
		&models.EquipmentTemplate{},
		&models.Equipment{},
		&models.Item{},

		// Transactions & Budget
		&models.Transaction{},
		&models.Budget{},
		&models.CategoryBudget{},

		// Rewards
		&models.Reward{},
		&models.RewardItem{},

		// Quests
		&models.Quest{},
		&models.UserQuest{},

		// Challenges
		&models.Challenge{},
		&models.ChallengeParticipation{},

		// Achievements
		&models.Achievement{},
		&models.UserAchievement{},

		// Skills
		&models.Skill{},

		// Stages
		&models.Stage{},
	)
}

func SeedData() error {
	// Seed Stages
	var stageCount int64
	DB.Model(&models.Stage{}).Count(&stageCount)
	if stageCount == 0 {
		for _, stage := range models.Stages {
			if err := DB.Create(&stage).Error; err != nil {
				log.Printf("Error seeding stage: %v", err)
			}
		}
		log.Println("Stages seeded successfully")
	}

	// Seed Skills
	var skillCount int64
	DB.Model(&models.Skill{}).Count(&skillCount)
	if skillCount == 0 {
		for _, skill := range models.CommonSkills {
			if err := DB.Create(&skill).Error; err != nil {
				log.Printf("Error seeding skill: %v", err)
			}
		}
		log.Println("Skills seeded successfully")
	}

	// Seed Quests
	var questCount int64
	DB.Model(&models.Quest{}).Count(&questCount)
	if questCount == 0 {
		allQuests := append(models.DailyQuests, models.WeeklyQuests...)
		allQuests = append(allQuests, models.MonthlyQuests...)
		for _, quest := range allQuests {
			if err := DB.Create(&quest).Error; err != nil {
				log.Printf("Error seeding quest: %v", err)
			}
		}
		log.Println("Quests seeded successfully")
	}

	// Seed Achievements
	var achievementCount int64
	DB.Model(&models.Achievement{}).Count(&achievementCount)
	if achievementCount == 0 {
		for _, achievement := range models.Achievements {
			if err := DB.Create(&achievement).Error; err != nil {
				log.Printf("Error seeding achievement: %v", err)
			}
		}
		log.Println("Achievements seeded successfully")
	}

	return nil
}

func Close() {
	sqlDB, err := DB.DB()
	if err != nil {
		log.Printf("Error getting underlying DB: %v", err)
		return
	}
	sqlDB.Close()
}
