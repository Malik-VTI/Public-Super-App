package models

import (
	"time"

	"gorm.io/gorm"
)

type Complaint struct {
	ID          uint           `gorm:"primaryKey" json:"id"`
	UserID      uint           `json:"user_id"`
	Category    string         `json:"category"` // JALAN_RUSAK, LAMPU_MATI, dll.
	Description string         `json:"description"`
	Latitude    float64        `json:"latitude"`
	Longitude   float64        `json:"longitude"`
	Address     string         `json:"address"`
	PhotoPath   string         `json:"photo_path,omitempty"`
	Status      string         `json:"status"` // SUBMITTED, IN_PROGRESS, RESOLVED
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"-"`
	
	User        User           `gorm:"foreignKey:UserID" json:"-"`
}
