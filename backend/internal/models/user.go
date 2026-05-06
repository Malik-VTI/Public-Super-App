package models

import (
	"time"

	"gorm.io/gorm"
)

type User struct {
	ID           uint           `gorm:"primaryKey" json:"id"`
	NIK          string         `gorm:"uniqueIndex;type:varchar(16)" json:"nik"`
	FullName     string         `json:"full_name"`
	Email        string         `gorm:"uniqueIndex" json:"email"`
	Phone        string         `json:"phone"`
	Password     string         `json:"-"`
	BiometricKey string         `json:"-"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}
