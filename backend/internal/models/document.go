package models

import (
	"time"

	"gorm.io/gorm"
)

type Document struct {
	ID           uint           `gorm:"primaryKey" json:"id"`
	UserID       uint           `json:"user_id"`
	Type         string         `json:"type"` // e.g. "KTP", "PASPOR"
	Status       string         `json:"status"` // SUBMITTED, IN_REVIEW, APPROVED, REJECTED
	RejectReason string         `json:"reject_reason,omitempty"`
	Data         string         `type:"json" json:"data"`
	FilePath     string         `json:"file_path,omitempty"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
	
	User         User           `gorm:"foreignKey:UserID" json:"-"`
}
