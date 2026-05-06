package handlers

import (
	"path/filepath"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/govapp/backend/internal/services"
	"github.com/govapp/backend/pkg/response"
)

type ComplaintHandler struct {
	service services.ComplaintService
}

func NewComplaintHandler(service services.ComplaintService) *ComplaintHandler {
	return &ComplaintHandler{service}
}

type CreateComplaintRequest struct {
	Category    string  `json:"category" binding:"required"`
	Description string  `json:"description" binding:"required"`
	Address     string  `json:"address" binding:"required"`
	Latitude    float64 `json:"latitude" binding:"required"`
	Longitude   float64 `json:"longitude" binding:"required"`
}

func (h *ComplaintHandler) Create(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		response.Error(c, 401, "Unauthorized", nil)
		return
	}

	var req CreateComplaintRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, 400, "Invalid request", []string{err.Error()})
		return
	}

	complaint, err := h.service.CreateComplaint(userID.(uint), req.Category, req.Description, req.Address, req.Latitude, req.Longitude)
	if err != nil {
		response.Error(c, 500, "Failed to create complaint", []string{err.Error()})
		return
	}

	response.Success(c, "Complaint submitted successfully", complaint)
}

func (h *ComplaintHandler) List(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		response.Error(c, 401, "Unauthorized", nil)
		return
	}

	complaints, err := h.service.GetUserComplaints(userID.(uint))
	if err != nil {
		response.Error(c, 500, "Failed to retrieve complaints", []string{err.Error()})
		return
	}

	response.Success(c, "Complaints retrieved successfully", complaints)
}

func (h *ComplaintHandler) Detail(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		response.Error(c, 400, "Invalid complaint ID", nil)
		return
	}

	complaint, err := h.service.GetComplaintDetail(uint(id))
	if err != nil {
		response.Error(c, 404, "Complaint not found", []string{err.Error()})
		return
	}

	response.Success(c, "Complaint detail retrieved successfully", complaint)
}

func (h *ComplaintHandler) UploadPhoto(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		response.Error(c, 400, "Invalid complaint ID", nil)
		return
	}

	file, err := c.FormFile("file")
	if err != nil {
		response.Error(c, 400, "Photo file is required", []string{err.Error()})
		return
	}

	filename := strconv.FormatInt(time.Now().Unix(), 10) + filepath.Ext(file.Filename)
	filePath := "uploads/complaints/" + filename

	err = h.service.UploadPhoto(uint(id), filePath)
	if err != nil {
		response.Error(c, 500, "Failed to update complaint photo path", []string{err.Error()})
		return
	}

	response.Success(c, "Photo uploaded successfully", gin.H{"photo_path": filePath})
}
