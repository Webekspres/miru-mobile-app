# 08 — Task List: Mobile App Development Roadmap

> **Roadmap backend (dependensi):** repositori **miru-backend-api** — `.ai-steering/08-task-list.md`
>
> Mobile app adalah **prioritas ketiga**. Mulai setelah web admin MVP operasional (atau parallel setelah backend Fase 2–3 stabil).

---

## Ringkasan Fase

| Fase | Nama | Tujuan | Status |
|------|------|--------|--------|
| 0 | Scaffold | Flutter project default | ✅ Selesai |
| 1 | Foundation | Dependencies, folder structure, API client | 🔲 Berikutnya |
| 2 | Auth Flow | Login, register, JWT persistence | 🔲 |
| 3 | MVP Screens | Home, profil, penjemputan, saldo, reward, pengaduan | 🔲 |
| 4 | Navigation & UX | Bottom nav, polish, error states | 🔲 |
| 5 | Post-MVP | Push notif, iOS, offline cache | 🔲 |

---

## Dependensi Backend per Fase Mobile

| Fase Mobile | Backend Minimum |
|-------------|-----------------|
| Fase 1–2 | Fase 1 ✅ (auth, register, `/api/auth/me/`) |
| Fase 3 | Fase 2–3 (pickups workflow, withdrawals validation, complaints) |
| Push notifications | Post-MVP backend + FCM setup |
| Pengumuman in-app | Backend Fase 5 (`/api/settings/`) |

---

## Fase 0: Scaffold ✅ Selesai

- [x] Create Flutter project (Dart ^3.12.2)
- [x] Android/iOS folder structure
- [x] Dokumentasi `.ai-steering/` selaras backend

## Fase 1: Project Setup

### 1.1 Dependencies
- [ ] Add to `pubspec.yaml`: `provider`, `dio`, `go_router`, `flutter_secure_storage`, `qr_flutter`, `intl`
- [ ] Create folder structure (`config/`, `models/`, `providers/`, `services/`, `screens/`, `widgets/`)

### 1.2 Core Infrastructure
- [ ] `config/constants.dart` — API URL (`10.0.2.2:8000` emulator)
- [ ] `config/theme.dart` — MIRU green theme `#16a34a`
- [ ] `config/routes.dart` — go_router + auth redirect
- [ ] `services/api_client.dart` — Dio + Envelope + Auth interceptors (`04-api-integration.md`)
- [ ] `services/auth_service.dart` — token storage, login, register, me

### 1.3 Models
- [ ] `User`, `WasteCategory`, `Deposit`, `Pickup`, `Withdrawal`, `Reward`, `RewardRedemption`, `Complaint`
- [ ] fromJson/toJson dengan `snake_case` mapping

## Fase 2: Auth Flow

- [ ] `AuthProvider` — login guard role `nasabah` only
- [ ] `SplashScreen` — auto-check token → `/home` or `/login`
- [ ] `LoginScreen` — `POST /api/auth/login/`
- [ ] `RegisterScreen` — `POST /api/users/` + auto login
- [ ] Token persistence (`flutter_secure_storage`)
- [ ] Auto refresh token on 401
- [ ] Logout with confirmation

## Fase 3: Main Screens (MVP)

### 3.1 Home/Dashboard
- [ ] `HomeProvider` — `GET /api/auth/me/`, `GET /api/waste-categories/`
- [ ] Saldo card, poin, quick actions, info harga, aktivitas terbaru
- [ ] Pull to refresh

### 3.2 Profil & QR
- [ ] `ProfileScreen` — view/edit `PATCH /api/users/{id}/`
- [ ] `QRCodeScreen` — encode `{id, nama_lengkap, no_hp}`

### 3.3 Info Sampah
- [ ] `InfoSampahScreen` — list kategori public endpoint

### 3.4 Penjemputan
- [ ] `PenjemputanScreen` — list + tabs
- [ ] `AjukanPenjemputanScreen` — form (min 5 kg, H+1 jadwal)
- [ ] `POST /api/pickups/`

### 3.5 Riwayat & Tarik Saldo
- [ ] `RiwayatScreen` — deposits, withdrawals, redemptions
- [ ] `TarikSaldoScreen` — min Rp50.000, `POST /api/withdrawals/`

### 3.6 Reward
- [ ] `RewardScreen` — `GET /api/rewards/`
- [ ] Tukar poin — `POST /api/reward-redemptions/`

### 3.7 Pengaduan
- [ ] `PengaduanScreen` + form — `POST/GET /api/complaints/`

## Fase 4: Navigation & UX Polish

- [ ] Bottom navigation (Home, Riwayat, Profil)
- [ ] Loading, error, empty states semua screen
- [ ] SnackBar error Bahasa Indonesia
- [ ] Confirmation dialogs
- [ ] Network error handling (offline message)

## Fase 5: Post-MVP

- [ ] Firebase Cloud Messaging
- [ ] In-app announcements
- [ ] Biometric unlock (optional)
- [ ] iOS build & adaptation
- [ ] Offline cache (future)

---

## Referensi Dokumentasi

| Dokumen | Kegunaan |
|---------|----------|
| `04-api-integration.md` | Dio client & endpoints |
| `10-integration-and-roles.md` | Alur nasabah & integrasi web admin |
| `07-modules-and-features.md` | Wireframe halaman |
| `05-business-rules-sops.md` | Validasi form |
| `06-system-constraints.md` | Batasan (no GPS, no payment) |

Repositori terkait: **miru-backend-api**, **miru-web-admin** (GitHub terpisah).

---

## Testing Checklist

- [ ] Backend running: `python manage.py runserver 0.0.0.0:8000`
- [ ] Seed: `python manage.py seed_data --flush`
- [ ] Login: `nasabah001` / `nasabah123`
- [ ] Test di Android Emulator (`10.0.2.2`)
- [ ] Test registrasi akun baru
- [ ] Verify envelope parsing (saldo, poin update setelah setoran petugas)
