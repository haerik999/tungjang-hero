package main

import (
	"log"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"github.com/tungjang-hero/server/internal/config"
	"github.com/tungjang-hero/server/internal/database"
	"github.com/tungjang-hero/server/internal/handlers"
	"github.com/tungjang-hero/server/internal/middleware"
)

func main() {
	// Load .env file
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using environment variables")
	}

	// Load configuration
	cfg := config.Load()

	// Set Gin mode
	gin.SetMode(cfg.Server.GinMode)

	// Initialize database
	if err := database.Initialize(cfg); err != nil {
		log.Fatalf("Failed to initialize database: %v", err)
	}
	defer database.Close()

	// Auto migrate
	if err := database.AutoMigrate(); err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}

	// Seed initial data
	if err := database.SeedData(); err != nil {
		log.Printf("Warning: Failed to seed data: %v", err)
	}

	// Initialize auth
	middleware.InitAuth(cfg)

	// Create router
	r := gin.Default()

	// CORS middleware
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	// Rate limiting
	r.Use(middleware.RateLimit(100, time.Minute))

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"status":  "ok",
			"message": "텅장히어로 서버가 정상 작동중입니다!",
			"version": "1.0.0",
		})
	})

	// Initialize handlers
	authHandler := handlers.NewAuthHandler()
	userHandler := handlers.NewUserHandler()
	heroHandler := handlers.NewHeroHandler()
	transactionHandler := handlers.NewTransactionHandler()
	questHandler := handlers.NewQuestHandler()
	achievementHandler := handlers.NewAchievementHandler()
	budgetHandler := handlers.NewBudgetHandler()
	inventoryHandler := handlers.NewInventoryHandler()
	equipmentHandler := handlers.NewEquipmentHandler()
	challengeHandler := handlers.NewChallengeHandler()

	// API v1 routes
	v1 := r.Group("/api/v1")
	{
		// Auth routes (public)
		auth := v1.Group("/auth")
		{
			auth.POST("/register", authHandler.Register)
			auth.POST("/login", authHandler.Login)
			auth.POST("/google", authHandler.GoogleOAuth)
			auth.POST("/find-email", authHandler.FindEmail)
			auth.POST("/password/reset-request", authHandler.PasswordResetRequest)
			auth.POST("/password/reset-confirm", authHandler.PasswordResetConfirm)
		}

		// Protected routes
		protected := v1.Group("")
		protected.Use(middleware.AuthRequired())
		{
			// Auth
			protected.POST("/auth/refresh", authHandler.RefreshToken)

			// User routes
			users := protected.Group("/users")
			{
				users.GET("/me", userHandler.GetMe)
				users.PUT("/me", userHandler.UpdateMe)
				users.GET("/me/stats", userHandler.GetUserStats)
			}

			// Hero routes
			hero := protected.Group("/hero")
			{
				hero.POST("/", heroHandler.CreateHero)
				hero.GET("/", heroHandler.GetHero)
				hero.GET("/stats", heroHandler.GetHeroStats)
				hero.POST("/stats/allocate", heroHandler.AllocateStat)
				hero.POST("/stats/reset", heroHandler.ResetStats)
				hero.POST("/collect-rewards", heroHandler.CollectOfflineRewards)
				hero.GET("/stages", heroHandler.GetStages)
				hero.POST("/stages/change", heroHandler.ChangeStage)
				hero.POST("/hunt", heroHandler.SimulateHunting)
			}

			// Transaction routes
			transactions := protected.Group("/transactions")
			{
				transactions.GET("/", transactionHandler.GetTransactions)
				transactions.POST("/", transactionHandler.CreateTransaction)
				transactions.GET("/summary", transactionHandler.GetSummary)
				transactions.GET("/:id", transactionHandler.GetTransaction)
				transactions.PUT("/:id", transactionHandler.UpdateTransaction)
				transactions.DELETE("/:id", transactionHandler.DeleteTransaction)
			}

			// Budget routes
			budgets := protected.Group("/budgets")
			{
				budgets.GET("/", budgetHandler.GetBudget)
				budgets.POST("/", budgetHandler.CreateBudget)
				budgets.PUT("/", budgetHandler.UpdateBudget)
				budgets.DELETE("/", budgetHandler.DeleteBudget)
				budgets.POST("/copy", budgetHandler.CopyBudget)
			}

			// Quest routes
			quests := protected.Group("/quests")
			{
				quests.GET("/", questHandler.GetAllQuests)
				quests.GET("/active", questHandler.GetActiveQuests)
				quests.GET("/history", questHandler.GetQuestHistory)
				quests.POST("/:id/claim", questHandler.ClaimQuestReward)
			}

			// Achievement routes
			achievements := protected.Group("/achievements")
			{
				achievements.GET("/", achievementHandler.GetAchievements)
				achievements.GET("/category/:category", achievementHandler.GetAchievementsByCategory)
				achievements.POST("/:id/claim", achievementHandler.ClaimAchievementReward)
			}

			// Challenge routes
			challenges := protected.Group("/challenges")
			{
				challenges.GET("/", challengeHandler.GetChallenges)
				challenges.POST("/", challengeHandler.CreateChallenge)
				challenges.GET("/my", challengeHandler.GetMyChallenges)
				challenges.GET("/:id", challengeHandler.GetChallenge)
				challenges.POST("/:id/join", challengeHandler.JoinChallenge)
				challenges.POST("/:id/claim", challengeHandler.ClaimChallengeReward)
			}

			// Inventory routes
			inventory := protected.Group("/inventory")
			{
				inventory.GET("/", inventoryHandler.GetInventory)
				inventory.GET("/items/:type", inventoryHandler.GetItemInfo)
				inventory.POST("/use", inventoryHandler.UseItem)
				inventory.POST("/sell", inventoryHandler.SellItems)
			}

			// Equipment routes
			equipment := protected.Group("/equipment")
			{
				equipment.GET("/", equipmentHandler.GetEquipments)
				equipment.GET("/:id", equipmentHandler.GetEquipment)
				equipment.POST("/equip", equipmentHandler.EquipItem)
				equipment.POST("/:id/unequip", equipmentHandler.UnequipItem)
				equipment.POST("/enhance", equipmentHandler.EnhanceEquipment)
				equipment.DELETE("/:id", equipmentHandler.SellEquipment)
			}
		}
	}

	// Start server
	log.Printf("Starting server on port %s", cfg.Server.Port)
	if err := r.Run(":" + cfg.Server.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
