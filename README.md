# MIRU Bank Sampah — Mobile App (Miru-G)

Aplikasi mobile Android untuk **nasabah/masyarakat** program Bank Sampah digital Distrik Mimika Baru. Dibangun dengan Flutter.

## Target Pengguna

| Role | Akses Mobile |
|------|--------------|
| **Nasabah** | ✅ Pengguna utama — registrasi, setor/jemput, saldo, reward, pengaduan |
| Petugas, Admin, Koordinator, Distrik | ❌ Gunakan repositori **miru-web-admin** |
| Mitra/Pengepul | ❌ Tidak punya login |

## Tech Stack

| Komponen | Teknologi | Status |
|----------|-----------|--------|
| Framework | Flutter 3.x (Dart SDK ^3.12.2) | ✅ Scaffold |
| State Management | Provider | 🔲 Perlu ditambahkan |
| HTTP Client | Dio | 🔲 Perlu ditambahkan |
| Secure Storage | flutter_secure_storage | 🔲 Perlu ditambahkan |
| Routing | go_router | 🔲 Perlu ditambahkan |
| QR Code | qr_flutter | 🔲 Perlu ditambahkan |
| Backend | Django REST API — repositori **miru-backend-api** | ✅ Tersedia |

## Prerequisites

- Flutter SDK 3.x ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio / Android SDK (target utama: Android)
- Backend MIRU berjalan (clone & setup repositori **miru-backend-api**)

## Local Development

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Konfigurasi API URL

`lib/config/constants.dart` mendefinisikan `apiBaseUrl` (termasuk prefix `/api`).

| Environment | Base URL | Cara set |
|-------------|----------|----------|
| Android Emulator (default) | `http://10.0.2.2:8000/api` | Tidak perlu konfigurasi tambahan |
| iOS Simulator | `http://localhost:8000/api` | `--dart-define=API_BASE_URL=http://localhost:8000/api` |
| Device fisik (LAN) | `http://<IP-komputer>:8000/api` | `--dart-define=API_BASE_URL=http://192.168.x.x:8000/api` |
| Production | `https://api.mirubanksampah.id/api` (usulan) | `--dart-define` saat build release |

**Emulator Android** — `10.0.2.2` adalah alias ke localhost mesin host. Jalankan backend dengan `runserver 0.0.0.0:8000`.

**Device fisik** — HP dan komputer harus satu jaringan Wi-Fi/LAN. Cari IP komputer (`ipconfig` di Windows, `ip a` di Linux). Contoh run:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8000/api
```

Pastikan backend `ALLOWED_HOSTS` dan CORS mengizinkan origin tersebut.

### 3. Jalankan Backend & Seed Data

```bash
# Di repositori miru-backend-api (clone terpisah)
python manage.py migrate
python manage.py seed_data --minimal --flush
python manage.py runserver 0.0.0.0:8000
```

### 4. Run App

```bash
# Di repositori mirumobileapp (repo ini)
flutter run
```

### 5. Akun Demo (Registrasi atau Seed Full)

Mode full seed backend:

| Username | Password | Role |
|----------|----------|------|
| `nasabah001` | `nasabah123` | nasabah |

Atau daftar akun baru via `POST /api/users/` (registrasi publik nasabah).

## Integrasi Backend API

Mobile app berkomunikasi **hanya** dengan backend REST API via Dio.

### Autentikasi

```
POST /api/auth/login/     → { access, refresh, user }
POST /api/auth/refresh/   → { access }
GET  /api/auth/me/        → profil + saldo + poin
POST /api/users/          → registrasi nasabah (public)
```

Token disimpan di `flutter_secure_storage`, dikirim via interceptor:

```
Authorization: Bearer <access_token>
```

### Format Response — JSON Envelope

```json
{
  "success": true,
  "status_code": 200,
  "message": "Profil berhasil diambil.",
  "data": {
    "id": 1,
    "nama_lengkap": "Budi Santoso",
    "saldo": "125000.00",
    "poin": 125
  },
  "meta": { "timestamp": "...", "request_id": "..." }
}
```

Parser mobile **wajib** mengambil payload dari field `data`.

### Endpoint Mobile

| Fitur | Method | Endpoint |
|-------|--------|----------|
| Login | POST | `/api/auth/login/` |
| Register | POST | `/api/users/` |
| Profil | GET | `/api/auth/me/` |
| Kategori sampah | GET | `/api/waste-categories/` (public) |
| Ajukan penjemputan | POST | `/api/pickups/` |
| Riwayat setoran | GET | `/api/deposits/?nasabah={id}` |
| Ajukan penarikan | POST | `/api/withdrawals/` |
| Katalog reward | GET | `/api/rewards/` |
| Tukar poin | POST | `/api/reward-redemptions/` |
| Pengaduan | POST/GET | `/api/complaints/` |

Detail lengkap: [`.ai-steering/04-api-integration.md`](.ai-steering/04-api-integration.md)

## Struktur Folder (Target)

```
mirumobileapp/
├── .ai-steering/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/           # theme, routes, constants
│   ├── models/           # fromJson/toJson
│   ├── providers/        # ChangeNotifier
│   ├── services/         # api_client, auth_service
│   ├── screens/          # UI per fitur
│   └── widgets/          # Reusable widgets
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

## Fitur MVP (Nasabah)

| Fitur | Screen |
|-------|--------|
| Login & Registrasi | `LoginScreen`, `RegisterScreen` |
| Dashboard | `HomeScreen` — saldo, poin, quick actions |
| Kartu Digital | `QRCodeScreen` — QR ID nasabah |
| Info Sampah | `InfoSampahScreen` — harga per kategori |
| Penjemputan | `PenjemputanScreen` — ajukan & cek status |
| Riwayat | `RiwayatScreen` — setoran, penarikan, penukaran |
| Tarik Saldo | `TarikSaldoScreen` |
| Reward | `RewardScreen` — tukar poin |
| Pengaduan | `PengaduanScreen` |

## Dokumentasi Proyek

| File | Isi |
|------|-----|
| [`.ai-steering/01-project-overview.md`](.ai-steering/01-project-overview.md) | Konteks bisnis & ekosistem |
| [`.ai-steering/04-api-integration.md`](.ai-steering/04-api-integration.md) | Dio client & envelope |
| [`.ai-steering/10-integration-and-roles.md`](.ai-steering/10-integration-and-roles.md) | Alur nasabah & batasan role |
| [`.ai-steering/07-modules-and-features.md`](.ai-steering/07-modules-and-features.md) | Wireframe & modul mobile |
| [`.ai-steering/08-task-list.md`](.ai-steering/08-task-list.md) | Roadmap pengembangan |
| [`.ai-steering/12-play-internal-testing.md`](.ai-steering/12-play-internal-testing.md) | Play Internal testing (UAT stakeholder) |

Repositori terkait (GitHub terpisah): **miru-backend-api** (API), **miru-web-admin** (panel staff).

## Scripts

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter test             # Run tests
flutter build apk        # Build Android APK
flutter analyze          # Static analysis
```

## Status Proyek

Proyek ini **belum dikerjakan** (scaffold Flutter default). Backend API sudah tersedia. Ikuti roadmap di `.ai-steering/08-task-list.md`.

## Branding

- **Nama:** MIRU Bank Sampah (Miru-G)
- **Slogan:** "Sampah Bernilai, Lingkungan Bersih, Warga Sejahtera"
- **Warna tema:** Hijau `#16a34a`
- **Bahasa UI:** Bahasa Indonesia
- **Platform prioritas:** Android → iOS (post-MVP)

## Batasan Penting

- **Tidak ada** payment gateway — penarikan saldo diproses manual admin
- **Tidak ada** GPS live tracking — status penjemputan diupdate petugas
- **Online-first** — koneksi internet diperlukan (MVP)
- **Hanya nasabah** yang boleh login di mobile

Lihat [`.ai-steering/06-system-constraints.md`](.ai-steering/06-system-constraints.md)
