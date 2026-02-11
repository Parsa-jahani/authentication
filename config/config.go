package config

import (
	"os"
)

type Config struct {
	Port         string
	DBPath       string
	JWTSecret    string
	JWTExpiryMin int
}

func Load() *Config {
	return &Config{
		Port:         getEnv("PORT", "8080"),
		DBPath:       getEnv("DB_PATH", "./database/auth.db"),
		JWTSecret:    getEnv("JWT_SECRET", "super-secret-change-me"),
		JWTExpiryMin: 60, // 1 hour
	}
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}
