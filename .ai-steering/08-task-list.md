# 08 — Task List: Mobile

Flutter, Android prioritas. Belum selesai di atas; selesai di bawah.
Hanya task dalam modul nasabah. Jangan tambah modul di luar cakupan.

---

## Fase 6 — Kualitas & UAT

### Bisa langsung

- [x] Tidak ada log token / password / foto KTP di path **release**
- [x] Double-tap prevention: tarik saldo, tukar poin, ajukan jemput
- [x] Token expired mid-session → refresh atau logout ramah (BI)
- [x] Jangan kurangi saldo/poin lokal sebelum server confirm
- [x] `test/models/user_test.dart` — `fromJson` saldo/poin string & number
- [x] `test/services/api_envelope_test.dart` — parse success/error envelope
- [x] `test/providers/auth_provider_test.dart` — mock dio; reject non-nasabah
- [x] Widget test LoginScreen — form kosong / password pendek
- [x] Widget test TarikSaldoScreen — min Rp50.000 ditolak di UI
- [x] Server 500 → pesan ramah Bahasa Indonesia
- [x] App background/foreground → session tetap valid
- [x] Network offline → pesan jelas, tidak crash
- [x] Registrasi akun baru → login → home *(perlu backend hidup + device/emulator)*
- [x] Login demo `nasabah001` / `nasabah123` (setelah `seed_data`) *(perlu backend hidup)*
- [x] Login akun staff ditolak dengan pesan benar
- [x] Baca list + detail artikel edukasi dari Home
- [x] Notifikasi: badge unread, mark-read, mark-all
- [x] Test Android emulator (`10.0.2.2:8000`) *(perlu emulator + backend)*
- [x] Test device fisik via LAN IP *(perlu device + `--dart-define=API_BASE_URL`)*

### Perlu integrasi (web admin + backend)

- [ ] Ajukan penjemputan → status update dari web terlihat setelah refresh
- [ ] Tarik saldo → approve admin → saldo berkurang di home
- [ ] Tukar poin → approve admin → poin berkurang
- [ ] Ajukan pengaduan → admin tindak lanjut → status ditutup
- [ ] QR discan petugas → setoran → saldo naik setelah pull-to-refresh

---

## Fase 7 — Production Android

Prosedur Play Internal: `12-play-internal-testing.md`.

### Bisa langsung

- [ ] App name, icon, splash MIRU
- [ ] `versionCode` / `versionName`
- [ ] ProGuard/R8 (keep model JSON / secure storage) jika perlu
- [ ] `flutter build apk --release` (URL staging)
- [ ] Tidak ada secret/API key tertanam di source
- [ ] Secure storage + logout bersih diuji di Android

### Perlu integrasi (domain HTTPS, akun Play, klien)

- [ ] `constants.dart` / dart-define production URL **HTTPS only**
- [ ] Cleartext HTTP mati di release
- [ ] `flutter build appbundle`
- [ ] Privacy policy URL publik (Backend 8.9 + hosting HTTPS)
- [ ] Data safety form jujur (akun, transaksi, device token FCM jika aktif)
- [ ] Screenshot phone
- [ ] Deskripsi Bahasa Indonesia
- [ ] Content rating questionnaire
- [ ] Internal testing track upload
- [ ] Akun Google Play Console dari klien
- [ ] Email list + invite stakeholder UAT
- [ ] Checklist go-live keamanan mobile
- [ ] *(Opsional)* GitHub Actions upload internal — setelah keystore + service account
- [ ] Certificate pinning *(evaluasi post-launch)*

---

## Fase 8 — Pengembangan lanjutan

### Bisa langsung (API sudah ✅)

- [x] Info masa berlaku / sisa poin di Reward (`PoinInfoView`); teks BI poin hangus 1 tahun (2026-09-25)
- [ ] Unduh atau share PDF bukti setoran / penarikan (role-gated, milik sendiri)
- [ ] UI metode pencairan di TarikSaldo (tunai / transfer / e-wallet metadata; tanpa gateway; konfirmasi + SLA 1–2 hari)
- [x] Pesan error wilayah & kuota 2×/minggu dari envelope BI saat ajukan jemput gagal — dialog (2026-09-25)

### Perlu integrasi

- [ ] FCM: `firebase_messaging` + config Android; register token `POST /api/device-tokens/`; unregister saat logout — **Firebase project + `google-services.json`**
- [ ] Handle push OS (jemput, tarik approved/ditolak, pengumuman, harga) → tap buka layar relevan
- [ ] Payload push tanpa PII berlebih / saldo lengkap / JWT (jangan log)
- [ ] Permission notifikasi OS (Android 13+ `POST_NOTIFICATIONS`) saat FCM aktif
- [ ] Pin/static map lokasi jemput — **Backend 8.7 Maps key**; bukan GPS live
- [ ] *(Opsional)* Verifikasi HP/email — **tunggu keputusan klien**
- [ ] iOS build + TestFlight
- [ ] Adapt UI safe area / Cupertino jika perlu
- [ ] Offline cache last-loaded saldo *(future)*
- [ ] Biometric unlock *(opsional)*
- [ ] In-app rating prompt *(opsional store)*

---

## Out of scope

- ❌ Login petugas/admin/koordinator
- ❌ Input setoran sampah
- ❌ Payment gateway / e-wallet otomatis
- ❌ GPS live tracking
- ❌ Scan KTP / face recognition / Dukcapil
- ❌ Hardware timbangan/barcode
- ❌ Modul staff-only (1, 6, 8, 12, 13, 16)

---

## Selesai

### Fase 0 — Scaffold

- [x] Flutter project (`mobile/`, Dart ^3.12.2)
- [x] Android/iOS folder; `flutter_lints`
- [x] Dokumentasi `.ai-steering/`

### Fase 1 — Foundation

- [x] Dependencies: provider, dio, go_router, flutter_secure_storage, qr_flutter, intl
- [x] Folder `config/`, `models/`, `services/`, `providers/`, `screens/`, `widgets/`
- [x] Theme Material 3 `#16a34a`; routes + auth redirect
- [x] Dio + EnvelopeInterceptor + AuthInterceptor + refresh 401
- [x] Widgets: Loading, Error, Empty, SaldoCard, StatusBadge, AppScaffold

### Fase 2 — Auth

- [x] AuthProvider guard `role == nasabah`; tolak staff
- [x] Splash → me / login
- [x] LoginScreen + RegisterScreen (consent, password min 6)
- [x] go_router redirect unauthenticated
- [x] Disable Login jika username/password kosong
- [x] Pesan error login spesifik BI
- [x] Lupa password → OTP WhatsApp → password baru
- [x] Registrasi singkat: nama/username/password+consent → HP + OTP WA
- [x] Gate transaksi tanpa alamat → dialog lengkapi profil
- [x] `phone_verified=false` → layar verifikasi OTP

### Fase 3 — Layar MVP

- [x] Home: saldo, poin, quick actions, aktivitas, pull-to-refresh, banner jam
- [x] Profile + edit; QR JSON `{ id, nama_lengkap, no_hp }` (bukan JWT)
- [x] InfoSampah: kategori/harga/panduan; min 1 kg
- [x] Penjemputan: tabs; ajukan min 5 kg, H+1; status badge
- [x] Riwayat: filter chip scroll (Semua / Setoran / Penarikan / Poin); detail bottom sheet
- [x] TarikSaldo: min Rp50.000; tanpa gateway
- [x] Reward: katalog; tukar; disable jika poin/stok kurang
- [x] Pengaduan: form jenis + keluhan; tindak lanjut read-only

### Fase 4 — Navigasi & UX

- [x] Bottom nav Beranda | Riwayat | Notifikasi | Profil + FAB jemput
- [x] Bottom nav hilang di nested; tap tab reset ke root
- [x] Loading / error BI / empty / confirm / pull-to-refresh
- [x] Skeleton hanya bagian dinamis (bukan full-page)
- [x] Format Rupiah & tanggal `id_ID`
- [x] Empty state pengaduan & penjemputan ke tengah

### Fase 5 — Settings & informasi

- [x] Kebijakan Data + Tentang di ProfileScreen
- [x] `GET /api/settings/`, `GET /api/pengumuman/`
- [x] Consent UU PDP di registrasi
- [x] Token di `flutter_secure_storage`; logout clear cache

### Fase 6 (sebagian)

- [x] `test/widget_test.dart` splash/MIRU smoke
- [x] Tes kualitas: user/envelope/auth, widget Login & TarikSaldo, 500/offline, double-tap

### Fase 8 (sebagian)

- [x] Field RT/RW/kelurahan di profil edit + registrasi
- [x] Kartu digital: QR + logo; flip depan/belakang
- [x] Home: ikon QR → modal + kecerahan maksimum
- [x] Share / screenshot QR
- [x] Form jemput: jenis, estimasi, pin lokasi, validasi jadwal WIT
- [x] Auto-fill alamat jemput dari profil
- [x] Tukar poin UI + copy SLA; qty=1
- [x] Tarik saldo: quick amount, format titik, validasi min/saldo, lampiran KTP ≥1jt
- [x] Aktivitas Home dari `/api/activity/`; detail setoran lengkap
- [x] Edukasi Markdown + list/detail + preview Home
- [x] Pengaduan jenis Lainnya
- [x] Banner harga H-3
- [x] Pengumuman banner di Beranda
- [x] Notifikasi in-app: list/detail/mark-read/mark-all; polling ~8s; badge + popup lonceng
- [x] List jemput reload status; nama petugas setelah dijadwalkan
