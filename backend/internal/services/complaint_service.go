package services

import (
	"errors"

	"github.com/govapp/backend/internal/models"
	"github.com/govapp/backend/internal/repository"
)

type ComplaintService interface {
	CreateComplaint(userID uint, category, description, address string, lat, lng float64) (*models.Complaint, error)
	GetUserComplaints(userID uint) ([]models.Complaint, error)
	GetComplaintDetail(id uint) (*models.Complaint, error)
	UploadPhoto(id uint, filePath string) error
}

type complaintService struct {
	repo repository.ComplaintRepository
}

func NewComplaintService(repo repository.ComplaintRepository) ComplaintService {
	return &complaintService{repo}
}

func (s *complaintService) CreateComplaint(userID uint, category, description, address string, lat, lng float64) (*models.Complaint, error) {
	complaint := &models.Complaint{
		UserID:      userID,
		Category:    category,
		Description: description,
		Latitude:    lat,
		Longitude:   lng,
		Address:     address,
		Status:      "SUBMITTED",
	}

	err := s.repo.Create(complaint)
	if err != nil {
		return nil, err
	}

	return complaint, nil
}

func (s *complaintService) GetUserComplaints(userID uint) ([]models.Complaint, error) {
	return s.repo.FindByUserID(userID)
}

func (s *complaintService) GetComplaintDetail(id uint) (*models.Complaint, error) {
	return s.repo.FindByID(id)
}

func (s *complaintService) UploadPhoto(id uint, filePath string) error {
	complaint, err := s.repo.FindByID(id)
	if err != nil {
		return err
	}
	if complaint == nil {
		return errors.New("complaint not found")
	}

	return s.repo.UpdatePhotoPath(id, filePath)
}
