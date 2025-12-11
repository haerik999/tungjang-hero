package handlers

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/tungjang-hero/server/internal/database"
	"github.com/tungjang-hero/server/internal/domain/models"
	"github.com/tungjang-hero/server/internal/middleware"
)

type BudgetHandler struct{}

func NewBudgetHandler() *BudgetHandler {
	return &BudgetHandler{}
}

// GetBudget returns budget for a specific month
func (h *BudgetHandler) GetBudget(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	year, _ := strconv.Atoi(c.Query("year"))
	month, _ := strconv.Atoi(c.Query("month"))

	if year == 0 {
		year = time.Now().Year()
	}
	if month == 0 {
		month = int(time.Now().Month())
	}

	var budget models.Budget
	if err := database.DB.Preload("CategoryBudgets").
		Where("user_id = ? AND year = ? AND month = ?", userID, year, month).
		First(&budget).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Budget not found for this month"})
		return
	}

	// Calculate usage
	response := h.calculateBudgetUsage(userID, &budget, year, month)

	c.JSON(http.StatusOK, response)
}

// CreateBudget creates a new budget
func (h *BudgetHandler) CreateBudget(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)

	var req models.BudgetCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if budget already exists
	var existingBudget models.Budget
	if err := database.DB.Where("user_id = ? AND year = ? AND month = ?", userID, req.Year, req.Month).
		First(&existingBudget).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Budget already exists for this month"})
		return
	}

	// Create budget
	budget := models.Budget{
		UserID:      userID,
		Year:        req.Year,
		Month:       req.Month,
		TotalBudget: req.TotalBudget,
	}

	if err := database.DB.Create(&budget).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create budget"})
		return
	}

	// Create category budgets
	for _, cb := range req.CategoryBudgets {
		categoryBudget := models.CategoryBudget{
			BudgetID: budget.ID,
			Category: cb.Category,
			Amount:   cb.Amount,
		}
		database.DB.Create(&categoryBudget)
	}

	// Reload with category budgets
	database.DB.Preload("CategoryBudgets").First(&budget, budget.ID)

	c.JSON(http.StatusCreated, budget)
}

// UpdateBudget updates an existing budget
func (h *BudgetHandler) UpdateBudget(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	year, _ := strconv.Atoi(c.Query("year"))
	month, _ := strconv.Atoi(c.Query("month"))

	if year == 0 || month == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Year and month are required"})
		return
	}

	var budget models.Budget
	if err := database.DB.Where("user_id = ? AND year = ? AND month = ?", userID, year, month).
		First(&budget).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Budget not found"})
		return
	}

	var req models.BudgetUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Update total budget
	if req.TotalBudget > 0 {
		budget.TotalBudget = req.TotalBudget
	}

	if err := database.DB.Save(&budget).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update budget"})
		return
	}

	// Update category budgets
	if len(req.CategoryBudgets) > 0 {
		// Delete existing category budgets
		database.DB.Where("budget_id = ?", budget.ID).Delete(&models.CategoryBudget{})

		// Create new ones
		for _, cb := range req.CategoryBudgets {
			categoryBudget := models.CategoryBudget{
				BudgetID: budget.ID,
				Category: cb.Category,
				Amount:   cb.Amount,
			}
			database.DB.Create(&categoryBudget)
		}
	}

	// Reload with category budgets
	database.DB.Preload("CategoryBudgets").First(&budget, budget.ID)

	c.JSON(http.StatusOK, budget)
}

// DeleteBudget deletes a budget
func (h *BudgetHandler) DeleteBudget(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	year, _ := strconv.Atoi(c.Query("year"))
	month, _ := strconv.Atoi(c.Query("month"))

	if year == 0 || month == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Year and month are required"})
		return
	}

	var budget models.Budget
	if err := database.DB.Where("user_id = ? AND year = ? AND month = ?", userID, year, month).
		First(&budget).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Budget not found"})
		return
	}

	// Delete category budgets first
	database.DB.Where("budget_id = ?", budget.ID).Delete(&models.CategoryBudget{})

	// Delete budget
	if err := database.DB.Delete(&budget).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete budget"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Budget deleted successfully"})
}

// calculateBudgetUsage calculates budget usage for response
func (h *BudgetHandler) calculateBudgetUsage(userID uint, budget *models.Budget, year, month int) models.BudgetResponse {
	startDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endDate := startDate.AddDate(0, 1, 0)
	now := time.Now()

	// Calculate total used
	var totalUsed int64
	database.DB.Model(&models.Transaction{}).
		Where("user_id = ? AND type = ? AND transaction_date >= ? AND transaction_date < ?",
			userID, models.TransactionTypeExpense, startDate, endDate).
		Select("COALESCE(SUM(amount), 0)").Scan(&totalUsed)

	// Calculate remaining days
	var remainingDays int
	if now.Before(endDate) && now.After(startDate) {
		remainingDays = int(endDate.Sub(now).Hours() / 24)
	} else if now.Before(startDate) {
		remainingDays = int(endDate.Sub(startDate).Hours() / 24)
	}

	// Calculate daily allowance
	var dailyAllowance int64
	if remainingDays > 0 {
		dailyAllowance = (budget.TotalBudget - totalUsed) / int64(remainingDays)
		if dailyAllowance < 0 {
			dailyAllowance = 0
		}
	}

	// Calculate usage percent
	usagePercent := 0.0
	if budget.TotalBudget > 0 {
		usagePercent = float64(totalUsed) / float64(budget.TotalBudget) * 100
	}

	// Category usage
	var categoryUsage []models.CategoryUsageResponse
	for _, cb := range budget.CategoryBudgets {
		var used int64
		database.DB.Model(&models.Transaction{}).
			Where("user_id = ? AND type = ? AND category = ? AND transaction_date >= ? AND transaction_date < ?",
				userID, models.TransactionTypeExpense, cb.Category, startDate, endDate).
			Select("COALESCE(SUM(amount), 0)").Scan(&used)

		categoryPct := 0.0
		if cb.Amount > 0 {
			categoryPct = float64(used) / float64(cb.Amount) * 100
		}

		categoryUsage = append(categoryUsage, models.CategoryUsageResponse{
			Category:     cb.Category,
			BudgetAmount: cb.Amount,
			UsedAmount:   used,
			Remaining:    cb.Amount - used,
			UsagePercent: categoryPct,
			IsOverBudget: used > cb.Amount,
		})
	}

	return models.BudgetResponse{
		Budget:          *budget,
		UsedAmount:      totalUsed,
		RemainingAmount: budget.TotalBudget - totalUsed,
		UsagePercent:    usagePercent,
		RemainingDays:   remainingDays,
		DailyAllowance:  dailyAllowance,
		CategoryUsage:   categoryUsage,
	}
}

// CopyBudget copies budget from previous month
func (h *BudgetHandler) CopyBudget(c *gin.Context) {
	userID := middleware.GetCurrentUserID(c)
	year, _ := strconv.Atoi(c.Query("year"))
	month, _ := strconv.Atoi(c.Query("month"))

	if year == 0 || month == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Year and month are required"})
		return
	}

	// Check if budget already exists for target month
	var existingBudget models.Budget
	if err := database.DB.Where("user_id = ? AND year = ? AND month = ?", userID, year, month).
		First(&existingBudget).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Budget already exists for this month"})
		return
	}

	// Get previous month
	prevDate := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local).AddDate(0, -1, 0)
	prevYear := prevDate.Year()
	prevMonth := int(prevDate.Month())

	// Get previous month's budget
	var prevBudget models.Budget
	if err := database.DB.Preload("CategoryBudgets").
		Where("user_id = ? AND year = ? AND month = ?", userID, prevYear, prevMonth).
		First(&prevBudget).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "No previous budget to copy"})
		return
	}

	// Create new budget
	newBudget := models.Budget{
		UserID:      userID,
		Year:        year,
		Month:       month,
		TotalBudget: prevBudget.TotalBudget,
	}

	if err := database.DB.Create(&newBudget).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create budget"})
		return
	}

	// Copy category budgets
	for _, cb := range prevBudget.CategoryBudgets {
		categoryBudget := models.CategoryBudget{
			BudgetID: newBudget.ID,
			Category: cb.Category,
			Amount:   cb.Amount,
		}
		database.DB.Create(&categoryBudget)
	}

	// Reload with category budgets
	database.DB.Preload("CategoryBudgets").First(&newBudget, newBudget.ID)

	c.JSON(http.StatusCreated, newBudget)
}
