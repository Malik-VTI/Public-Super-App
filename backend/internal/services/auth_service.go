package services

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/govapp/backend/internal/models"
	"github.com/govapp/backend/internal/repository"
	"golang.org/x/crypto/bcrypt"
)

type AuthService interface {
	Login(email, password string) (string, error)
	ValidateBiometric(biometricKey string) (string, error)
	RefreshToken(oldToken string) (string, error)
	GetProfile(userID uint) (*models.User, error)
	Register(nik, fullName, email, phone, password string) (string, error)
	ResetPassword(email, nik, newPassword string) error
	UpdateProfile(userID uint, fullName, phone string) (*models.User, error)
}

type authService struct {
	repo           repository.UserRepository
	jwtSecret      string
	jwtExpiryHours int
}

func NewAuthService(repo repository.UserRepository, jwtSecret string, jwtExpiryHours int) AuthService {
	return &authService{
		repo:           repo,
		jwtSecret:      jwtSecret,
		jwtExpiryHours: jwtExpiryHours,
	}
}

func (s *authService) generateToken(userID uint) (string, error) {
	claims := jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Hour * time.Duration(s.jwtExpiryHours)).Unix(),
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.jwtSecret))
}

func (s *authService) Login(email, password string) (string, error) {
	user, err := s.repo.FindByEmail(email)
	if err != nil {
		return "", err
	}
	if user == nil {
		return "", errors.New("invalid email or password")
	}

	err = bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password))
	if err != nil {
		return "", errors.New("invalid email or password")
	}

	return s.generateToken(user.ID)
}

func (s *authService) ValidateBiometric(biometricKey string) (string, error) {
	user, err := s.repo.FindByBiometricKey(biometricKey)
	if err != nil {
		return "", err
	}
	if user == nil {
		return "", errors.New("invalid biometric credential")
	}

	return s.generateToken(user.ID)
}

func (s *authService) RefreshToken(oldTokenString string) (string, error) {
	token, err := jwt.Parse(oldTokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(s.jwtSecret), nil
	})

	if err != nil || !token.Valid {
		return "", errors.New("invalid or expired token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok {
		return "", errors.New("invalid token claims")
	}

	userIDFloat, ok := claims["user_id"].(float64)
	if !ok {
		return "", errors.New("invalid user_id in token")
	}

	return s.generateToken(uint(userIDFloat))
}

func (s *authService) GetProfile(userID uint) (*models.User, error) {
	user, err := s.repo.FindByID(userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, errors.New("user not found")
	}
	return user, nil
}

func (s *authService) Register(nik, fullName, email, phone, password string) (string, error) {
	// Check if email or NIK already exists
	existingUser, _ := s.repo.FindByEmail(email)
	if existingUser != nil {
		return "", errors.New("email already registered")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}

	user := &models.User{
		NIK:      nik,
		FullName: fullName,
		Email:    email,
		Phone:    phone,
		Password: string(hashedPassword),
	}

	err = s.repo.Create(user)
	if err != nil {
		return "", err
	}

	return s.generateToken(user.ID)
}

func (s *authService) ResetPassword(email, nik, newPassword string) error {
	user, err := s.repo.FindByEmail(email)
	if err != nil {
		return err
	}
	if user == nil || user.NIK != nik {
		return errors.New("invalid email or NIK")
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(newPassword), bcrypt.DefaultCost)
	if err != nil {
		return err
	}

	user.Password = string(hashedPassword)
	return s.repo.Update(user)
}

func (s *authService) UpdateProfile(userID uint, fullName, phone string) (*models.User, error) {
	user, err := s.repo.FindByID(userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, errors.New("user not found")
	}

	user.FullName = fullName
	user.Phone = phone

	err = s.repo.Update(user)
	if err != nil {
		return nil, err
	}

	return user, nil
}
