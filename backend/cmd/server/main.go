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
	"github.com/govapp/backend/pkg/simulator"
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

	// Initialize Document dependencies
	docSimulator := simulator.NewDocumentSimulator(cfg.DocProcessingSecs)
	docRepo := repository.NewDocumentRepository(db)
	docService := services.NewDocumentService(docRepo, docSimulator)
	docHandler := handlers.NewDocumentHandler(docService)

	// Initialize Payment dependencies
	paymentSimulator := simulator.NewPaymentSimulator(cfg)
	paymentRepo := repository.NewPaymentRepository(db)
	paymentService := services.NewPaymentService(paymentRepo, paymentSimulator)
	paymentHandler := handlers.NewPaymentHandler(paymentService)

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
		docGroup.Use(middleware.Auth(cfg.JWTSecret))
		{
			docGroup.GET("", docHandler.List)
			docGroup.POST("", docHandler.Create)
			docGroup.POST("/:id/upload", docHandler.UploadFile)
			docGroup.GET("/:id/status", docHandler.Status)
		}

		// Payment Routes
		paymentGroup := api.Group("/payments")
		paymentGroup.Use(middleware.Auth(cfg.JWTSecret))
		{
			paymentGroup.GET("/bills", paymentHandler.ListBills)
			paymentGroup.POST("/process", paymentHandler.Process)
			paymentGroup.GET("/:id/status", paymentHandler.Status)
			paymentGroup.GET("/history", paymentHandler.History)
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
