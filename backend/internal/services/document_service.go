package services

import (
	"encoding/json"
	"errors"

	"github.com/govapp/backend/internal/models"
	"github.com/govapp/backend/internal/repository"
	"github.com/govapp/backend/pkg/simulator"
)

type DocumentService interface {
	CreateDocument(userID uint, docType string, data map[string]interface{}) (*models.Document, error)
	GetUserDocuments(userID uint) ([]models.Document, error)
	GetDocumentStatus(docID uint) (*models.Document, error)
	UploadFile(docID uint, filePath string) error
	SimulateProcessing(docID uint)
}

type documentService struct {
	repo      repository.DocumentRepository
	simulator simulator.DocumentSimulator
}

func NewDocumentService(repo repository.DocumentRepository, sim simulator.DocumentSimulator) DocumentService {
	return &documentService{repo, sim}
}

func (s *documentService) CreateDocument(userID uint, docType string, data map[string]interface{}) (*models.Document, error) {
	dataBytes, err := json.Marshal(data)
	if err != nil {
		return nil, errors.New("invalid document data format")
	}

	doc := &models.Document{
		UserID: userID,
		Type:   docType,
		Status: "SUBMITTED",
		Data:   string(dataBytes),
	}

	err = s.repo.Create(doc)
	if err != nil {
		return nil, err
	}

	// Trigger simulation in background
	go s.SimulateProcessing(doc.ID)

	return doc, nil
}

func (s *documentService) GetUserDocuments(userID uint) ([]models.Document, error) {
	return s.repo.FindByUserID(userID)
}

func (s *documentService) GetDocumentStatus(docID uint) (*models.Document, error) {
	return s.repo.FindByID(docID)
}

func (s *documentService) UploadFile(docID uint, filePath string) error {
	doc, err := s.repo.FindByID(docID)
	if err != nil {
		return err
	}
	if doc == nil {
		return errors.New("document not found")
	}
	return s.repo.UpdateFilePath(docID, filePath)
}

func (s *documentService) SimulateProcessing(docID uint) {
	// First step: SUBMITTED -> IN_REVIEW
	doc, err := s.repo.FindByID(docID)
	if err != nil || doc == nil {
		return
	}

	newStatus, reason := s.simulator.SimulateProcessing(doc.Status)
	if newStatus != doc.Status {
		s.repo.UpdateStatus(docID, newStatus, reason)
		
		// If it reached IN_REVIEW, simulate again to reach APPROVED/REJECTED
		if newStatus == "IN_REVIEW" {
			go s.SimulateProcessing(docID)
		}
	}
}
