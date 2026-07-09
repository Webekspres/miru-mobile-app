# 08 — Task List: Mobile App Development Roadmap

> **Dokumen ini** adalah roadmap pengembangan **mirumobileapp** dari scaffold hingga production-ready (Android prioritas).
> Urutan task mengikuti dependensi **miru-backend-api**; mobile adalah **prioritas ketiga** setelah web admin operasional.
>
> **Referensi terkait (repo ini):**
> - `04-api-integration.md` — Dio client & JSON Envelope
> - `07-modules-and-features.md` — wireframe & 14 fitur nasabah
> - `10-integration-and-roles.md` — alur nasabah & integrasi staff
>
> **Referensi backend (repositori terpisah):**
> - **miru-backend-api** — `.ai-steering/08-task-list.md` (roadmap API)
> - **miru-backend-api** — `.ai-steering/04-api-contracts-and-standards.md` (kontrak endpoint)
> - **miru-backend-api** — `.ai-steering/07-modules-and-features.md` (17 modul sistem)

---

## Ringkasan Fase

| Fase | Nama | Tujuan | Backend Min. | Status |
|------|------|--------|--------------|--------|
| 0 | Scaffold | Flutter project default | — | ✅ Selesai |
| 1 | Foundation | Dependencies, API client, models | Backend Fase 1 ✅ | 🔲 Berikutnya |
| 2 | Auth Flow | Login, register, JWT, splash | Backend Fase 1 ✅ | 🔲 |
| 3 | MVP Screens | Home, profil, jemput, saldo, reward, pengaduan | Backend Fase 2–3 | ✅ Selesai |
| 4 | Navigation & UX | Bottom nav, polish, error states | Backend Fase 2–3 | ✅ Selesai |
| 5 | Settings & Info | Pengumuman, kebijakan, jam layanan | Backend Fase 5 | 🔲 |
| 6 | Kualitas & Testing | Widget test, integration, UAT | Backend Fase 6 | 🔲 |
| 7 | Production Android | APK/AAB, Play Store prep | Backend Fase 7 | 🔲 |
| 8 | Post-MVP | FCM, iOS, offline cache | Backend Fase 8 | 🔲 |

---

## Cakupan Modul — Mobile (Nasabah)

Dari 17 modul sistem, **10 modul** diimplementasikan di mobile (sisanya staff-only di **miru-web-admin**).

| No | Modul | Screen | Fase | Backend API |
|----|-------|--------|------|-------------|
| 2 | Autentikasi | `LoginScreen`, `RegisterScreen`, `SplashScreen` | Fase 2 | `/api/auth/*`, `POST /api/users/` |
| 3 | Profil & QR | `ProfileScreen`, `QRCodeScreen` | Fase 3 | `/api/auth/me/`, `PATCH /api/users/{id}/` |
| 4 | Info & Edukasi | `InfoSampahScreen` | Fase 3 | `GET /api/waste-categories/` (public) |
| 5 | Katalog Harga | (bagian InfoSampah & Home) | Fase 3 | `GET /api/waste-categories/` |
| 7 | Penjemputan | `PenjemputanScreen`, `AjukanPenjemputanScreen` | Fase 3 | `/api/pickups/` |
| 9 | Saldo & Riwayat | `RiwayatScreen`, `HomeScreen` | Fase 3 | `/api/deposits/`, `/api/activity/` |
| 10 | Tarik Saldo | `TarikSaldoScreen` | Fase 3 | `/api/withdrawals/` |
| 11 | Poin & Reward | `RewardScreen`, `TukarPoinScreen` | Fase 3 | `/api/rewards/`, `/api/reward-redemptions/` |
| 14 | Pengaduan | `PengaduanScreen`, `PengaduanFormScreen` | Fase 3 | `/api/complaints/` |
| 15 | Dashboard | `HomeScreen` | Fase 3 | `/api/auth/me/`, waste-categories |
| 17 | Settings | `SettingsScreen` | Fase 5 | `/api/settings/`, `/api/pengumuman/` |

Modul **tidak ada** di mobile: 1, 6, 8, 12, 13, 16 (staff/admin only).

---

## Matriks Dependensi Backend → Mobile

| Backend Fase (miru-backend-api) | Fitur API | Task Mobile yang Unblock |
|---------------------------------|-----------|--------------------------|
| Fase 1 ✅ | Auth, register, me, waste-categories public | Fase 1–2, InfoSampah, Home (partial) |
| Fase 2 | Validasi penjemputan, penarikan, penukaran | Fase 3 forms dengan error bisnis benar |
| Fase 3 | Pickup workflow, activity feed, approve flows | Fase 3 status jemput real-time, riwayat gabungan |
| Fase 5 | Settings, pengumuman | Fase 5 announcements |
| Fase 8 | Push notification trigger | Fase 8 FCM |

| Backend Fase | Integrasi Staff (miru-web-admin) |
|--------------|----------------------------------|
| Fase 2–3 | Petugas input setoran → nasabah lihat saldo di Home |
| Fase 2–3 | Admin approve penarikan → status update di Riwayat |
| Fase 2–3 | Petugas update penjemputan → badge status di PenjemputanScreen |

---

## Fase 0: Scaffold ✅ Selesai

### 0.1 Project Setup ✅
- [x] Create Flutter project (`mirumobileapp`, Dart ^3.12.2)
- [x] Android/iOS folder structure
- [x] `flutter_lints` configured
- [x] Dokumentasi `.ai-steering/` selaras **miru-backend-api**

---

## Fase 1: Foundation

> **Backend:** Fase 1 ✅
> **Tujuan:** Arsitektur Provider + Dio + go_router siap.

### 1.1 Dependencies (`pubspec.yaml`)
- [x] `provider` — state management
- [x] `dio` — HTTP client
- [x] `go_router` — declarative routing
- [x] `flutter_secure_storage` — token storage
- [x] `qr_flutter` — QR code kartu digital
- [x] `intl` — format Rupiah & tanggal Indonesia
- [x] `cached_network_image` (opsional) — logo/avatar
- [x] Run `flutter pub get`

### 1.2 Folder Structure
- [x] `lib/config/` — constants, theme, routes
- [x] `lib/models/` — data classes
- [x] `lib/services/` — api_client, auth_service, storage_service
- [x] `lib/providers/` — ChangeNotifier per domain
- [x] `lib/screens/` — UI per fitur
- [x] `lib/widgets/` — reusable widgets
- [x] `lib/app.dart` — MaterialApp + MultiProvider
- [x] Refactor `main.dart` → entry point minimal

### 1.3 Config & Theme
- [x] `config/constants.dart` — `apiBaseUrl` (10.0.2.2 emulator, LAN IP device)
- [x] `config/theme.dart` — Material 3, primary `#16a34a`, typography
- [x] `config/routes.dart` — go_router routes + auth redirect
- [x] Environment notes di README (emulator vs device fisik)

### 1.4 API Client (Modul 2 — infrastruktur)
- [x] `services/api_client.dart` — Dio instance, timeouts
- [x] `EnvelopeInterceptor` — unwrap `data`, throw on `success: false`
- [x] `AuthInterceptor` — attach Bearer token
- [x] Refresh token on 401 → retry request
- [x] `services/auth_service.dart` — login, register, logout, getMe, token R/W
- [x] `services/storage_service.dart` — wrapper secure storage
- [x] `models/api_envelope.dart` — parse envelope (fallback jika no interceptor)

### 1.5 Core Models
- [x] `models/user.dart` — fromJson, saldo as String → double helper
- [x] `models/waste_category.dart`
- [x] `models/deposit.dart` + `deposit_detail.dart`
- [x] `models/pickup.dart` — status enum + badge color
- [x] `models/withdrawal.dart`
- [x] `models/reward.dart`, `models/reward_redemption.dart`
- [x] `models/complaint.dart`
- [x] `models/activity_item.dart` — untuk riwayat gabungan *(backend Fase 3.5)*

### 1.6 Shared Widgets
- [x] `widgets/loading_indicator.dart`
- [x] `widgets/error_view.dart` — message + retry
- [x] `widgets/empty_state.dart`
- [x] `widgets/saldo_card.dart` — prominent saldo display
- [x] `widgets/status_badge.dart` — penjemputan/pengaduan status
- [x] `widgets/app_scaffold.dart` — AppBar konsisten MIRU

---

## Fase 2: Auth Flow (Modul 2)

> **Backend:** Fase 1 ✅ — `POST /api/auth/login/`, `POST /api/users/`, `GET /api/auth/me/`
> **Tujuan:** Nasabah bisa daftar & login; staff ditolak.

### 2.1 AuthProvider
- [x] `providers/auth_provider.dart` — user, isLoggedIn, isLoading, error
- [x] `login(username, password)` → guard `role == nasabah`
- [x] `register(data)` → `POST /api/users/` + auto login
- [x] `logout()` — clear storage, navigate login
- [x] `checkAuthStatus()` — splash auto-login
- [x] Reject non-nasabah: "Akun petugas/admin hanya untuk Web Admin MIRU"

### 2.2 SplashScreen
- [x] Logo MIRU + loading
- [x] Cek token → `GET /api/auth/me/` → `/home` atau `/login`
- [x] Handle expired token gracefully

### 2.3 LoginScreen
- [x] Form username + password
- [x] Validasi: field tidak kosong
- [x] `POST /api/auth/login/`
- [x] Error SnackBar dari envelope `message`
- [x] Link ke RegisterScreen
- [x] Loading disable button

### 2.4 RegisterScreen
- [x] Field: nama_lengkap, username, password, no_hp, alamat
- [x] NIK opsional
- [x] Checkbox `setuju_kebijakan_data` — required *(backend Fase 5.5)*
- [x] Validasi password min 6 karakter
- [x] `POST /api/users/` → success → login → Home
- [x] Tampilkan error field-level dari `envelope.errors`

### 2.5 Auth Routing
- [x] go_router redirect: unauthenticated → `/login`
- [x] Deep link guard — no access without token
- [x] Back button behavior dari auth screens

---

## Fase 3: MVP Screens

> **Backend:** Fase 2–3 — validasi bisnis & workflow
> **Tujuan:** Semua fitur nasabah MVP berfungsi end-to-end.

### 3.1 HomeScreen / Dashboard (Modul 15, 5, 9)
- [x] `providers/home_provider.dart`
- [x] `GET /api/auth/me/` — saldo, poin
- [x] `GET /api/waste-categories/` — 3–4 kategori top untuk info harga
- [x] `GET /api/activity/?limit=3` atau aggregate deposits *(backend Fase 3.5)*
- [x] UI: Saldo card (besar), poin, quick actions grid
- [x] Quick actions: [Jemput] [Tarik] [Tukar] [Info Sampah]
- [x] Aktivitas terbaru list (3 item)
- [x] Pull-to-refresh
- [x] Banner jam layanan Sen–Sab 08–17 WIT jika di luar jam

### 3.2 Profil & Kartu Digital (Modul 3)
- [x] `screens/profile/profile_screen.dart` — lihat data diri
- [x] `GET /api/auth/me/`
- [x] Form edit: nama, no_hp, alamat — `PATCH /api/users/{id}/`
- [x] Validasi: tidak bisa ubah saldo/poin/role
- [x] `screens/profile/qrcode_screen.dart`
- [x] QR encode JSON: `{ id, nama_lengkap, no_hp }` — **bukan JWT**
- [x] Tombol share/screenshot QR *(post-MVP)*

### 3.3 Info Sampah (Modul 4, 5)
- [x] `screens/info/info_sampah_screen.dart`
- [x] `GET /api/waste-categories/` — public, no auth required
- [x] List: nama, harga/kg, contoh sampah
- [x] Detail bottom sheet: panduan pemilahan singkat
- [x] Catatan: minimal setoran 1 kg per jenis

### 3.4 Penjemputan (Modul 7)
- [x] `providers/penjemputan_provider.dart`
- [x] `screens/penjemputan/penjemputan_screen.dart` — tabs Aktif | Riwayat
- [x] `GET /api/pickups/?nasabah={id}`
- [x] Status badge warna (`05-business-rules-sops.md`)
- [x] FAB / button [+ Ajukan]
- [x] `screens/penjemputan/ajukan_penjemputan_screen.dart`
- [x] Multi-select jenis sampah (dari kategori)
- [x] Input estimasi berat — validasi min **5 kg** total
- [x] Alamat penjemputan (prefill dari profil)
- [x] Date picker jadwal — min **H+1**
- [x] `POST /api/pickups/`
- [x] Konfirmasi success → kembali ke list
- [x] Pull-to-refresh status

### 3.5 Riwayat Transaksi (Modul 9)
- [x] `providers/saldo_provider.dart`
- [x] `screens/riwayat/riwayat_screen.dart` — tabs: Semua | Setoran | Penarikan | Poin
- [x] `GET /api/deposits/?nasabah={id}`
- [x] `GET /api/withdrawals/?nasabah={id}`
- [x] `GET /api/reward-redemptions/?nasabah={id}`
- [x] Atau `GET /api/activity/` unified *(backend Fase 3.5)*
- [x] Item: tanggal, jenis, nominal, status
- [x] Detail tap → bottom sheet
- [x] Pull-to-refresh

### 3.6 Tarik Saldo (Modul 10)
- [x] `screens/saldo/tarik_saldo_screen.dart`
- [x] Tampilkan saldo saat ini dari auth/me
- [x] Input nominal — validasi min **Rp50.000**
- [x] Validasi client: nominal <= saldo
- [x] Pilih metode (tunai — default)
- [x] Dialog konfirmasi
- [x] `POST /api/withdrawals/`
- [x] Info SLA: proses 1–2 hari kerja, **tanpa payment gateway**
- [x] Success → riwayat penarikan

### 3.7 Reward & Tukar Poin (Modul 11)
- [x] `providers/reward_provider.dart`
- [x] `screens/reward/reward_screen.dart` — list katalog
- [x] `GET /api/rewards/`
- [x] Tampilkan poin user, poin_dibutuhkan, stok
- [x] Disable [Tukar] jika poin tidak cukup atau stok 0
- [x] `screens/reward/tukar_poin_screen.dart` — konfirmasi
- [x] `POST /api/reward-redemptions/`
- [x] Status menunggu → admin approve di **miru-web-admin**
- [x] Riwayat penukaran di tab Riwayat

### 3.8 Pengaduan (Modul 14)
- [x] `providers/pengaduan_provider.dart`
- [x] `screens/pengaduan/pengaduan_screen.dart` — tabs Terbuka | Selesai
- [x] `GET /api/complaints/?nasabah={id}`
- [x] `screens/pengaduan/pengaduan_form_screen.dart`
- [x] Field keluhan (multiline), jenis pengaduan *(backend Fase 2.7)*
- [x] `POST /api/complaints/`
- [x] Detail: tindak lanjut admin (read-only)
- [x] Badge status terbuka/ditutup

---

## Fase 4: Navigation & UX Polish

> **Tujuan:** App terasa native, intuitif untuk masyarakat Mimika.

### 4.1 Navigation
- [x] Bottom navigation bar: Home | Riwayat | Profil
- [x] go_router nested navigation (`StatefulShellRoute`)
- [x] Back stack behavior konsisten
- [x] Deep links internal (home → tarik saldo → back)

### 4.2 UX Polish
- [x] Loading state semua screen async — `LoadingIndicator` di semua screen
- [x] Error SnackBar Bahasa Indonesia — `parseDioError()` dengan pesan Indonesia
- [x] Empty state ilustrasi sederhana per screen — `EmptyState` di semua screen list
- [x] Confirmation dialog: tarik saldo, tukar poin, logout — logout via ProfileScreen
- [x] Network error: "Tidak dapat terhubung ke server" — di `parseDioError()`
- [x] Pull-to-refresh semua list screens — `RefreshIndicator` di 7 screen
- [x] Format angka Rupiah konsisten (`intl`) — `NumberFormat.currency(locale: 'id_ID')`
- [x] Format tanggal Indonesia — `DateFormat` + `initializeDateFormatting('id_ID')`

### 4.3 Performance
- [x] `const` widgets where possible — sudah diterapkan di seluruh screen
- [x] `ListView.builder` untuk list panjang — di riwayat, penjemputan, pengaduan, reward; InfoSampahScreen di-refactor ke `SliverChildBuilderDelegate`
- [x] Avoid unnecessary provider rebuilds (`Consumer` scoped) — pattern `Consumer`/`Consumer2` sudah sesuai

---

## Fase 5: Settings & Informasi (Modul 17)

> **Backend:** Fase 5 — `/api/settings/`, `/api/pengumuman/`
> **Tujuan:** Info institusi & pengumuman di app.

### 5.1 SettingsScreen
- [ ] Menu: Profil, Pengumuman, Kebijakan Data, Tentang, Logout
- [ ] `GET /api/settings/` — nama institusi, kontak, jam operasional
- [ ] Link ke ProfileScreen, QRCodeScreen

### 5.2 Pengumuman
- [ ] `screens/settings/pengumuman_screen.dart`
- [ ] `GET /api/pengumuman/` — list aktif
- [ ] Card: judul, tanggal, isi singkat
- [ ] Detail pengumuman

### 5.3 Kebijakan Data
- [ ] Static page kebijakan data pribadi (UU PDP)
- [ ] Tampilkan saat registrasi + link di settings

---

## Fase 6: Kualitas & Testing

> **Backend:** Fase 6 tested
> **Tujuan:** App siap UAT dengan nasabah pilot.

### 6.1 Automated Tests
- [ ] `test/models/user_test.dart` — fromJson saldo string
- [ ] `test/services/api_envelope_test.dart` — parse success/error
- [ ] `test/providers/auth_provider_test.dart` — mock dio
- [ ] Widget test LoginScreen — form validation
- [ ] Widget test TarikSaldoScreen — min 50rb validation

### 6.2 Manual / UAT Checklist
- [ ] Registrasi akun baru → login → home
- [ ] Login akun demo `nasabah001` / `nasabah123`
- [ ] Ajukan penjemputan → cek status setelah petugas update (**miru-web-admin**)
- [ ] Tarik saldo → approve admin → saldo berkurang di home
- [ ] Tukar poin → approve admin → poin berkurang
- [ ] Ajukan pengaduan → admin tindak lanjut → status ditutup
- [ ] QR code discan petugas → setoran → saldo naik di home refresh
- [ ] Test Android emulator (`10.0.2.2:8000`)
- [ ] Test device fisik via LAN IP

### 6.3 Edge Cases
- [ ] Token expired mid-session
- [ ] Server 500 → pesan ramah
- [ ] Double tap submit prevention
- [ ] App background/foreground token restore

---

## Fase 7: Production Android

> **Backend:** Fase 7 — production API HTTPS
> **Tujuan:** Rilis Google Play Store.

### 7.1 Build Configuration
- [ ] `constants.dart` production URL `https://api.mirubanksampah.id`
- [ ] App name, icon, splash screen MIRU branding
- [ ] `android/app/build.gradle` — versionCode, versionName
- [ ] ProGuard/R8 rules jika perlu
- [ ] `flutter build apk --release`
- [ ] `flutter build appbundle` — untuk Play Store

### 7.2 Play Store Preparation
- [ ] Privacy policy URL
- [ ] Screenshot  phone & tablet
- [ ] Deskripsi Bahasa Indonesia
- [ ] Content rating questionnaire
- [ ] Internal testing track upload
- [ ] Akun Google Play Console dari klien

### 7.3 Security
- [ ] Certificate pinning *(evaluasi post-MVP)*
- [ ] No sensitive data in logs (release)
- [ ] Secure storage verified on Android

---

## Fase 8: Post-MVP

> **Backend:** Fase 8
> **Tujuan:** Peningkatan setelah go-live.

### 8.1 Push Notifications
- [ ] Firebase project setup
- [ ] `firebase_messaging` integration
- [ ] Handle: penjemputan status change, penarikan approved, pengumuman baru
- [ ] Backend trigger API *(miru-backend-api Fase 8.1)*

### 8.2 iOS
- [ ] iOS build configuration
- [ ] App Store Connect setup
- [ ] TestFlight beta
- [ ] Adapt UI safe area / Cupertino where needed

### 8.3 Enhancements
- [ ] Biometric unlock (optional)
- [ ] Share QR code intent
- [ ] Offline cache last-loaded saldo *(future)*
- [ ] Lupa password flow *(butuh backend endpoint)*
- [ ] In-app rating prompt

### 8.4 Yang TIDAK BOLEH Diimplementasikan
- [ ] ❌ Login petugas/admin/koordinator
- [ ] ❌ Input setoran sampah (petugas di web admin)
- [ ] ❌ Payment gateway / e-wallet integration
- [ ] ❌ GPS live tracking penjemputan
- [ ] ❌ Scan KTP / face recognition registrasi
- [ ] ❌ Integrasi Dukcapil NIK validation

---

## Urutan Sprint (Selaras Backend & Web Admin)

| Sprint | Backend | Web Admin | Mobile |
|--------|---------|-----------|--------|
| 1 | Fase 1 ✅ | Foundation + Auth | Fase 1–2 Foundation + Auth |
| 2 | Fase 2.1–2.2 Setoran | Input setoran | Home + Info Sampah + Profil |
| 3 | Fase 2.3–2.5 Workflow | Penjemputan, tarik, pengaduan | Penjemputan + Tarik + Reward |
| 4 | Fase 2.6–3 E2E | Manajemen & stok | Riwayat + Pengaduan + UX polish |
| 5 | Fase 4 Dashboard | Monitoring UI | — (stabilisasi mobile) |
| 6 | Fase 5–6 Governance | Settings, QA | Fase 5–6 Settings, testing |
| 7 | Fase 7 Production | Deploy | Fase 7 Play Store |
| Post | Fase 8 | Post-MVP | FCM, iOS |

---

## Definisi "Selesai" per Tahap

| Tahap | Kriteria Selesai (Mobile) |
|-------|---------------------------|
| **Auth Ready** | Fase 1–2; nasabah register & login |
| **MVP Nasabah** | Fase 3–4; semua fitur core + UX polish |
| **UAT Ready** | Fase 6; checklist UAT lulus dengan backend + web admin |
| **Play Store Beta** | Fase 7; internal testing track live |
| **Go-Live** | Production API + app published |

---

## Checklist Integrasi End-to-End (Mobile ↔ Backend ↔ Web Admin)

| # | Alur Nasabah (Mobile) | Aksi Staff (miru-web-admin) | API Backend |
|---|----------------------|----------------------------|-------------|
| 1 | Register & login | — | Fase 1 ✅ |
| 2 | Lihat saldo di Home | Petugas input setoran | Fase 2–3 |
| 3 | Tunjukkan QR | Petugas scan → setoran | Fase 2–3 |
| 4 | Ajukan penjemputan | Approve & update status | Fase 2–3 |
| 5 | Ajukan tarik saldo | Admin approve manual | Fase 2–3 |
| 6 | Tukar poin | Admin serahkan & approve | Fase 2–3 |
| 7 | Ajukan pengaduan | Admin tindak lanjut | Fase 2–3 |
| 8 | Lihat pengumuman | Admin publish | Fase 5 |
| 9 | Refresh riwayat | — | Fase 3.5 activity |

---

## Environment Testing

| Target | API Base URL | Backend Command |
|--------|--------------|-----------------|
| Android Emulator | `http://10.0.2.2:8000` | `runserver` di **miru-backend-api** |
| Device fisik (LAN) | `http://<IP-PC>:8000` | `runserver 0.0.0.0:8000` |
| Production | `https://api.mirubanksampah.id` | Deploy backend Fase 7 |

Seed data: `python manage.py seed_data --flush` di **miru-backend-api** → akun `nasabah001` / `nasabah123`.
