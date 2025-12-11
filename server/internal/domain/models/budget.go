package models

import (
	"time"
)

type Budget struct {
	ID        uint      `json:"id" gorm:"primaryKey"`
	UserID    uint      `json:"user_id" gorm:"index;not null"`
	Year      int       `json:"year" gorm:"not null"`
	Month     int       `json:"month" gorm:"not null"`

	// Total budget
	TotalBudget int64 `json:"total_budget"`

	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`

	// Relations
	User           *User            `json:"user,omitempty" gorm:"foreignKey:UserID"`
	CategoryBudgets []CategoryBudget `json:"category_budgets,omitempty" gorm:"foreignKey:BudgetID"`
}

type CategoryBudget struct {
	ID       uint     `json:"id" gorm:"primaryKey"`
	BudgetID uint     `json:"budget_id" gorm:"index;not null"`
	Category Category `json:"category" gorm:"not null"`
	Amount   int64    `json:"amount" gorm:"not null"`

	// Relations
	Budget *Budget `json:"budget,omitempty" gorm:"foreignKey:BudgetID"`
}

type BudgetCreateRequest struct {
	Year            int                      `json:"year" binding:"required"`
	Month           int                      `json:"month" binding:"required,min=1,max=12"`
	TotalBudget     int64                    `json:"total_budget" binding:"required,min=0"`
	CategoryBudgets []CategoryBudgetRequest `json:"category_budgets"`
}

type CategoryBudgetRequest struct {
	Category Category `json:"category" binding:"required"`
	Amount   int64    `json:"amount" binding:"required,min=0"`
}

type BudgetUpdateRequest struct {
	TotalBudget     int64                    `json:"total_budget"`
	CategoryBudgets []CategoryBudgetRequest `json:"category_budgets"`
}

type BudgetResponse struct {
	Budget
	UsedAmount      int64                   `json:"used_amount"`
	RemainingAmount int64                   `json:"remaining_amount"`
	UsagePercent    float64                 `json:"usage_percent"`
	RemainingDays   int                     `json:"remaining_days"`
	DailyAllowance  int64                   `json:"daily_allowance"`
	CategoryUsage   []CategoryUsageResponse `json:"category_usage"`
}

type CategoryUsageResponse struct {
	Category     Category `json:"category"`
	BudgetAmount int64    `json:"budget_amount"`
	UsedAmount   int64    `json:"used_amount"`
	Remaining    int64    `json:"remaining"`
	UsagePercent float64  `json:"usage_percent"`
	IsOverBudget bool     `json:"is_over_budget"`
}
