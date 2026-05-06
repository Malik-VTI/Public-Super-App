package simulator

import (
	"math/rand"
	"time"

	"github.com/govapp/backend/internal/config"
)

type PaymentSimulator interface {
	Simulate() string
}

type paymentSimulator struct {
	config *config.Config
}

func NewPaymentSimulator(cfg *config.Config) PaymentSimulator {
	return &paymentSimulator{cfg}
}

func (s *paymentSimulator) Simulate() string {
	rand.Seed(time.Now().UnixNano())
	random := rand.Intn(100)

	// Chance of failure
	if random < s.config.PaymentErrorRate {
		return "FAILED"
	}

	// Chance of timeout
	if random < s.config.PaymentErrorRate+s.config.PaymentTimeoutRate {
		time.Sleep(time.Duration(s.config.PaymentTimeoutSecs) * time.Second)
		return "TIMEOUT"
	}

	// Otherwise success
	return "SUCCESS"
}
