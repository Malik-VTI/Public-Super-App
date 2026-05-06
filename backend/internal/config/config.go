package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	AppPort                    string
	AppEnv                     string
	DBHost                     string
	DBPort                     string
	DBName                     string
	DBUser                     string
	DBPassword                 string
	JWTSecret                  string
	JWTExpiryHours             int
	PaymentErrorRate           int
	PaymentTimeoutRate         int
	PaymentTimeoutSecs         int
	DocProcessingSecs          int
}

func LoadConfig() *Config {
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: .env file not found, using environment variables")
	}

	return &Config{
		AppPort:            getEnv("APP_PORT", "8080"),
		AppEnv:             getEnv("APP_ENV", "development"),
		DBHost:             getEnv("DB_HOST", "localhost"),
		DBPort:             getEnv("DB_PORT", "5432"),
		DBName:             getEnv("DB_NAME", "govapp_db"),
		DBUser:             getEnv("DB_USER", "govapp_user"),
		DBPassword:         getEnv("DB_PASSWORD", "govapp_password"),
		JWTSecret:          getEnv("JWT_SECRET", "secret"),
		JWTExpiryHours:     getEnvAsInt("JWT_EXPIRY_HOURS", 24),
		PaymentErrorRate:   getEnvAsInt("SIMULATOR_PAYMENT_ERROR_RATE", 10),
		PaymentTimeoutRate: getEnvAsInt("SIMULATOR_PAYMENT_TIMEOUT_RATE", 10),
		PaymentTimeoutSecs: getEnvAsInt("SIMULATOR_PAYMENT_TIMEOUT_SECS", 5),
		DocProcessingSecs:  getEnvAsInt("SIMULATOR_DOC_PROCESSING_SECS", 10),
	}
}

func getEnv(key string, defaultVal string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultVal
}

func getEnvAsInt(name string, defaultVal int) int {
	valueStr := getEnv(name, "")
	if value, err := strconv.Atoi(valueStr); err == nil {
		return value
	}
	return defaultVal
}
