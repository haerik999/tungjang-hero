package handlers

import (
	"context"
	"fmt"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/tungjang-hero/server/internal/config"
	"github.com/tungjang-hero/server/internal/database"
	"github.com/tungjang-hero/server/internal/domain/models"
	"github.com/tungjang-hero/server/internal/middleware"
	"github.com/tungjang-hero/server/internal/services"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type AuthHandler struct{}

func NewAuthHandler() *AuthHandler {
	return &AuthHandler{}
}

// Register creates a new user account
func (h *AuthHandler) Register(c *gin.Context) {
	var req models.UserRegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Check if email already exists
	var existingUser models.User
	if err := database.DB.Where("email = ?", req.Email).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Email already registered"})
		return
	}

	// Check if nickname already exists
	if err := database.DB.Where("nickname = ?", req.Nickname).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusConflict, gin.H{"error": "Nickname already taken"})
		return
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Create user
	user := models.User{
		Email:    req.Email,
		Password: string(hashedPassword),
		Nickname: req.Nickname,
	}

	if err := database.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
		return
	}

	// Generate token
	token, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusCreated, models.UserLoginResponse{
		Token: token,
		User:  user,
	})
}

// Login authenticates a user and returns a token
func (h *AuthHandler) Login(c *gin.Context) {
	var req models.UserLoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Find user by email
	var user models.User
	if err := database.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// Check password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
		return
	}

	// Update last login
	now := time.Now()
	user.LastLoginAt = &now
	database.DB.Save(&user)

	// Generate token
	token, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, models.UserLoginResponse{
		Token: token,
		User:  user,
	})
}

// RefreshToken generates a new token for the current user
func (h *AuthHandler) RefreshToken(c *gin.Context) {
	user := middleware.GetCurrentUser(c)
	if user == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return
	}

	token, err := middleware.GenerateToken(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}

// GoogleOAuth handles Google OAuth authentication
func (h *AuthHandler) GoogleOAuth(c *gin.Context) {
	var req models.OAuthGoogleRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Get config for Google client ID
	cfg := config.Load()

	// Verify Google token
	ctx := context.Background()
	googleInfo, err := services.VerifyGoogleToken(ctx, req.Token, cfg.OAuth.GoogleClientID)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Google token"})
		return
	}

	if !googleInfo.EmailVerified {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email not verified"})
		return
	}

	// Check if user exists with this OAuth provider
	var user models.User
	err = database.DB.Where("oauth_provider = ? AND oauth_id = ?", "google", googleInfo.Sub).First(&user).Error

	if err == gorm.ErrRecordNotFound {
		// Check if email already exists (for linking accounts)
		err = database.DB.Where("email = ?", googleInfo.Email).First(&user).Error
		if err == gorm.ErrRecordNotFound {
			// Create new user
			nickname := googleInfo.Name
			if nickname == "" {
				nickname = googleInfo.Email[:len(googleInfo.Email)-len("@gmail.com")]
			}

			user = models.User{
				Email:         googleInfo.Email,
				Nickname:      nickname,
				OAuthProvider: "google",
				OAuthID:       googleInfo.Sub,
			}

			if err := database.DB.Create(&user).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
				return
			}
		} else if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
			return
		} else {
			// User exists with same email but different provider - link accounts
			user.OAuthProvider = "google"
			user.OAuthID = googleInfo.Sub
			database.DB.Save(&user)
		}
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Update last login
	now := time.Now()
	user.LastLoginAt = &now
	database.DB.Save(&user)

	// Generate token
	token, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, models.UserLoginResponse{
		Token: token,
		User:  user,
	})
}

// KakaoOAuth handles Kakao OAuth authentication
func (h *AuthHandler) KakaoOAuth(c *gin.Context) {
	var req models.OAuthKakaoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Verify Kakao token
	ctx := context.Background()
	kakaoInfo, err := services.VerifyKakaoToken(ctx, req.Token)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Kakao token"})
		return
	}

	kakaoID := fmt.Sprintf("%d", kakaoInfo.ID)
	email := kakaoInfo.KakaoAccount.Email
	nickname := kakaoInfo.Properties.Nickname

	// Email might not be available if user didn't agree
	if email == "" {
		email = fmt.Sprintf("kakao_%s@tungjang-hero.local", kakaoID)
	}

	if nickname == "" {
		nickname = fmt.Sprintf("User_%s", kakaoID[:8])
	}

	// Check if user exists with this OAuth provider
	var user models.User
	err = database.DB.Where("oauth_provider = ? AND oauth_id = ?", "kakao", kakaoID).First(&user).Error

	if err == gorm.ErrRecordNotFound {
		// Check if email already exists (for linking accounts)
		if kakaoInfo.KakaoAccount.Email != "" {
			err = database.DB.Where("email = ?", email).First(&user).Error
			if err == gorm.ErrRecordNotFound {
				// Create new user
				user = models.User{
					Email:         email,
					Nickname:      nickname,
					OAuthProvider: "kakao",
					OAuthID:       kakaoID,
				}

				if err := database.DB.Create(&user).Error; err != nil {
					c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
					return
				}
			} else if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
				return
			} else {
				// User exists with same email but different provider - link accounts
				user.OAuthProvider = "kakao"
				user.OAuthID = kakaoID
				database.DB.Save(&user)
			}
		} else {
			// Create new user without verified email
			user = models.User{
				Email:         email,
				Nickname:      nickname,
				OAuthProvider: "kakao",
				OAuthID:       kakaoID,
			}

			if err := database.DB.Create(&user).Error; err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create user"})
				return
			}
		}
	} else if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Update last login
	now := time.Now()
	user.LastLoginAt = &now
	database.DB.Save(&user)

	// Generate token
	token, err := middleware.GenerateToken(&user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
		return
	}

	c.JSON(http.StatusOK, models.UserLoginResponse{
		Token: token,
		User:  user,
	})
}

// FindEmail finds user email by nickname and returns masked email
func (h *AuthHandler) FindEmail(c *gin.Context) {
	var req models.FindEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Find user by nickname
	var user models.User
	if err := database.DB.Where("nickname = ?", req.Nickname).First(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "User not found with this nickname"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Database error"})
		return
	}

	// Mask the email for privacy
	maskedEmail := services.MaskEmail(user.Email)

	c.JSON(http.StatusOK, models.FindEmailResponse{
		Email: maskedEmail,
	})
}

// PasswordResetRequest generates a password reset token
func (h *AuthHandler) PasswordResetRequest(c *gin.Context) {
	var req models.PasswordResetRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Find user by email
	var user models.User
	if err := database.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		// Don't reveal if email exists or not for security
		c.JSON(http.StatusOK, models.PasswordResetResponse{
			Message: "If the email exists, a password reset token has been generated",
		})
		return
	}

	// Check if user is OAuth user (they can't reset password)
	if user.OAuthProvider != "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Cannot reset password for OAuth accounts"})
		return
	}

	// Generate reset token
	resetToken, err := services.GenerateResetToken()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate reset token"})
		return
	}

	// Set token expiry (1 hour from now)
	expiry := time.Now().Add(1 * time.Hour)

	// Save token to database
	user.PasswordResetToken = resetToken
	user.PasswordResetExpiry = &expiry
	if err := database.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save reset token"})
		return
	}

	// In production, you would send this token via email
	// For now, return it in the response for testing
	c.JSON(http.StatusOK, models.PasswordResetResponse{
		Message: "Password reset token generated successfully",
		Token:   resetToken, // Only for development - remove in production
	})
}

// PasswordResetConfirm verifies the reset token and sets new password
func (h *AuthHandler) PasswordResetConfirm(c *gin.Context) {
	var req models.PasswordResetConfirmRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Find user with this reset token
	var user models.User
	if err := database.DB.Where("password_reset_token = ?", req.Token).First(&user).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid or expired reset token"})
		return
	}

	// Check if token is expired
	if user.PasswordResetExpiry == nil || time.Now().After(*user.PasswordResetExpiry) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Reset token has expired"})
		return
	}

	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password"})
		return
	}

	// Update password and clear reset token
	user.Password = string(hashedPassword)
	user.PasswordResetToken = ""
	user.PasswordResetExpiry = nil

	if err := database.DB.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update password"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Password reset successfully",
	})
}
