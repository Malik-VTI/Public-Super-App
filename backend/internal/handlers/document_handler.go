package handlers

import (
	"path/filepath"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/govapp/backend/internal/services"
	"github.com/govapp/backend/pkg/response"
)

type DocumentHandler struct {
	service services.DocumentService
}

func NewDocumentHandler(service services.DocumentService) *DocumentHandler {
	return &DocumentHandler{service}
}

type CreateDocumentRequest struct {
	Type string                 `json:"type" binding:"required"`
	Data map[string]interface{} `json:"data" binding:"required"`
}

func (h *DocumentHandler) Create(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		response.Error(c, 401, "Unauthorized", nil)
		return
	}

	var req CreateDocumentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, 400, "Invalid request", []string{err.Error()})
		return
	}

	doc, err := h.service.CreateDocument(userID.(uint), req.Type, req.Data)
	if err != nil {
		response.Error(c, 500, "Failed to create document", []string{err.Error()})
		return
	}

	response.Success(c, "Document created successfully", doc)
}

func (h *DocumentHandler) List(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		response.Error(c, 401, "Unauthorized", nil)
		return
	}

	docs, err := h.service.GetUserDocuments(userID.(uint))
	if err != nil {
		response.Error(c, 500, "Failed to retrieve documents", []string{err.Error()})
		return
	}

	response.Success(c, "Documents retrieved successfully", docs)
}

func (h *DocumentHandler) Status(c *gin.Context) {
	docIDStr := c.Param("id")
	docID, err := strconv.ParseUint(docIDStr, 10, 32)
	if err != nil {
		response.Error(c, 400, "Invalid document ID", nil)
		return
	}

	doc, err := h.service.GetDocumentStatus(uint(docID))
	if err != nil {
		response.Error(c, 404, "Document not found", []string{err.Error()})
		return
	}

	response.Success(c, "Document status retrieved successfully", doc)
}

func (h *DocumentHandler) UploadFile(c *gin.Context) {
	docIDStr := c.Param("id")
	docID, err := strconv.ParseUint(docIDStr, 10, 32)
	if err != nil {
		response.Error(c, 400, "Invalid document ID", nil)
		return
	}

	file, err := c.FormFile("file")
	if err != nil {
		response.Error(c, 400, "File is required", []string{err.Error()})
		return
	}

	// Simple check, no complex validation for demo purposes
	filename := strconv.FormatInt(time.Now().Unix(), 10) + filepath.Ext(file.Filename)
	filePath := "uploads/documents/" + filename

	// Note: in a real application, you'd save it to a cloud bucket or robust storage.
	// We'll just assume the directory exists or you'd save it relatively.
	// For this simulation, we just update the path in DB.
	
	err = h.service.UploadFile(uint(docID), filePath)
	if err != nil {
		response.Error(c, 500, "Failed to update document file path", []string{err.Error()})
		return
	}

	response.Success(c, "File uploaded successfully", gin.H{"file_path": filePath})
}
