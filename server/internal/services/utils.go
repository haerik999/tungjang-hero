package services

import (
	"crypto/rand"
	"encoding/hex"
	"strings"
)

// MaskEmail masks the email address for privacy
// e.g., "hello@example.com" -> "h****@example.com"
func MaskEmail(email string) string {
	parts := strings.Split(email, "@")
	if len(parts) != 2 {
		return email
	}

	localPart := parts[0]
	domain := parts[1]

	if len(localPart) <= 1 {
		return localPart[0:1] + "***@" + domain
	}

	// Show first character and mask the rest
	masked := string(localPart[0]) + "***"

	return masked + "@" + domain
}

// GenerateResetToken generates a secure random token for password reset
func GenerateResetToken() (string, error) {
	bytes := make([]byte, 32) // 256-bit token
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return hex.EncodeToString(bytes), nil
}
