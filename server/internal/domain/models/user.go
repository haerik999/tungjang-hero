package models

import (
	"time"
)

type User struct {
	ID           uint      `json:"id" gorm:"primaryKey"`
	Email        string    `json:"email" gorm:"uniqueIndex;not null"`
	Password     string    `json:"-" gorm:""`
	Nickname     string    `json:"nickname" gorm:"not null"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
	LastLoginAt  *time.Time `json:"last_login_at"`

	// OAuth fields
	OAuthProvider string `json:"oauth_provider,omitempty" gorm:""`
	OAuthID       string `json:"oauth_id,omitempty" gorm:""`

	// Password reset fields
	PasswordResetToken  string     `json:"-" gorm:""`
	PasswordResetExpiry *time.Time `json:"-" gorm:""`

	// Relations
	Hero         *Hero         `json:"hero,omitempty" gorm:"foreignKey:UserID"`
	Transactions []Transaction `json:"transactions,omitempty" gorm:"foreignKey:UserID"`
}

type UserRegisterRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required,min=6"`
	Nickname string `json:"nickname" binding:"required,min=2,max=12"`
}

type UserLoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type UserLoginResponse struct {
	Token string `json:"token"`
	User  User   `json:"user"`
}

type UserUpdateRequest struct {
	Nickname string `json:"nickname" binding:"omitempty,min=2,max=12"`
}

// OAuth request/response types
type OAuthGoogleRequest struct {
	Token string `json:"token" binding:"required"`
}

type OAuthKakaoRequest struct {
	Token string `json:"token" binding:"required"`
}

// Find email request/response types
type FindEmailRequest struct {
	Nickname string `json:"nickname" binding:"required"`
}

type FindEmailResponse struct {
	Email string `json:"email"`
}

// Password reset request/response types
type PasswordResetRequest struct {
	Email string `json:"email" binding:"required,email"`
}

type PasswordResetResponse struct {
	Message string `json:"message"`
	Token   string `json:"token,omitempty"` // Only for development/testing
}

type PasswordResetConfirmRequest struct {
	Token       string `json:"token" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}
