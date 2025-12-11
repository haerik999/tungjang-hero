package config

import (
	"os"
	"strconv"
)

type Config struct {
	Server   ServerConfig
	Database DatabaseConfig
	JWT      JWTConfig
	OAuth    OAuthConfig
}

type ServerConfig struct {
	Port    string
	GinMode string
}

type DatabaseConfig struct {
	Host     string
	Port     int
	User     string
	Password string
	DBName   string
	SSLMode  string
}

type JWTConfig struct {
	Secret      string
	ExpiryHours int
}

type OAuthConfig struct {
	GoogleClientID string
}

func Load() *Config {
	// SERVER_PORT가 우선, 없으면 PORT 확인
	port := getEnv("SERVER_PORT", "")
	if port == "" {
		port = getEnv("PORT", "8080")
	}

	return &Config{
		Server: ServerConfig{
			Port:    port,
			GinMode: getEnv("GIN_MODE", "debug"),
		},
		Database: DatabaseConfig{
			Host:     getEnv("DB_HOST", "localhost"),
			Port:     getEnvAsInt("DB_PORT", 5432),
			User:     getEnv("DB_USER", "tungjang"),
			Password: getEnv("DB_PASSWORD", "heropassword"),
			DBName:   getEnv("DB_NAME", "tungjang_hero"),
			SSLMode:  getEnv("DB_SSLMODE", "disable"),
		},
		JWT: JWTConfig{
			Secret:      getEnv("JWT_SECRET", "your-super-secret-key-change-in-production"),
			ExpiryHours: getEnvAsInt("JWT_EXPIRY_HOURS", 24),
		},
		OAuth: OAuthConfig{
			GoogleClientID: getEnv("GOOGLE_CLIENT_ID", ""),
		},
	}
}

func getEnv(key, defaultValue string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return defaultValue
}

func getEnvAsInt(key string, defaultValue int) int {
	if value := os.Getenv(key); value != "" {
		if intValue, err := strconv.Atoi(value); err == nil {
			return intValue
		}
	}
	return defaultValue
}
