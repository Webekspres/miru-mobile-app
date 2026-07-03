# 08 — Task List: Mobile App Development Roadmap

## Fase 1: Project Setup

### 1.1 Foundation
- [ ] Install dependencies: `provider`, `dio`, `go_router`, `flutter_secure_storage`, `qr_flutter`, `cached_network_image`
- [ ] Create folder structure (`screens/`, `models/`, `providers/`, `services/`, `widgets/`)
- [ ] Create `app.dart` — MaterialApp with theme and router
- [ ] Create `config/theme.dart` — MIRU theme (green, clean design)
- [ ] Create `config/constants.dart` — API URL, app name
- [ ] Create `config/routes.dart` — go_router configuration with auth redirect
- [ ] Create `services/api_client.dart` — Dio client with interceptors
- [ ] Create `services/auth_service.dart` — Token storage and management

### 1.2 Core Models
- [ ] Create `User` model (fromJson/toJson)
- [ ] Create `KategoriSampah` model
- [ ] Create `Transaksi` model
- [ ] Create `Penjemputan` model
- [ ] Create `PenarikanSaldo` model
- [ ] Create `Reward` model
- [ ] Create `PenukaranPoin` model
- [ ] Create `Pengaduan` model

## Fase 2: Auth Flow (MVP)

- [ ] Create `AuthProvider` (login, register, logout, checkAuthStatus)
- [ ] Create `SplashScreen` — auto-check login status → redirect
- [ ] Create `LoginScreen` — username + password form
- [ ] Create `RegisterScreen` — registration form
- [ ] Implement token persistence (flutter_secure_storage)
- [ ] Implement auto-login on app start
- [ ] Implement logout with confirmation

## Fase 3: Main Screens (MVP)

### 3.1 Home/Dashboard
- [ ] Create `HomeProvider` (fetch saldo, poin, info harga, aktivitas)
- [ ] Create `HomeScreen` with:
  - [ ] Saldo card (prominent)
  - [ ] Poin display
  - [ ] Quick action buttons (Jemput, Tarik, Tukar, Info)
  - [ ] Info harga sampah (3-4 kategori)
  - [ ] Aktivitas terbaru list
  - [ ] Pull to refresh

### 3.2 Profil & Kartu Digital
- [ ] Create `ProfileScreen` — lihat/edit data diri
- [ ] Create `QRCodeScreen` — QR code ID nasabah
- [ ] Create edit profil form

### 3.3 Info Sampah
- [ ] Create `InfoSampahScreen` — list kategori dengan harga
- [ ] Create detail per kategori (contoh, panduan pemilahan)

### 3.4 Penjemputan
- [ ] Create `PenjemputanProvider`
- [ ] Create `PenjemputanScreen` — list penjemputan (tab: Aktif/Riwayat)
- [ ] Create `AjukanPenjemputanScreen` — multi-step form:
  - [ ] Pilih jenis sampah (checkboxes)
  - [ ] Input estimasi berat per jenis (min 5 kg total)
  - [ ] Pilih alamat (manual atau dari profil)
  - [ ] Pilih jadwal (date picker, min H+1)
  - [ ] Konfirmasi & submit

### 3.5 Riwayat Transaksi
- [ ] Create `SaldoProvider` (load saldo, riwayat)
- [ ] Create `RiwayatScreen` — tab: Semua, Setoran, Penarikan, Tukar Poin
- [ ] Create transaction detail view

### 3.6 Tarik Saldo
- [ ] Create `TarikSaldoScreen` — input nominal, validasi min 50rb, submit
- [ ] Show confirmation dialog

### 3.7 Reward & Tukar Poin
- [ ] Create `RewardProvider`
- [ ] Create `RewardScreen` — list reward dengan poin & stok
- [ ] Create `TukarPoinScreen` — konfirmasi penukaran

### 3.8 Pengaduan
- [ ] Create `PengaduanProvider`
- [ ] Create `PengaduanScreen` — list pengaduan (tab: Terbuka/Ditutup)
- [ ] Create `PengaduanFormScreen` — input keluhan, submit

## Fase 4: Navigation & UX Polish

- [ ] Create bottom navigation bar (Home, Riwayat, Profil)
- [ ] Create bottom sheet for quick actions
- [ ] Loading indicators for all screens
- [ ] Error handling (SnackBar untuk error messages)
- [ ] Empty state illustrations ("Belum ada transaksi")
- [ ] Pull to refresh on all list screens
- [ ] Confirmation dialogs for destructive actions

## Fase 5: Post-MVP

- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] In-app announcements section
- [ ] Dark mode support
- [ ] Biometric authentication (fingerprint/face unlock)
- [ ] Share QR code (screenshot/share intent)
- [ ] Receive notifications for:
  - [ ] Penjemputan status changes
  - [ ] Penarikan approval
  - [ ] New announcements
- [ ] Offline mode: cache last-load data (future)
- [ ] iOS adaptation (separate task when iOS is prioritized)
