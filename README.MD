# 🏛️ GovApp — Super-App Layanan Publik

> Platform digital terpadu yang mengintegrasikan berbagai layanan publik untuk warga dalam satu aplikasi mobile.

---

## 📋 Daftar Isi

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Arsitektur Aplikasi](#arsitektur-aplikasi)
- [Struktur Proyek](#struktur-proyek)
- [Fitur Aplikasi](#fitur-aplikasi)
- [API Endpoints](#api-endpoints)
- [Setup & Instalasi](#setup--instalasi)
- [Environment Variables](#environment-variables)
- [Panduan Development](#panduan-development)
- [Catatan Penting](#catatan-penting)

---

## Overview

**GovApp** adalah aplikasi mobile layanan publik terpadu yang menggabungkan berbagai kebutuhan administrasi warga dalam satu platform. Aplikasi ini mencakup layanan autentikasi biometrik, pengajuan dokumen kependudukan, pembayaran pajak dan retribusi, serta pengaduan fasilitas umum berbasis peta.

Seluruh fitur dalam aplikasi ini bersifat **simulasi** dan tidak terhubung ke sistem pemerintahan nyata.

---

## Tech Stack

### Backend
| Komponen | Teknologi |
|---|---|
| **Language** | Go (Golang) |
| **Web Framework** | [Gin](https://github.com/gin-gonic/gin) |
| **ORM** | [GORM](https://gorm.io/) |
| **Database** | PostgreSQL |
| **Containerization** | Docker + Docker Compose |

### Frontend
| Komponen | Teknologi |
|---|---|
| **Framework** | Flutter |
| **Platform** | iOS & Android |
| **State Management** | BLoC / Riverpod |
| **HTTP Client** | Dio |
| **Maps** | Google Maps Flutter |

---

## Arsitektur Aplikasi

```
┌─────────────────────────────────────────────────────────────────┐
│                        FLUTTER MOBILE APP                        │
│                        iOS / Android                             │
└─────────────────────────┬───────────────────────────────────────┘
                           │ HTTPS / REST API
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                        API GATEWAY / NGINX                       │
│                    (Rate Limiting, SSL Termination)               │
└──────┬──────────────┬────────────────┬───────────────┬──────────┘
       │              │                │               │
       ▼              ▼                ▼               ▼
┌──────────┐  ┌──────────────┐  ┌──────────┐  ┌──────────────┐
│  Auth    │  │  Document    │  │ Payment  │  │  Complaint   │
│ Service  │  │  Service     │  │ Service  │  │  Service     │
│ (Go/Gin) │  │  (Go/Gin)    │  │ (Go/Gin) │  │  (Go/Gin)    │
└────┬─────┘  └──────┬───────┘  └────┬─────┘  └──────┬───────┘
     │               │               │               │
     └───────────────┴───────────────┴───────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   PostgreSQL DB  │
                    │   (GORM ORM)    │
                    └─────────────────┘
                              │
              ┌───────────────┴──────────────┐
              │                              │
              ▼                              ▼
   ┌─────────────────────┐      ┌────────────────────────┐
   │    Internal Cache   │      │  Simulated External    │
   │      (Redis)        │      │  Services:             │
   │                     │      │  - Payment Gateway     │
   └─────────────────────┘      │  - Maps API (Google)   │
                                │  - Document Validator  │
                                └────────────────────────┘
```

---

## Struktur Proyek

```
govapp/
│
├── backend/                          # Go Backend (Gin + GORM)
│   ├── cmd/
│   │   └── server/
│   │       └── main.go               # Entry point
│   │
│   ├── internal/
│   │   ├── config/
│   │   │   └── config.go             # App configuration (env vars)
│   │   │
│   │   ├── middleware/
│   │   │   ├── auth.go               # JWT middleware
│   │   │   └── cors.go               # CORS handler
│   │   │
│   │   ├── models/
│   │   │   ├── user.go               # User model
│   │   │   ├── document.go           # Document submission model
│   │   │   ├── payment.go            # Payment/tax model
│   │   │   └── complaint.go          # Public facility complaint model
│   │   │
│   │   ├── handlers/
│   │   │   ├── auth_handler.go       # Login, biometric token
│   │   │   ├── document_handler.go   # Upload & status dokumen
│   │   │   ├── payment_handler.go    # Pembayaran pajak/retribusi
│   │   │   └── complaint_handler.go  # Pengaduan fasilitas
│   │   │
│   │   ├── services/
│   │   │   ├── auth_service.go
│   │   │   ├── document_service.go
│   │   │   ├── payment_service.go    # Integrasi simulasi payment gateway
│   │   │   └── complaint_service.go
│   │   │
│   │   ├── repository/
│   │   │   ├── user_repo.go
│   │   │   ├── document_repo.go
│   │   │   ├── payment_repo.go
│   │   │   └── complaint_repo.go
│   │   │
│   │   └── database/
│   │       └── postgres.go           # GORM DB connection & migration
│   │
│   ├── pkg/
│   │   ├── simulator/
│   │   │   ├── payment_simulator.go  # Simulasi variasi response payment gateway
│   │   │   └── document_simulator.go # Simulasi proses validasi dokumen
│   │   └── response/
│   │       └── response.go           # Standard API response wrapper
│   │
│   ├── migrations/                   # SQL migration files
│   │
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── go.mod
│   ├── go.sum
│   └── .env.example
│
└── mobile/                           # Flutter App
    ├── lib/
    │   ├── main.dart                 # Entry point
    │   │
    │   ├── core/
    │   │   ├── constants/
    │   │   │   ├── api_constants.dart
    │   │   │   └── app_constants.dart
    │   │   ├── theme/
    │   │   │   └── app_theme.dart
    │   │   └── utils/
    │   │       └── helpers.dart
    │   │
    │   ├── data/
    │   │   ├── models/               # Dart model classes
    │   │   ├── repositories/         # Data layer
    │   │   └── datasources/
    │   │       └── remote/           # Dio HTTP client
    │   │
    │   └── presentation/
    │       ├── screens/
    │       │   ├── splash/
    │       │   ├── auth/
    │       │   │   ├── login_screen.dart
    │       │   │   └── biometric_screen.dart
    │       │   ├── dashboard/
    │       │   │   └── dashboard_screen.dart
    │       │   ├── document/
    │       │   │   ├── document_list_screen.dart
    │       │   │   ├── document_form_screen.dart
    │       │   │   └── document_upload_screen.dart
    │       │   ├── payment/
    │       │   │   ├── tax_list_screen.dart
    │       │   │   ├── payment_form_screen.dart
    │       │   │   └── payment_status_screen.dart
    │       │   └── complaint/
    │       │       ├── complaint_map_screen.dart
    │       │       └── complaint_form_screen.dart
    │       │
    │       └── widgets/
    │           └── common/
    │
    ├── ios/
    ├── android/
    ├── pubspec.yaml
    └── .env.example
```

---

## Fitur Aplikasi

> ⚠️ **Seluruh fitur bersifat simulasi** — tidak terhubung ke sistem pemerintahan nyata.

### 🔐 1. Autentikasi & Login Biometrik
- Login menggunakan username dan password
- Autentikasi biometrik (fingerprint / Face ID) via Flutter `local_auth`
- JWT token management untuk session pengguna
- Auto-refresh token dan handling session expired

### 📄 2. Pengajuan Dokumen (KTP / Paspor)
- Form pengisian data diri untuk pengajuan dokumen kependudukan
- Upload foto atau scan dokumen pendukung
- Tracking status pengajuan secara real-time

| Status | Keterangan |
|---|---|
| `SUBMITTED` | Pengajuan berhasil dikirim |
| `IN_REVIEW` | Sedang diproses |
| `APPROVED` | Dokumen disetujui |
| `REJECTED` | Dokumen ditolak beserta alasannya |

### 💰 3. Pembayaran Pajak & Retribusi
- Daftar tagihan pajak (PBB, PKB, dll.) berdasarkan akun warga
- Form pembayaran dengan input nomor tagihan atau VA
- Simulasi payment gateway dengan variasi response:
  - **Success** — Pembayaran berhasil diproses
  - **Timeout** — Gateway tidak merespons dalam batas waktu
  - **Failed** — Pembayaran gagal, notifikasi alasan kegagalan
- Riwayat transaksi pembayaran

### 🗺️ 4. Pengaduan Fasilitas Umum
- Peta interaktif berbasis Google Maps untuk menandai lokasi pengaduan
- Kategori pengaduan (Jalan Rusak, Lampu Mati, Sampah, Banjir, dll.)
- Upload foto kondisi fasilitas
- Tracking status pengaduan yang sudah dikirimkan

---

## API Endpoints

### Auth Service

| Method | Endpoint | Deskripsi |
|---|---|---|
| `POST` | `/api/v1/auth/login` | Login dengan username & password |
| `POST` | `/api/v1/auth/biometric` | Validasi biometric token |
| `POST` | `/api/v1/auth/logout` | Logout & invalidasi token |
| `POST` | `/api/v1/auth/refresh` | Refresh JWT token |
| `GET` | `/api/v1/auth/profile` | Get profil pengguna |

### Document Service

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api/v1/documents` | List pengajuan dokumen milik user |
| `POST` | `/api/v1/documents` | Buat pengajuan dokumen baru |
| `POST` | `/api/v1/documents/:id/upload` | Upload file dokumen pendukung |
| `GET` | `/api/v1/documents/:id/status` | Cek status pengajuan |

### Payment Service

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api/v1/payments/bills` | List tagihan pajak milik user |
| `POST` | `/api/v1/payments/process` | Proses pembayaran tagihan |
| `GET` | `/api/v1/payments/:id/status` | Cek status pembayaran |
| `GET` | `/api/v1/payments/history` | Riwayat pembayaran |

### Complaint Service

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/api/v1/complaints` | List pengaduan milik user |
| `POST` | `/api/v1/complaints` | Buat pengaduan baru |
| `POST` | `/api/v1/complaints/:id/upload` | Upload foto pengaduan |
| `GET` | `/api/v1/complaints/:id` | Detail pengaduan |

### Health Check

| Method | Endpoint | Deskripsi |
|---|---|---|
| `GET` | `/health` | Health check backend |

---

## Setup & Instalasi

### Prerequisites

**Backend:**
- Go 1.21+
- Docker & Docker Compose
- PostgreSQL 15+ (atau via Docker)

**Frontend:**
- Flutter SDK 3.x
- Xcode (untuk build iOS, butuh Mac)
- Android Studio (untuk build Android)
- Google Maps API Key

---

### Backend Setup

```bash
# 1. Clone repository
git clone https://github.com/your-org/govapp.git
cd govapp/backend

# 2. Copy environment file dan sesuaikan isinya
cp .env.example .env

# 3. Jalankan PostgreSQL via Docker
docker-compose up -d postgres

# 4. Install dependencies Go
go mod tidy

# 5. Jalankan database migration
go run cmd/migrate/main.go

# 6. Jalankan server
go run cmd/server/main.go
```

Server berjalan di: `http://localhost:8080`

Atau jalankan semua service sekaligus via Docker Compose:

```bash
docker-compose up -d
```

---

### Frontend (Flutter) Setup

```bash
# 1. Masuk ke folder mobile
cd govapp/mobile

# 2. Copy environment file dan sesuaikan isinya
cp .env.example .env

# 3. Install dependencies Flutter
flutter pub get

# 4. Konfigurasi Google Maps API Key
# Android → android/app/src/main/AndroidManifest.xml
# iOS     → ios/Runner/AppDelegate.swift

# 5. Jalankan di Android
flutter run -d android

# 6. Jalankan di iOS (hanya bisa di Mac dengan Xcode)
flutter run -d ios
```

---

## Environment Variables

### Backend (`.env`)

```dotenv
# Server
APP_PORT=8080
APP_ENV=development          # development | production

# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=govapp_db
DB_USER=govapp_user
DB_PASSWORD=govapp_password

# JWT
JWT_SECRET=your-super-secret-key
JWT_EXPIRY_HOURS=24

# Simulator Settings
SIMULATOR_PAYMENT_ERROR_RATE=10      # % peluang payment gagal
SIMULATOR_PAYMENT_TIMEOUT_RATE=10    # % peluang payment timeout
SIMULATOR_PAYMENT_TIMEOUT_SECS=5     # Durasi timeout simulasi (detik)
SIMULATOR_DOC_PROCESSING_SECS=10     # Simulasi durasi proses dokumen (detik)
```

### Frontend (`.env`)

```dotenv
API_BASE_URL=http://localhost:8080
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
APP_ENV=development
```

---

## Panduan Development

### Menambahkan Endpoint Baru (Backend)

1. Tambahkan model di `internal/models/`
2. Buat repository di `internal/repository/`
3. Buat business logic di `internal/services/`
4. Buat handler di `internal/handlers/`
5. Daftarkan route di `cmd/server/main.go`

### Menambahkan Screen Baru (Flutter)

1. Buat screen di `lib/presentation/screens/{feature}/`
2. Buat model Dart di `lib/data/models/`
3. Buat repository di `lib/data/repositories/`
4. Tambahkan route di `main.dart`

### Konvensi Penamaan

| Konteks | Konvensi |
|---|---|
| File Go | `snake_case.go` |
| File Dart | `snake_case.dart` |
| Struct / Class | `PascalCase` |
| Fungsi / Method | `camelCase` |
| Konstanta | `SCREAMING_SNAKE_CASE` |
| API Endpoint | `kebab-case` |

### Standard Response API

Semua response dari backend mengikuti format berikut:

```json
// Success
{
  "status": "success",
  "message": "Data berhasil diambil",
  "data": { ... }
}

// Error
{
  "status": "error",
  "message": "Deskripsi error",
  "errors": [ ... ]
}
```

---

## Catatan Penting

1. **Simulasi Penuh** — Seluruh data (tagihan pajak, status dokumen, data pengguna) adalah data dummy yang di-generate saat seed database. Tidak ada integrasi dengan sistem Dukcapil, DJP, atau instansi pemerintah lainnya.

2. **Payment Gateway** — Service payment gateway yang digunakan adalah endpoint internal yang mensimulasikan variasi response (sukses, timeout, gagal). Tidak ada transaksi keuangan nyata yang terjadi.

3. **Data Pengguna** — Gunakan data dummy saat development. Jangan memasukkan data pribadi nyata ke dalam aplikasi ini.

4. **Keamanan** — Nilai pada `.env.example` hanya untuk keperluan development lokal. Selalu gunakan secret management yang proper untuk lingkungan staging dan produksi.

---

## Referensi

- [Gin Framework Documentation](https://gin-gonic.com/docs/)
- [GORM Documentation](https://gorm.io/docs/)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Flutter local_auth](https://pub.dev/packages/local_auth)
- [Dio HTTP Client](https://pub.dev/packages/dio)