package main

import (
	"log"

	"github.com/gin-gonic/gin"
	"github.com/govapp/backend/internal/config"
	"github.com/govapp/backend/internal/database"
	"github.com/govapp/backend/internal/middleware"
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

	api := r.Group("/api/v1")
	{
		// Auth Routes
		authGroup := api.Group("/auth")
		{
			// TODO: Add auth routes
			_ = authGroup
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
