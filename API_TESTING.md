# 🧪 API Testing Guide — GovApp

Panduan ini berisi contoh **request dan response** untuk setiap endpoint API.
Gunakan `curl` atau tools seperti Postman untuk menguji.

> **Base URL**: `http://localhost:8080`

---

## 1. Health Check

```bash
curl http://localhost:8080/health
```

**Response:**
```json
{"status": "ok"}
```

---

## 2. Auth Service

### 2.1 Login

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "warga1@govapp.id", "password": "password123"}'
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6..."
  }
}
```

**Response (401) — Wrong credentials:**
```json
{
  "status": "error",
  "message": "Login failed",
  "errors": ["invalid email or password"]
}
```

### 2.2 Biometric Login

```bash
curl -X POST http://localhost:8080/api/v1/auth/biometric \
  -H "Content-Type: application/json" \
  -d '{"biometric_key": "biometric_key_warga_1"}'
```

### 2.3 Get Profile (Protected)

```bash
curl http://localhost:8080/api/v1/auth/profile \
  -H "Authorization: Bearer <TOKEN>"
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Profile retrieved successfully",
  "data": {
    "id": 1,
    "nik": "3201010101010001",
    "full_name": "Budi Santoso",
    "email": "warga1@govapp.id",
    "phone": "081234567890",
    "created_at": "2026-05-06T10:00:00Z",
    "updated_at": "2026-05-06T10:00:00Z"
  }
}
```

### 2.4 Refresh Token

```bash
curl -X POST http://localhost:8080/api/v1/auth/refresh \
  -H "Authorization: Bearer <TOKEN>"
```

### 2.5 Logout

```bash
curl -X POST http://localhost:8080/api/v1/auth/logout \
  -H "Authorization: Bearer <TOKEN>"
```

---

## 3. Document Service

> Semua endpoint membutuhkan header `Authorization: Bearer <TOKEN>`

### 3.1 List Dokumen

```bash
curl http://localhost:8080/api/v1/documents \
  -H "Authorization: Bearer <TOKEN>"
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Documents retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "type": "KTP",
      "status": "SUBMITTED",
      "data": "{\"nama\": \"Budi\", \"nik\": \"320101...\"}",
      "created_at": "2026-05-06T10:00:00Z",
      "updated_at": "2026-05-06T10:00:00Z"
    }
  ]
}
```

### 3.2 Buat Pengajuan Dokumen

```bash
curl -X POST http://localhost:8080/api/v1/documents \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "KTP",
    "data": {
      "nama": "Budi Santoso",
      "nik": "3201010101010001",
      "alamat": "Jl. Merdeka No. 1"
    }
  }'
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Document created successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "type": "KTP",
    "status": "SUBMITTED",
    "data": "{...}",
    "created_at": "2026-05-06T10:00:00Z",
    "updated_at": "2026-05-06T10:00:00Z"
  }
}
```

### 3.3 Upload File Dokumen

```bash
curl -X POST http://localhost:8080/api/v1/documents/1/upload \
  -H "Authorization: Bearer <TOKEN>" \
  -F "file=@/path/to/scan_ktp.jpg"
```

### 3.4 Cek Status Dokumen

```bash
curl http://localhost:8080/api/v1/documents/1/status \
  -H "Authorization: Bearer <TOKEN>"
```

**Status Flow:** `SUBMITTED` → `IN_REVIEW` → `APPROVED` / `REJECTED`

---

## 4. Payment Service

> Semua endpoint membutuhkan header `Authorization: Bearer <TOKEN>`

### 4.1 List Tagihan

```bash
curl http://localhost:8080/api/v1/payments/bills \
  -H "Authorization: Bearer <TOKEN>"
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Bills retrieved successfully",
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "bill_type": "PBB",
      "bill_number": "PBB-2023-3201010101010001",
      "amount": 1500000,
      "status": "PENDING",
      "created_at": "2026-05-06T10:00:00Z"
    }
  ]
}
```

### 4.2 Proses Pembayaran

```bash
curl -X POST http://localhost:8080/api/v1/payments/process \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"bill_id": 1, "payment_method": "Bank Transfer"}'
```

**Response (200) — Success:**
```json
{
  "status": "success",
  "message": "Payment process completed",
  "data": {
    "id": 1,
    "status": "SUCCESS",
    "transaction_id": "TRX-1683388800-1",
    "payment_method": "Bank Transfer",
    "paid_at": "2026-05-06T10:05:00Z"
  }
}
```

> ⚠️ Hasil simulasi bisa berupa `SUCCESS`, `FAILED`, atau `TIMEOUT` tergantung config.

### 4.3 Cek Status Pembayaran

```bash
curl http://localhost:8080/api/v1/payments/1/status \
  -H "Authorization: Bearer <TOKEN>"
```

### 4.4 Riwayat Pembayaran

```bash
curl http://localhost:8080/api/v1/payments/history \
  -H "Authorization: Bearer <TOKEN>"
```

---

## 5. Complaint Service

> Semua endpoint membutuhkan header `Authorization: Bearer <TOKEN>`

### 5.1 List Pengaduan

```bash
curl http://localhost:8080/api/v1/complaints \
  -H "Authorization: Bearer <TOKEN>"
```

### 5.2 Buat Pengaduan

```bash
curl -X POST http://localhost:8080/api/v1/complaints \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "category": "JALAN_RUSAK",
    "description": "Jalan berlubang besar di depan gang",
    "address": "Jl. Merdeka No. 45, RT 01/02",
    "latitude": -6.2088,
    "longitude": 106.8456
  }'
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Complaint submitted successfully",
  "data": {
    "id": 1,
    "user_id": 1,
    "category": "JALAN_RUSAK",
    "description": "Jalan berlubang besar di depan gang",
    "latitude": -6.2088,
    "longitude": 106.8456,
    "address": "Jl. Merdeka No. 45, RT 01/02",
    "status": "SUBMITTED",
    "created_at": "2026-05-06T10:00:00Z"
  }
}
```

**Kategori yang tersedia:** `JALAN_RUSAK`, `LAMPU_MATI`, `SAMPAH`, `BANJIR`

### 5.3 Upload Foto Pengaduan

```bash
curl -X POST http://localhost:8080/api/v1/complaints/1/upload \
  -H "Authorization: Bearer <TOKEN>" \
  -F "file=@/path/to/foto_jalan.jpg"
```

### 5.4 Detail Pengaduan

```bash
curl http://localhost:8080/api/v1/complaints/1 \
  -H "Authorization: Bearer <TOKEN>"
```

---

## End-to-End Test Flow

Berikut urutan testing yang disarankan:

### Flow 1: Auth
```
1. POST /auth/login        → Simpan token
2. GET  /auth/profile       → Verifikasi profil
3. POST /auth/refresh       → Dapatkan token baru
4. POST /auth/logout        → Hapus session
```

### Flow 2: Document
```
1. POST /auth/login             → Dapatkan token
2. POST /documents              → Buat pengajuan KTP
3. GET  /documents              → Lihat list pengajuan
4. POST /documents/:id/upload   → Upload file pendukung
5. GET  /documents/:id/status   → Cek status (tunggu simulasi)
```

### Flow 3: Payment
```
1. POST /auth/login          → Dapatkan token
2. GET  /payments/bills      → Lihat tagihan PENDING
3. POST /payments/process    → Bayar tagihan
4. GET  /payments/:id/status → Cek hasil (SUCCESS/FAILED/TIMEOUT)
5. GET  /payments/history    → Lihat riwayat
```

### Flow 4: Complaint
```
1. POST /auth/login              → Dapatkan token
2. POST /complaints              → Buat pengaduan
3. POST /complaints/:id/upload   → Upload foto
4. GET  /complaints/:id          → Lihat detail
5. GET  /complaints              → Lihat semua pengaduan
```

---

## Quick Start (Docker)

```bash
cd backend

# Start semua service
docker-compose up -d

# Tunggu sampai semua service ready, lalu test:
curl http://localhost:8080/health

# Login untuk mendapatkan token:
TOKEN=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"warga1@govapp.id","password":"password123"}' | jq -r '.data.token')

# Gunakan token untuk request lainnya:
curl http://localhost:8080/api/v1/auth/profile \
  -H "Authorization: Bearer $TOKEN"
```

---

## Dummy Users

| Email | Password | NIK | Biometric Key |
|---|---|---|---|
| warga1@govapp.id | password123 | 3201010101010001 | biometric_key_warga_1 |
| warga2@govapp.id | password123 | 3201010101010002 | biometric_key_warga_2 |
