package database

import (
	"fmt"
	"log"

	"github.com/govapp/backend/internal/config"
	"github.com/govapp/backend/internal/models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func Connect(cfg *config.Config) (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Jakarta",
		cfg.DBHost, cfg.DBUser, cfg.DBPassword, cfg.DBName, cfg.DBPort)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, err
	}

	log.Println("Successfully connected to database")
	return db, nil
}

func Migrate(db *gorm.DB) {
	err := db.AutoMigrate(
		&models.User{},
		&models.Document{},
		&models.Payment{},
		&models.Complaint{},
	)
	if err != nil {
		log.Printf("Failed to migrate database: %v", err)
	} else {
		log.Println("Database migration completed successfully")
	}
}
