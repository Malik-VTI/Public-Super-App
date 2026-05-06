package repository

import (
	"github.com/govapp/backend/internal/models"
	"gorm.io/gorm"
)

type ComplaintRepository interface {
	Create(complaint *models.Complaint) error
	FindByUserID(userID uint) ([]models.Complaint, error)
	FindByID(id uint) (*models.Complaint, error)
	UpdatePhotoPath(id uint, path string) error
}

type complaintRepository struct {
	db *gorm.DB
}

func NewComplaintRepository(db *gorm.DB) ComplaintRepository {
	return &complaintRepository{db}
}

func (r *complaintRepository) Create(complaint *models.Complaint) error {
	return r.db.Create(complaint).Error
}

func (r *complaintRepository) FindByUserID(userID uint) ([]models.Complaint, error) {
	var complaints []models.Complaint
	err := r.db.Where("user_id = ?", userID).Order("created_at desc").Find(&complaints).Error
	return complaints, err
}

func (r *complaintRepository) FindByID(id uint) (*models.Complaint, error) {
	var complaint models.Complaint
	err := r.db.Where("id = ?", id).First(&complaint).Error
	if err != nil {
		return nil, err
	}
	return &complaint, nil
}

func (r *complaintRepository) UpdatePhotoPath(id uint, path string) error {
	return r.db.Model(&models.Complaint{}).Where("id = ?", id).Update("photo_path", path).Error
}
