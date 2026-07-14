# 08 — Task List: Mobile App Development Roadmap

> **Dokumen ini** adalah roadmap **mirumobileapp** (Android prioritas).
> Urutan: **yang belum selesai di atas**, arsip MVP yang sudah selesai di bawah.
>
> Item pengembangan lanjutan hanya dari dokumen persyaratan (Proposal, Jawaban,
> Modules, Business Rules, Constraints).
>
> **Referensi (repo ini):**
> - `04-api-integration.md`, `07-modules-and-features.md`, `10-integration-and-roles.md`
> - `05-business-rules-sops.md`, `06-system-constraints.md`
>
> **Referensi backend:**
> - `miru-backend-api` → `.ai-steering/08-task-list.md`, `04-api-contracts`, `07-modules`

---

## Ringkasan Fase

| Fase | Nama | Tujuan | Backend Min. | Status |
|------|------|--------|--------------|--------|
| 0–5 | Scaffold → Settings | Auth, MVP screens, UX, pengumuman | Fase 1–5 ✅ | ✅ Selesai |
| 6 | Kualitas & UAT | Widget/unit test + checklist UAT | Fase 6 | 🔲 Aktif |
| 7 | Production Android | APK/AAB, Play Store | Fase 7 | 🔲 Aktif |
| 8 | Pengembangan Lanjutan | FCM, edukasi, lupa password, iOS, dll. | Fase 8 | 🔲 Post-MVP |
| — | Out of Scope | Larangan sistem | — | ⛔ |

### Cakupan Modul — Mobile (Nasabah)

Dari 17 modul sistem, **sebagian** di mobile; sisanya staff-only di web-admin.

| No | Modul | Screen | Status MVP | Lanjutan |
|----|-------|--------|------------|----------|
| 2 | Autentikasi | Login, Register, Splash | ✅ | Lupa password; verifikasi HP/email (opsional) |
| 3 | Profil & QR | Profile, QRCode | ✅ | RT/RW–kelurahan; share QR |
| 4 | Info & Edukasi | InfoSampah | ✅ (kategori/harga) | Artikel edukasi dari API |
| 5 | Katalog Harga | (InfoSampah / Home) | ✅ | Banner harga H-3 |
| 7 | Penjemputan | List + Ajukan | ✅ | Wilayah/kuota; Maps sederhana |
| 9 | Saldo & Riwayat | Riwayat, Home | ✅ | Notifikasi status |
| 10 | Tarik Saldo | TarikSaldo | ✅ | Bukti PDF; metode metadata |
| 11 | Poin & Reward | Reward, Tukar | ✅ | Info masa berlaku poin |
| 14 | Pengaduan | List + Form | ✅ | — |
| 15 | Dashboard | Home | ✅ | — |
| 17 | Settings | Settings, Pengumuman, Kebijakan | ✅ | FCM settings |

Modul **tidak ada** di mobile: 1, 6, 8, 12, 13, 16 (staff/admin only).

---

# BAGIAN A — BELUM SELESAI (prioritas atas)

---

## Fase 6: Kualitas & Testing (UAT Ready)

> **Sumber:** Kriteria UAT roadmap; checklist integrasi E2E.

### 6.1 Automated Tests
- [ ] `test/models/user_test.dart` — fromJson saldo string
- [ ] `test/services/api_envelope_test.dart` — parse success/error
- [ ] `test/providers/auth_provider_test.dart` — mock dio
- [ ] Widget test LoginScreen — form validation
- [ ] Widget test TarikSaldoScreen — min Rp50.000
- [x] `test/widget_test.dart` — splash/MIRU smoke *(minimal)*

### 6.2 Manual / UAT Checklist
- [ ] Registrasi akun baru → login → home
- [ ] Login demo `nasabah001` / `nasabah123` (setelah seed backend)
- [ ] Ajukan penjemputan → status update dari web-admin
- [ ] Tarik saldo → approve admin → saldo berkurang di home
- [ ] Tukar poin → approve admin → poin berkurang
- [ ] Ajukan pengaduan → admin tindak lanjut → ditutup
- [ ] QR discan petugas → setoran → saldo naik setelah refresh
- [ ] Test Android emulator (`10.0.2.2:8000`)
- [ ] Test device fisik via LAN IP

### 6.3 Edge Cases
- [ ] Token expired mid-session
- [ ] Server 500 → pesan ramah Indonesia
- [ ] Double tap submit prevention
- [ ] App background/foreground token restore

---

## Fase 7: Production Android

> **Sumber:** Jawaban §6.4 (Play Console, branding, privacy policy); Constraints §10 (Android prioritas).

### 7.1 Build Configuration
- [ ] `constants.dart` production URL HTTPS
- [ ] App name, icon, splash screen MIRU branding
- [ ] `android/app/build.gradle` — versionCode, versionName
- [ ] ProGuard/R8 rules jika perlu
- [ ] `flutter build apk --release`
- [ ] `flutter build appbundle` — Play Store

### 7.2 Play Store Preparation
- [ ] Privacy policy URL (dari kebijakan data + hosting)
- [ ] Screenshot phone (& tablet jika relevan)
- [ ] Deskripsi Bahasa Indonesia
- [ ] Content rating questionnaire
- [ ] Internal testing track upload
- [ ] Akun Google Play Console dari klien *(Jawaban §6.4.1)*

### 7.3 Security
- [ ] No sensitive data in logs (release)
- [ ] Secure storage verified on Android
- [ ] Certificate pinning *(evaluasi saja — opsional post-launch)*

---

## Fase 8: Pengembangan Lanjutan (pasca-MVP)

> Bergantung Backend Fase 8. Hanya item dari dokumen persyaratan.

### 8.1 Modul 2 — Autentikasi lanjutan
> **Sumber:** Proposal §4 modul 2 (lupa password, verifikasi nomor/email).

- [ ] Lupa password flow (butuh endpoint backend)
- [ ] (Opsional) verifikasi nomor HP/email — hanya jika disepakati klien

### 8.2 Modul 3 — Profil & kartu digital
> **Sumber:** Proposal modul 3 (alamat, RT/RW, kelurahan, QR digital).

- [ ] Field RT/RW dan kelurahan di profil / registrasi
- [ ] Share / screenshot QR code intent

### 8.3 Modul 4 — Artikel edukasi
> **Sumber:** Proposal modul 4 (artikel edukasi); Modules Web/Mobile.

- [ ] Tampil list + detail artikel edukasi dari API (selain kategori/harga)
- [ ] Tetap tampilkan panduan pemilahan singkat di InfoSampah

### 8.4 Modul 5 / 9 — Harga terjadwal & notifikasi
> **Sumber:** Jawaban §6.2.4 (pengumuman harga H-3); Jawaban §6.6.5 FCM; Proposal modul 9.

- [ ] Banner/info harga akan berubah pada tanggal berlaku
- [ ] Firebase Cloud Messaging setup
- [ ] Handle push: status penjemputan, penarikan approved, pengumuman, harga baru
- [ ] Wire layar notifikasi ke API list/mark-read (screen sudah ada)

### 8.5 Modul 7 — Wilayah & peta sederhana
> **Sumber:** Jawaban §6.2.12–13, §6.6.1; Constraints §5 (tanpa live tracking).

- [ ] Validasi / pesan error wilayah & kuota 2×/minggu dari envelope backend
- [ ] Pilih/lihat lokasi sederhana (static map atau pin alamat) — **bukan** GPS live armada

### 8.6 Modul 10 / 11 — Bukti & masa berlaku poin
> **Sumber:** Jawaban §6.2.10 (poin 1 tahun); §6.3.6 bukti; Business Rules §A.4.

- [ ] Tampilkan info masa berlaku / sisa poin (setelah backend expire task)
- [ ] Unduh atau share bukti transaksi / tanda terima (PDF atau gambar)
- [ ] UI metode pencairan (tunai / transfer metadata) — **tanpa** payment gateway

### 8.7 iOS & peningkatan opsional
> **Sumber:** Constraints §10 / Jawaban §6.4 (iOS menyusul); Constraints offline “tidak wajib MVP”.

- [ ] iOS build configuration + App Store Connect / TestFlight
- [ ] Adapt UI safe area / Cupertino jika perlu
- [ ] Offline cache last-loaded saldo *(future — tidak blocker)*
- [ ] Biometric unlock *(opsional — bukan persyaratan wajib)*
- [ ] In-app rating prompt *(opsional store policy)*

### 8.8 Out of Scope / larangan
> **Sumber:** `06-system-constraints.md`; Proposal §5.

- [ ] ❌ Login petugas/admin/koordinator
- [ ] ❌ Input setoran sampah (hanya petugas di web admin)
- [ ] ❌ Payment gateway / e-wallet otomatis
- [ ] ❌ GPS live tracking penjemputan
- [ ] ❌ Scan KTP / face recognition / Dukcapil NIK validation
- [ ] ❌ Integrasi hardware timbangan/barcode

---

# BAGIAN B — ARSIP MVP (Selesai) — urutan bawah

---

## Fase 0: Scaffold ✅

- [x] Flutter project (`mirumobileapp`, Dart ^3.12.2)
- [x] Android/iOS folder structure; `flutter_lints`
- [x] Dokumentasi `.ai-steering/` selaras backend

---

## Fase 1: Foundation ✅

### 1.1–1.3 Dependencies, structure, theme ✅
- [x] `provider`, `dio`, `go_router`, `flutter_secure_storage`, `qr_flutter`, `intl`, dll.
- [x] Folder `config/`, `models/`, `services/`, `providers/`, `screens/`, `widgets/`
- [x] Theme Material 3 primary `#16a34a`; routes + auth redirect

### 1.4 API Client ✅
- [x] Dio + EnvelopeInterceptor + AuthInterceptor + refresh 401
- [x] `auth_service`, `storage_service`, `api_envelope`

### 1.5–1.6 Models & Shared Widgets ✅
- [x] User, WasteCategory, Deposit, Pickup, Withdrawal, Reward, Complaint, ActivityItem, dll.
- [x] LoadingIndicator, ErrorView, EmptyState, SaldoCard, StatusBadge, AppScaffold

---

## Fase 2: Auth Flow ✅

- [x] AuthProvider — guard `role == nasabah`; reject staff
- [x] Splash → me / login
- [x] LoginScreen + RegisterScreen (consent `setuju_kebijakan_data`, password min 6)
- [x] go_router redirect unauthenticated

---

## Fase 3: MVP Screens ✅

### 3.1 Home ✅
- [x] Saldo, poin, quick actions, aktivitas, pull-to-refresh, banner jam layanan

### 3.2 Profil & QR ✅
- [x] Profile + edit; QR JSON `{ id, nama_lengkap, no_hp }`

### 3.3 Info Sampah ✅
- [x] List kategori/harga/panduan singkat; catatan min 1 kg

### 3.4 Penjemputan ✅
- [x] Tabs aktif/riwayat; ajukan min 5 kg, H+1; status badge

### 3.5 Riwayat ✅
- [x] Tabs semua/setoran/penarikan/poin; detail bottom sheet

### 3.6 Tarik Saldo ✅
- [x] Min Rp50.000; konfirmasi; SLA 1–2 hari; tanpa gateway

### 3.7 Reward ✅
- [x] Katalog; tukar; disable jika poin/stok kurang

### 3.8 Pengaduan ✅
- [x] Form jenis + keluhan; tabs; tindak lanjut read-only

---

## Fase 4: Navigation & UX Polish ✅

- [x] Bottom nav Home | Riwayat | Profil; StatefulShellRoute
- [x] Loading / error BI / empty / confirm dialogs / pull-to-refresh
- [x] Format Rupiah & tanggal `id_ID`
- [x] `ListView.builder` / Consumer scoped

---

## Fase 5: Settings & Informasi ✅

- [x] Settings: profil, pengumuman, kebijakan data, tentang, logout
- [x] `GET /api/settings/`, `GET /api/pengumuman/`
- [x] Kebijakan data (UU PDP) static + checkbox registrasi

---

## Matriks Dependensi Backend → Mobile

| Backend | Unblock Mobile |
|---------|----------------|
| Fase 1–5 ✅ | Fase 0–5 MVP |
| Fase 7 HTTPS | Fase 7 Play Store |
| Fase 8.1 edukasi | Fase 8.3 |
| Fase 8.2 harga H-3 | Fase 8.4 banner |
| Fase 8.3 wilayah | Fase 8.5 |
| Fase 8.4 lupa password / PDF | Fase 8.1 / 8.6 |
| Fase 8.5 poin expire | Fase 8.6 |
| Fase 8.6 FCM trigger | Fase 8.4 push |

---

## Checklist Integrasi End-to-End

| # | Alur Nasabah (Mobile) | Aksi Staff (Web Admin) | API |
|---|----------------------|------------------------|-----|
| 1 | Register & login | — | ✅ |
| 2 | Lihat saldo Home | Petugas input setoran | ✅ |
| 3 | Tunjukkan QR | Petugas setoran | ✅ |
| 4 | Ajukan penjemputan | Approve & update status | ✅ |
| 5 | Ajukan tarik saldo | Admin approve manual | ✅ |
| 6 | Tukar poin | Admin serahkan & approve | ✅ |
| 7 | Ajukan pengaduan | Admin tindak lanjut | ✅ |
| 8 | Lihat pengumuman | Admin publish | ✅ |
| 9 | Refresh riwayat | — | ✅ |
| 10 | Baca artikel edukasi | Admin kelola konten | Backend Fase 8 |

---

## Environment Testing

| Target | API Base URL |
|--------|--------------|
| Android Emulator | `http://10.0.2.2:8000` |
| Device fisik (LAN) | `http://<IP-PC>:8000` |
| Production | `https://…` (domain final klien / Webekspres) |

Seed: `python manage.py seed_data` di backend → akun demo nasabah.

---

## Definisi "Selesai" per Tahap

| Tahap | Kriteria |
|-------|----------|
| **Auth Ready** | Fase 0–2 |
| **MVP Nasabah** | Fase 3–5 |
| **UAT Ready** | Fase 6 checklist lulus + backend + web admin |
| **Play Store Beta** | Fase 7 internal testing |
| **Go-Live Android** | Production API + app published |
| **Pengembangan Lanjutan** | Fase 8 iteratif (FCM, edukasi, iOS, dll.) |
