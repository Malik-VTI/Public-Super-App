package simulator

import (
	"math/rand"
	"time"
)

type DocumentSimulator interface {
	SimulateProcessing(currentStatus string) (newStatus string, rejectReason string)
}

type documentSimulator struct {
	processingSecs int
}

func NewDocumentSimulator(processingSecs int) DocumentSimulator {
	return &documentSimulator{processingSecs}
}

func (s *documentSimulator) SimulateProcessing(currentStatus string) (string, string) {
	time.Sleep(time.Duration(s.processingSecs) * time.Second)

	if currentStatus == "SUBMITTED" {
		return "IN_REVIEW", ""
	}

	if currentStatus == "IN_REVIEW" {
		// Random chance: 80% approved, 20% rejected
		rand.Seed(time.Now().UnixNano())
		if rand.Intn(100) < 80 {
			return "APPROVED", ""
		}
		
		reasons := []string{"Dokumen tidak jelas", "Data tidak sesuai", "KTP sudah kedaluwarsa"}
		reason := reasons[rand.Intn(len(reasons))]
		return "REJECTED", reason
	}

	return currentStatus, ""
}
