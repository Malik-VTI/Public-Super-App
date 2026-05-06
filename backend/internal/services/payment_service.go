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
	ProcessPayment(userID uint, paymentID uint, method string) (*models.Payment, error)
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

func (s *paymentService) ProcessPayment(userID uint, paymentID uint, method string) (*models.Payment, error) {
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
		err = s.repo.UpdateSuccess(paymentID, result, method, trxID)
	} else {
		err = s.repo.UpdateStatus(paymentID, result)
	}

	if err != nil {
		return nil, err
	}

	return s.repo.FindByID(paymentID)
}
