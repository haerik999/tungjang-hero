package services

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"

	"google.golang.org/api/idtoken"
)

type GoogleTokenInfo struct {
	Email         string `json:"email"`
	EmailVerified bool   `json:"email_verified"`
	Name          string `json:"name"`
	Picture       string `json:"picture"`
	Sub           string `json:"sub"` // Google user ID
}

type KakaoTokenInfo struct {
	ID           int64              `json:"id"`
	KakaoAccount KakaoAccountInfo   `json:"kakao_account"`
	Properties   KakaoProperties    `json:"properties"`
}

type KakaoAccountInfo struct {
	Email              string `json:"email"`
	EmailNeedsAgreement bool  `json:"email_needs_agreement"`
}

type KakaoProperties struct {
	Nickname string `json:"nickname"`
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

// VerifyKakaoToken verifies a Kakao OAuth token and returns user info
func VerifyKakaoToken(ctx context.Context, token string) (*KakaoTokenInfo, error) {
	// Call Kakao API to verify token
	req, err := http.NewRequestWithContext(ctx, "GET", "https://kapi.kakao.com/v2/user/me", nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Authorization", "Bearer "+token)
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded;charset=utf-8")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to verify Kakao token: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("Kakao API error (status %d): %s", resp.StatusCode, string(body))
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	var tokenInfo KakaoTokenInfo
	if err := json.Unmarshal(body, &tokenInfo); err != nil {
		return nil, fmt.Errorf("failed to parse Kakao response: %w", err)
	}

	// Validate required fields
	if tokenInfo.ID == 0 {
		return nil, errors.New("invalid Kakao token: user ID not found")
	}

	return &tokenInfo, nil
}
