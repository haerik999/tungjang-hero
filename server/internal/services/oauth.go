package services

import (
	"context"
	"errors"
	"fmt"

	"google.golang.org/api/idtoken"
)

type GoogleTokenInfo struct {
	Email         string `json:"email"`
	EmailVerified bool   `json:"email_verified"`
	Name          string `json:"name"`
	Picture       string `json:"picture"`
	Sub           string `json:"sub"` // Google user ID
}

// VerifyGoogleToken verifies a Google OAuth token and returns user info
func VerifyGoogleToken(ctx context.Context, token string, clientID string) (*GoogleTokenInfo, error) {
	// Verify the token with Google
	payload, err := idtoken.Validate(ctx, token, clientID)
	if err != nil {
		return nil, fmt.Errorf("invalid Google token: %w", err)
	}

	// Extract claims
	email, ok := payload.Claims["email"].(string)
	if !ok || email == "" {
		return nil, errors.New("email not found in token")
	}

	emailVerified, _ := payload.Claims["email_verified"].(bool)
	name, _ := payload.Claims["name"].(string)
	picture, _ := payload.Claims["picture"].(string)
	sub, _ := payload.Claims["sub"].(string)

	return &GoogleTokenInfo{
		Email:         email,
		EmailVerified: emailVerified,
		Name:          name,
		Picture:       picture,
		Sub:           sub,
	}, nil
}
