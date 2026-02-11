package main

import (
	"log"

	"github.com/gin-gonic/gin"
	"github.com/umix/auth-service/config"
	"github.com/umix/auth-service/database"
	"github.com/umix/auth-service/handlers"
	"github.com/umix/auth-service/middleware"
)

func main() {
	// Load configuration
	cfg := config.Load()

	// Set JWT secret
	middleware.SetJWTSecret(cfg.JWTSecret)

	// Connect to database
	database.Connect(cfg.DBPath)

	// Create Gin router
	r := gin.Default()

	// Health check
	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// Auth routes
	auth := &handlers.AuthHandler{Config: cfg}
	authGroup := r.Group("/auth")
	{
		authGroup.POST("/register", auth.Register)
		authGroup.POST("/login", auth.Login)
		authGroup.POST("/refresh", auth.Refresh)

		// Protected routes (require valid JWT)
		authGroup.GET("/me", middleware.AuthRequired(), auth.Me)
		authGroup.POST("/logout", middleware.AuthRequired(), auth.Logout)
	}

	// Start server
	log.Printf("Server starting on port %s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
