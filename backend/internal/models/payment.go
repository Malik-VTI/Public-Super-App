package models

import (
	"time"

	"gorm.io/gorm"
)

type Payment struct {
	ID            uint           `gorm:"primaryKey" json:"id"`
	UserID        uint           `json:"user_id"`
	BillType      string         `json:"bill_type"` // PBB, PKB
	BillNumber    string         `json:"bill_number"`
	Amount        float64        `json:"amount"`
	Status        string         `json:"status"` // PENDING, SUCCESS, FAILED, TIMEOUT
	PaymentMethod string         `json:"payment_method,omitempty"`
	TransactionID string         `json:"transaction_id,omitempty"`
	PaidAt        *time.Time     `json:"paid_at,omitempty"`
	CreatedAt     time.Time      `json:"created_at"`
	UpdatedAt     time.Time      `json:"updated_at"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"-"`
	
	User          User           `gorm:"foreignKey:UserID" json:"-"`
}
