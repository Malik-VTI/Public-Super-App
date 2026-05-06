package repository

import (
	"github.com/govapp/backend/internal/models"
	"gorm.io/gorm"
)

type DocumentRepository interface {
	Create(doc *models.Document) error
	FindByUserID(userID uint) ([]models.Document, error)
	FindByID(id uint) (*models.Document, error)
	UpdateStatus(id uint, status string, reason string) error
	UpdateFilePath(id uint, filePath string) error
}

type documentRepository struct {
	db *gorm.DB
}

func NewDocumentRepository(db *gorm.DB) DocumentRepository {
	return &documentRepository{db}
}

func (r *documentRepository) Create(doc *models.Document) error {
	return r.db.Create(doc).Error
}

func (r *documentRepository) FindByUserID(userID uint) ([]models.Document, error) {
	var docs []models.Document
	err := r.db.Where("user_id = ?", userID).Order("created_at desc").Find(&docs).Error
	return docs, err
}

func (r *documentRepository) FindByID(id uint) (*models.Document, error) {
	var doc models.Document
	err := r.db.Where("id = ?", id).First(&doc).Error
	if err != nil {
		return nil, err
	}
	return &doc, nil
}

func (r *documentRepository) UpdateStatus(id uint, status string, reason string) error {
	return r.db.Model(&models.Document{}).Where("id = ?", id).Updates(map[string]interface{}{
		"status":        status,
		"reject_reason": reason,
	}).Error
}

func (r *documentRepository) UpdateFilePath(id uint, filePath string) error {
	return r.db.Model(&models.Document{}).Where("id = ?", id).Update("file_path", filePath).Error
}
