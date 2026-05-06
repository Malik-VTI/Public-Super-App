package services

import (
	"errors"
	"fmt"
	"time"

	"github.com/govapp/backend/internal/models"
	"github.com/govapp/backend/internal/repository"
	"github.com/govapp/backend/pkg/simulator"
)

type PaymentService interface {
	GetUserBills(userID uint) ([]models.Payment, error)
	GetPaymentHistory(userID uint) ([]models.Payment, error)
	GetPaymentStatus(paymentID uint) (*models.Payment, error)
	ProcessPayment(userID uint, paymentID uint, method, bankCode, ewalletType string) (*models.Payment, error)
}

type paymentService struct {
	repo      repository.PaymentRepository
	simulator simulator.PaymentSimulator
}

func NewPaymentService(repo repository.PaymentRepository, sim simulator.PaymentSimulator) PaymentService {
	return &paymentService{repo, sim}
}

func (s *paymentService) GetUserBills(userID uint) ([]models.Payment, error) {
	return s.repo.FindBillsByUserID(userID)
}

func (s *paymentService) GetPaymentHistory(userID uint) ([]models.Payment, error) {
	return s.repo.FindHistoryByUserID(userID)
}

func (s *paymentService) GetPaymentStatus(paymentID uint) (*models.Payment, error) {
	return s.repo.FindByID(paymentID)
}

func (s *paymentService) ProcessPayment(userID uint, paymentID uint, method, bankCode, ewalletType string) (*models.Payment, error) {
	payment, err := s.repo.FindByID(paymentID)
	if err != nil {
		return nil, err
	}
	if payment == nil {
		return nil, errors.New("payment not found")
	}
	if payment.UserID != userID {
		return nil, errors.New("unauthorized to process this payment")
	}
	if payment.Status != "PENDING" && payment.Status != "FAILED" && payment.Status != "TIMEOUT" {
		return nil, errors.New("payment cannot be processed because it is already paid or in progress")
	}

	result := s.simulator.Simulate()

	if result == "SUCCESS" {
		trxID := fmt.Sprintf("TRX-%d-%d", time.Now().Unix(), paymentID)
		
		// Generate details based on method
		var vaNum, qrisStr, ewalletRef string
		if method == "VIRTUAL_ACCOUNT" || method == "BANK_TRANSFER" {
			vaNum = fmt.Sprintf("8800%d", time.Now().UnixNano()%1000000000000)
			if bankCode == "" {
				bankCode = "BCA" // Default for testing
			}
		} else if method == "QRIS" {
			qrisStr = fmt.Sprintf("00020101021226%d", time.Now().UnixNano())
		} else if method == "EWALLET" {
			if ewalletType == "" {
				ewalletType = "GOPAY"
			}
			ewalletRef = fmt.Sprintf("%s-REF-%d", ewalletType, time.Now().Unix())
		}

		err = s.repo.UpdateSuccess(paymentID, result, method, trxID, bankCode, vaNum, qrisStr, ewalletRef)
	} else {
		err = s.repo.UpdateStatus(paymentID, result)
	}

	if err != nil {
		return nil, err
	}

	return s.repo.FindByID(paymentID)
}
