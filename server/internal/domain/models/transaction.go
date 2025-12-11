package models

import (
	"time"
)

type TransactionType string

const (
	TransactionTypeExpense TransactionType = "expense"
	TransactionTypeIncome  TransactionType = "income"
)

type Category string

const (
	CategoryFood       Category = "food"
	CategoryTransport  Category = "transport"
	CategoryShopping   Category = "shopping"
	CategoryCafe       Category = "cafe"
	CategoryEntertain  Category = "entertainment"
	CategoryMedical    Category = "medical"
	CategoryTelecom    Category = "telecom"
	CategoryHousing    Category = "housing"
	CategoryEducation  Category = "education"
	CategorySavings    Category = "savings"
	CategorySalary     Category = "salary"
	CategoryOther      Category = "other"
)

type Transaction struct {
	ID              uint            `json:"id" gorm:"primaryKey"`
	UserID          uint            `json:"user_id" gorm:"index;not null"`
	Type            TransactionType `json:"type" gorm:"not null"`
	Amount          int64           `json:"amount" gorm:"not null"`
	Category        Category        `json:"category" gorm:"not null"`
	Description     string          `json:"description"`
	TransactionDate time.Time       `json:"transaction_date" gorm:"not null"`
	CreatedAt       time.Time       `json:"created_at"`
	UpdatedAt       time.Time       `json:"updated_at"`

	// Receipt verification
	HasReceipt      bool   `json:"has_receipt" gorm:"default:false"`
	ReceiptImageURL string `json:"receipt_image_url,omitempty"`
	ReceiptVerified bool   `json:"receipt_verified" gorm:"default:false"`

	// Reward tracking
	RewardClaimed   bool `json:"reward_claimed" gorm:"default:false"`

	// Relations
	User   *User   `json:"user,omitempty" gorm:"foreignKey:UserID"`
	Reward *Reward `json:"reward,omitempty" gorm:"foreignKey:TransactionID"`
}

type TransactionCreateRequest struct {
	Type            TransactionType `json:"type" binding:"required,oneof=expense income"`
	Amount          int64           `json:"amount" binding:"required,min=1000"`
	Category        Category        `json:"category" binding:"required"`
	Description     string          `json:"description"`
	TransactionDate time.Time       `json:"transaction_date" binding:"required"`
	ReceiptImage    string          `json:"receipt_image,omitempty"` // Base64 encoded
}

type TransactionUpdateRequest struct {
	Type            TransactionType `json:"type" binding:"omitempty,oneof=expense income"`
	Amount          int64           `json:"amount" binding:"omitempty,min=1000"`
	Category        Category        `json:"category"`
	Description     string          `json:"description"`
	TransactionDate time.Time       `json:"transaction_date"`
}

type TransactionListRequest struct {
	Year     int      `form:"year"`
	Month    int      `form:"month"`
	Type     string   `form:"type"`
	Category string   `form:"category"`
	Page     int      `form:"page,default=1"`
	Limit    int      `form:"limit,default=20"`
}

type TransactionSummary struct {
	TotalIncome  int64 `json:"total_income"`
	TotalExpense int64 `json:"total_expense"`
	Balance      int64 `json:"balance"`
}

type CategorySummary struct {
	Category Category `json:"category"`
	Amount   int64    `json:"amount"`
	Count    int      `json:"count"`
	Percent  float64  `json:"percent"`
}
