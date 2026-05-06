package handlers

import (
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/govapp/backend/internal/services"
	"github.com/govapp/backend/pkg/response"
)

type AuthHandler struct {
	service services.AuthService
}

func NewAuthHandler(service services.AuthService) *AuthHandler {
	return &AuthHandler{service}
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, 400, "Invalid request", []string{err.Error()})
		return
	}

	token, err := h.service.Login(req.Email, req.Password)
	if err != nil {
		response.Error(c, 401, "Login failed", []string{err.Error()})
		return
	}

	response.Success(c, "Login successful", gin.H{"token": token})
}

type BiometricRequest struct {
	BiometricKey string `json:"biometric_key" binding:"required"`
}

func (h *AuthHandler) BiometricLogin(c *gin.Context) {
	var req BiometricRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, 400, "Invalid request", []string{err.Error()})
		return
	}

	token, err := h.service.ValidateBiometric(req.BiometricKey)
	if err != nil {
		response.Error(c, 401, "Biometric login failed", []string{err.Error()})
		return
	}

	response.Success(c, "Biometric login successful", gin.H{"token": token})
}

func (h *AuthHandler) Logout(c *gin.Context) {
	// In a real application, you might want to blacklist the token in Redis.
	// For this simulation, we'll just instruct the client to delete it.
	response.Success(c, "Logout successful", nil)
}

func (h *AuthHandler) Refresh(c *gin.Context) {
	authHeader := c.GetHeader("Authorization")
	if authHeader == "" {
		response.Error(c, 401, "Unauthorized", []string{"Authorization header is required"})
		return
	}

	parts := strings.SplitN(authHeader, " ", 2)
	if len(parts) != 2 || parts[0] != "Bearer" {
		response.Error(c, 401, "Unauthorized", []string{"Invalid Authorization header format"})
		return
	}

	oldToken := parts[1]
	newToken, err := h.service.RefreshToken(oldToken)
	if err != nil {
		response.Error(c, 401, "Token refresh failed", []string{err.Error()})
		return
	}

	response.Success(c, "Token refreshed successfully", gin.H{"token": newToken})
}

func (h *AuthHandler) Profile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		response.Error(c, 401, "Unauthorized", []string{"User ID not found in context"})
		return
	}

	user, err := h.service.GetProfile(userID.(uint))
	if err != nil {
		response.Error(c, 404, "User not found", []string{err.Error()})
		return
	}

	response.Success(c, "Profile retrieved successfully", user)
}

type RegisterRequest struct {
	NIK      string `json:"nik" binding:"required,len=16"`
	FullName string `json:"full_name" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
	Phone    string `json:"phone" binding:"required"`
	Password string `json:"password" binding:"required,min=6"`
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, 400, "Invalid request", []string{err.Error()})
		return
	}

	token, err := h.service.Register(req.NIK, req.FullName, req.Email, req.Phone, req.Password)
	if err != nil {
		response.Error(c, 400, "Registration failed", []string{err.Error()})
		return
	}

	response.Success(c, "Registration successful", gin.H{"token": token})
}

type ResetPasswordRequest struct {
	Email       string `json:"email" binding:"required,email"`
	NIK         string `json:"nik" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

func (h *AuthHandler) ResetPassword(c *gin.Context) {
	var req ResetPasswordRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, 400, "Invalid request", []string{err.Error()})
		return
	}

	err := h.service.ResetPassword(req.Email, req.NIK, req.NewPassword)
	if err != nil {
		response.Error(c, 400, "Password reset failed", []string{err.Error()})
		return
	}

	response.Success(c, "Password reset successfully", nil)
}

type UpdateProfileRequest struct {
	FullName string `json:"full_name" binding:"required"`
	Phone    string `json:"phone" binding:"required"`
}

func (h *AuthHandler) UpdateProfile(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		response.Error(c, 401, "Unauthorized", []string{"User ID not found in context"})
		return
	}

	var req UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, 400, "Invalid request", []string{err.Error()})
		return
	}

	user, err := h.service.UpdateProfile(userID.(uint), req.FullName, req.Phone)
	if err != nil {
		response.Error(c, 500, "Profile update failed", []string{err.Error()})
		return
	}

	response.Success(c, "Profile updated successfully", user)
}
