package main

import (
	"log"

	"github.com/gin-gonic/gin"
	"github.com/govapp/backend/internal/config"
	"github.com/govapp/backend/internal/database"
	"github.com/govapp/backend/internal/handlers"
	"github.com/govapp/backend/internal/middleware"
	"github.com/govapp/backend/internal/repository"
	"github.com/govapp/backend/internal/services"
)

func main() {
	cfg := config.LoadConfig()

	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	database.Migrate(db)

	if cfg.AppEnv == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()
	r.Use(middleware.CORS())

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	// Initialize dependencies
	userRepo := repository.NewUserRepository(db)
	authService := services.NewAuthService(userRepo, cfg.JWTSecret, cfg.JWTExpiryHours)
	authHandler := handlers.NewAuthHandler(authService)

	api := r.Group("/api/v1")
	{
		// Auth Routes
		authGroup := api.Group("/auth")
		{
			authGroup.POST("/login", authHandler.Login)
			authGroup.POST("/biometric", authHandler.BiometricLogin)
			authGroup.POST("/logout", authHandler.Logout)
			authGroup.POST("/refresh", authHandler.Refresh)
			
			// Protected profile route
			protected := authGroup.Group("")
			protected.Use(middleware.Auth(cfg.JWTSecret))
			protected.GET("/profile", authHandler.Profile)
		}

		// Document Routes
		docGroup := api.Group("/documents")
		// docGroup.Use(middleware.Auth(cfg.JWTSecret)) // Will uncomment when auth is ready
		{
			// TODO: Add document routes
			_ = docGroup
		}

		// Payment Routes
		paymentGroup := api.Group("/payments")
		// paymentGroup.Use(middleware.Auth(cfg.JWTSecret)) // Will uncomment when auth is ready
		{
			// TODO: Add payment routes
			_ = paymentGroup
		}

		// Complaint Routes
		complaintGroup := api.Group("/complaints")
		// complaintGroup.Use(middleware.Auth(cfg.JWTSecret)) // Will uncomment when auth is ready
		{
			// TODO: Add complaint routes
			_ = complaintGroup
		}
	}

	port := cfg.AppPort
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
