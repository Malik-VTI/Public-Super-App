package handlers

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/govapp/backend/internal/services"
	"github.com/govapp/backend/pkg/response"
)

type PaymentHandler struct {
	service services.PaymentService
}

func NewPaymentHandler(service services.PaymentService) *PaymentHandler {
	return &PaymentHandler{service}
}

func (h *PaymentHandler) ListBills(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		response.Error(c, 401, "Unauthorized", nil)
		return
	}

	bills, err := h.service.GetUserBills(userID.(uint))
	if err != nil {
		response.Error(c, 500, "Failed to retrieve bills", []string{err.Error()})
		return
	}

	response.Success(c, "Bills retrieved successfully", bills)
}

type ProcessPaymentRequest struct {
	BillID        uint   `json:"bill_id" binding:"required"`
	PaymentMethod string `json:"payment_method" binding:"required"`
	BankCode      string `json:"bank_code"`
	EwalletType   string `json:"ewallet_type"`
}

func (h *PaymentHandler) Process(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		response.Error(c, 401, "Unauthorized", nil)
		return
	}

	var req ProcessPaymentRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.Error(c, 400, "Invalid request", []string{err.Error()})
		return
	}

	payment, err := h.service.ProcessPayment(userID.(uint), req.BillID, req.PaymentMethod, req.BankCode, req.EwalletType)
	if err != nil {
		response.Error(c, 500, "Failed to process payment", []string{err.Error()})
		return
	}

	response.Success(c, "Payment process completed", payment)
}

func (h *PaymentHandler) Status(c *gin.Context) {
	paymentIDStr := c.Param("id")
	paymentID, err := strconv.ParseUint(paymentIDStr, 10, 32)
	if err != nil {
		response.Error(c, 400, "Invalid payment ID", nil)
		return
	}

	payment, err := h.service.GetPaymentStatus(uint(paymentID))
	if err != nil {
		response.Error(c, 404, "Payment not found", []string{err.Error()})
		return
	}

	response.Success(c, "Payment status retrieved successfully", payment)
}

func (h *PaymentHandler) History(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		response.Error(c, 401, "Unauthorized", nil)
		return
	}

	history, err := h.service.GetPaymentHistory(userID.(uint))
	if err != nil {
		response.Error(c, 500, "Failed to retrieve payment history", []string{err.Error()})
		return
	}

	response.Success(c, "Payment history retrieved successfully", history)
}
