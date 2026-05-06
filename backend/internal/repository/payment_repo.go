package repository

import (
	"github.com/govapp/backend/internal/models"
	"gorm.io/gorm"
)

type PaymentRepository interface {
	Create(payment *models.Payment) error
	FindBillsByUserID(userID uint) ([]models.Payment, error)
	FindHistoryByUserID(userID uint) ([]models.Payment, error)
	FindByID(id uint) (*models.Payment, error)
	UpdateStatus(id uint, status string) error
	UpdateSuccess(id uint, status, method, transactionID, bankCode, vaNumber, qrisString, ewalletRef string) error
}

type paymentRepository struct {
	db *gorm.DB
}

func NewPaymentRepository(db *gorm.DB) PaymentRepository {
	return &paymentRepository{db}
}

func (r *paymentRepository) Create(payment *models.Payment) error {
	return r.db.Create(payment).Error
}

func (r *paymentRepository) FindBillsByUserID(userID uint) ([]models.Payment, error) {
	var bills []models.Payment
	err := r.db.Where("user_id = ? AND status = ?", userID, "PENDING").Find(&bills).Error
	return bills, err
}

func (r *paymentRepository) FindHistoryByUserID(userID uint) ([]models.Payment, error) {
	var history []models.Payment
	err := r.db.Where("user_id = ? AND status != ?", userID, "PENDING").Order("created_at desc").Find(&history).Error
	return history, err
}

func (r *paymentRepository) FindByID(id uint) (*models.Payment, error) {
	var payment models.Payment
	err := r.db.Where("id = ?", id).First(&payment).Error
	if err != nil {
		return nil, err
	}
	return &payment, nil
}

func (r *paymentRepository) UpdateStatus(id uint, status string) error {
	return r.db.Model(&models.Payment{}).Where("id = ?", id).Update("status", status).Error
}

func (r *paymentRepository) UpdateSuccess(id uint, status, method, transactionID, bankCode, vaNumber, qrisString, ewalletRef string) error {
	updates := map[string]interface{}{
		"status":         status,
		"payment_method": method,
		"transaction_id": transactionID,
		"paid_at":        gorm.Expr("NOW()"),
	}
	if bankCode != "" {
		updates["bank_code"] = bankCode
	}
	if vaNumber != "" {
		updates["va_number"] = vaNumber
	}
	if qrisString != "" {
		updates["qris_string"] = qrisString
	}
	if ewalletRef != "" {
		updates["ewallet_ref"] = ewalletRef
	}

	return r.db.Model(&models.Payment{}).Where("id = ?", id).Updates(updates).Error
}
