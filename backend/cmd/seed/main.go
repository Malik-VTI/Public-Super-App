package main

import (
	"log"

	"github.com/govapp/backend/internal/config"
	"github.com/govapp/backend/internal/database"
	"github.com/govapp/backend/internal/models"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	cfg := config.LoadConfig()

	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Auto migrate
	database.Migrate(db)

	log.Println("Starting database seeding...")

	// Create dummy users if not exists
	hash, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	dummyPassword := string(hash)

	users := []models.User{
		{
			NIK:          "3201010101010001",
			FullName:     "Budi Santoso",
			Email:        "warga1@govapp.id",
			Phone:        "081234567890",
			Password:     dummyPassword,
			BiometricKey: "biometric_key_warga_1",
		},
		{
			NIK:          "3201010101010002",
			FullName:     "Siti Aminah",
			Email:        "warga2@govapp.id",
			Phone:        "081298765432",
			Password:     dummyPassword,
			BiometricKey: "biometric_key_warga_2",
		},
	}

	for _, user := range users {
		var count int64
		db.Model(&models.User{}).Where("email = ?", user.Email).Count(&count)
		if count == 0 {
			if err := db.Create(&user).Error; err != nil {
				log.Printf("Failed to seed user %s: %v\n", user.Email, err)
			} else {
				log.Printf("Seeded user: %s\n", user.Email)
			}
		}
	}

	log.Println("Database seeding completed.")
}
