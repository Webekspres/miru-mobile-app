# 08 — Task List: Mobile App Development Roadmap

> **Dokumen ini** adalah roadmap **mirumobileapp** (Android prioritas).
> **Urutan:** item **belum selesai di atas**; item **sudah selesai di bawah** (arsip).
>
> Item pengembangan lanjutan hanya dari dokumen persyaratan (Proposal, Jawaban,
> Modules, Business Rules, Constraints), dalam cakupan modul mobile — bukan spekulasi fitur.
> MVP sudah selesai; Fase 6–8 adalah lingkup kerja aktif.
>
> **Referensi (repo ini):**
>
> - `04-api-integration.md`, `07-modules-and-features.md`, `10-integration-and-roles.md`
> - `05-business-rules-sops.md`, `06-system-constraints.md`
> - `11-security-and-privacy.md` — **pedoman keamanan & privasi mobile**
>
> **Referensi backend:**
>
> - `backend/` → `.ai-steering/08-task-list.md`, `04-api-contracts`, `07-modules`,
> `11-security-and-privacy.md` **(kanonik)**

---



## Ringkasan Fase


| Fase | Nama                  | Tujuan                               | Backend Min.         | Status                |
| ---- | --------------------- | ------------------------------------ | -------------------- | --------------------- |
| 0–5  | Scaffold → Settings   | Auth, layar nasabah, UX, pengumuman  | Fase 1–5 ✅           | ✅ Selesai (arsip MVP) |
| 6    | Kualitas & UAT        | Widget/unit test + checklist UAT     | Fase 6               | 🔲 Aktif              |
| 7    | Production Android    | APK/AAB, Play Store                  | Fase 7               | 🔲 Aktif              |
| 8    | Pengembangan Lanjutan | Fitur persyaratan dalam modul mobile | Fase 8 (fitur API ✅) | 🔲 **Aktif**          |
| —    | Out of Scope          | Larangan sistem / di luar 17 modul   | —                    | ⛔                     |


> **Status proyek:** MVP mobile selesai. **Audit Temuan M0–M10 ✅.**
> **Kerja aktif #1:** sisa Fase 8 (FCM, PDF, poin expire) + Fase 6 UAT + Fase 7 Play Store.
> Hanya item dari dokumen persyaratan; **tidak menambah modul** di luar cakupan nasabah di bawah.



### Cakupan Modul — Mobile (Nasabah)

Dari 17 modul sistem, **sebagian** di mobile; sisanya staff-only di web-admin.


| No  | Modul           | Screen                    | Status MVP | Lanjutan (sisa)                                  |
| --- | --------------- | ------------------------- | ---------- | ------------------------------------------------ |
| 2   | Autentikasi     | Login, Register, Splash   | ✅          | OTP WA lupa password ✅; register singkat ✅       |
| 3   | Profil & QR     | Profile, QRCode           | ✅          | Kartu digital redesign ✅; QR di Home ✅           |
| 4   | Info & Edukasi  | InfoSampah + Edukasi      | ✅          | Render Markdown ✅                                |
| 5   | Katalog Harga   | InfoSampah / Home         | ✅          | Banner harga H-3 ✅                               |
| 7   | Penjemputan     | List + Ajukan             | ✅          | Form UX, maps, validasi jadwal ✅                 |
| 9   | Saldo & Riwayat | Riwayat, Home, Notifikasi | ✅          | Link riwayat; aktivitas campur; detail setoran ✅ |
| 10  | Tarik Saldo     | TarikSaldo                | ✅          | Keyboard UX ✅; lampiran KTP ≥1jt ✅; PDF/metode |
| 11  | Poin & Reward   | Reward, Tukar             | ✅          | UI polish; copy konfirmasi ✅                     |
| 14  | Pengaduan       | List + Form               | ✅          | Jenis “Lainnya” ✅                                |
| 15  | Dashboard       | Home                      | ✅          | QR cepat + brightness ✅                          |
| 17  | Settings        | Settings, Kebijakan       | ✅          | Info di profil; hub settings dihapus ✅           |


Modul **tidak ada** di mobile: 1, 6, 8, 12, 13, 16 (staff/admin only).

---



## Urutan kerja disarankan (Mobile)

1. ~~⛔ Sisa Audit Temuan mobile (M1–M10)~~ ✅ — arsip BAGIAN B.
2. Sisa Fase 8 yang belum tertutup temuan (FCM, PDF, poin expire).
3. Fase 6 UAT beriringan; Fase 7 Play Store saat API production HTTPS siap.
4. iOS & opsional — belakangan.

---



# BAGIAN A — BELUM SELESAI (prioritas atas)

> Hanya item `[ ]`. Detail cukup untuk dikerjakan; tetap dalam modul nasabah.

---



## Fase 8: Pengembangan Lanjutan

  *(overlap temuan audit sudah ✅ di BAGIAN B; sisa FCM/PDF/poin expire)*

> Bergantung Backend Fase 8. API fitur bisnis hampir semua ✅.
> Edukasi list/detail, share QR, notifikasi in-app + polling — sudah ✅ (BAGIAN B).



### 8.1 Modul 2 — Autentikasi lanjutan

> **Sumber:** Proposal §4 modul 2.
> **API:** `ForgotPasswordView` + `ResetPasswordView` — siap.

- [ ] **(Opsional) Verifikasi nomor HP/email** — hanya jika disepakati klien
  - Jangan kerjakan default; tunggu keputusan klien + endpoint final



### 8.4 Modul 5 / 9 — FCM push (sisa)

> Banner H-3 ✅ (BAGIAN B). Notifikasi in-app (list/detail/mark-read), polling ~8s, badge unread — sudah ✅.

- [ ] **Firebase Cloud Messaging setup**
  - `firebase_messaging` (+ config Android); register device token ke `POST /api/device-tokens/`
  - Unregister token saat logout
- [ ] **Handle push OS:** status penjemputan, penarikan approved/ditolak, pengumuman, harga baru
  - Tap notifikasi → buka layar relevan (detail jemput / notifikasi / home)
- [ ] **Payload push tanpa** PII berlebih / saldo lengkap / token JWT (jangan log payload sensitif)
- [ ] **Permission notifikasi OS** diminta saat FCM diaktifkan (Android 13+ `POST_NOTIFICATIONS`)



### 8.5 Modul 7 — Wilayah & peta sederhana

> **Sumber:** Jawaban §6.2.12–13, §6.6.1; Constraints §5.
> Reload status list + nama petugas setelah dijadwalkan — sudah ✅.

- [ ] **Validasi / pesan error wilayah & kuota 2×/minggu** dari envelope backend
  - Saat ajukan penjemputan gagal: tampilkan `message` server (BI), bukan generic “terjadi kesalahan”
  - Kasus: wilayah tidak terdaftar; kuota wilayah penuh
- [ ] **Pilih/lihat lokasi sederhana** (static map atau pin alamat) — **bukan** GPS live armada
  - Opsional; butuh Backend 8.7 koordinat + key Maps ter-restrict
  - Cukup tampil pin/static image di detail jemput jika koordinat ada



### 8.6 Modul 10 / 11 — Bukti & masa berlaku poin

> **Sumber:** Jawaban §6.2.10; §6.3.6; Business Rules §A.4.
> **API:** PDF download role-gated; `PoinInfoView`; metadata metode pencairan — siap.
> Lampiran KTP tarik ≥ Rp1.000.000 (sementara, bukan profil) — sudah ✅ (BAGIAN B).

- [ ] **Tampilkan info masa berlaku / sisa poin**
  - Di Home dan/atau RewardScreen; panggil endpoint info poin
  - Jelaskan poin hangus setelah 1 tahun (teks BI singkat)
- [ ] **Unduh atau share bukti transaksi / tanda terima** (PDF atau gambar)
  - Dari detail setoran / penarikan di Riwayat; hit download role-gated (nasabah milik sendiri)
  - Share via `share_plus` atau simpan file lokal
- [ ] **UI metode pencairan** (tunai / transfer bank / e-wallet metadata) di TarikSaldo
  - Field sesuai serializer backend; **tanpa** payment gateway
  - Konfirmasi sebelum submit; SLA 1–2 hari kerja tetap ditampilkan



### 8.7 iOS & peningkatan opsional

> **Sumber:** Constraints §10 / Jawaban §6.4 (iOS menyusul). **Bukan blocker Android.**

- [ ] iOS build configuration + App Store Connect / TestFlight
- [ ] Adapt UI safe area / Cupertino jika perlu
- [ ] Offline cache last-loaded saldo *(future — tidak blocker)*
- [ ] Biometric unlock *(opsional — bukan persyaratan wajib)*
- [ ] In-app rating prompt *(opsional store policy)*

---



## Fase 6: Kualitas & Testing (UAT Ready)

> **Sumber:** Checklist UAT; `11-security-and-privacy.md` §2, §7, §10.
> Guard nasabah, secure storage, consent, QR non-JWT, smoke `widget_test` — sudah ✅.



### 6.0 Keamanan Client — sisa

- [ ] **Verifikasi tidak ada log** token / password / foto KTP di path **release**
- [ ] **Double tap submit prevention** pada tarik saldo / tukar poin / ajukan jemput
- [ ] **Token expired mid-session** → refresh otomatis atau logout ramah (pesan BI)
- [ ] **Jangan kurangi saldo/poin lokal** sebelum server confirm (anti optimistic balance)



### 6.1 Automated Tests — sisa

- [ ] `test/models/user_test.dart` — `fromJson` saldo/poin string & number
- [ ] `test/services/api_envelope_test.dart` — parse success/error envelope
- [ ] `test/providers/auth_provider_test.dart` — mock dio; reject non-nasabah
- [ ] Widget test LoginScreen — validasi form kosong / password pendek
- [ ] Widget test TarikSaldoScreen — min Rp50.000 ditolak di UI



### 6.2 Manual / UAT Checklist

- [ ] Registrasi akun baru → login → home
- [ ] Login demo `nasabah001` / `nasabah123` (setelah `seed_data` backend)
- [ ] Login akun staff ditolak dengan pesan benar
- [ ] Ajukan penjemputan → status update dari web-admin terlihat setelah refresh/buka ulang
- [ ] Tarik saldo → approve admin → saldo berkurang di home
- [ ] Tukar poin → approve admin → poin berkurang
- [ ] Ajukan pengaduan → admin tindak lanjut → status ditutup
- [ ] QR discan petugas → setoran → saldo naik setelah pull-to-refresh
- [ ] Baca list + detail artikel edukasi dari Home
- [ ] Notifikasi: badge unread, mark-read, mark-all
- [ ] Test Android emulator (`10.0.2.2:8000`)
- [ ] Test device fisik via LAN IP



### 6.3 Edge Cases

- [ ] Server 500 → pesan ramah Bahasa Indonesia
- [ ] App background/foreground → token restore / session tetap valid
- [ ] Network offline → pesan jelas, tidak crash

---



## Fase 7: Production Android

> **Sumber:** Jawaban §6.4; Constraints §10; `11-security-and-privacy.md` §4, §9–10.  
> **Distribusi UAT stakeholder:** Play Console Internal testing — lihat `12-play-internal-testing.md`.



### 7.1 Build Configuration

- [ ] `constants.dart` / dart-define production URL **HTTPS only**
- [ ] Cleartext HTTP dimatikan di release (`usesCleartextTraffic=false` atau setara)
- [ ] App name, icon, splash screen MIRU branding
- [ ] `android/app/build.gradle` — `versionCode`, `versionName`
- [ ] ProGuard/R8 rules jika perlu (keep model JSON / secure storage)
- [ ] `flutter build apk --release`
- [ ] `flutter build appbundle` — Play Store



### 7.2 Play Store Preparation

> Prosedur lengkap: `12-play-internal-testing.md` (setup Console, build AAB, invite, update, rencana GH Actions).

- [ ] Privacy policy URL publik (koordinasi Backend  `/api/privacy-policy/` + hosting HTTPS)
- [ ] Data safety form jujur (data yang dikumpulkan: akun, transaksi, device token FCM jika aktif)
- [ ] Screenshot phone (& tablet jika relevan)
- [ ] Deskripsi Bahasa Indonesia
- [ ] Content rating questionnaire
- [ ] Internal testing track upload
- [ ] Akun Google Play Console dari klien *(Jawaban §6.4.1)*
- [ ] Email list + invite link stakeholder UAT
- [ ] *(Opsional)* GitHub Actions upload ke track internal — setelah keystore + service account siap



### 7.3 Security Release Checklist

> Lihat `11-security-and-privacy.md` §10.

- [ ] No sensitive data in logs (release)
- [ ] Secure storage verified on Android; logout bersih diuji
- [ ] Tidak ada secret/API key tertanam di source
- [ ] Checklist go-live keamanan mobile lolos
- [ ] Certificate pinning *(evaluasi saja — opsional post-launch)*

---



## Out of Scope / larangan

> **Sumber:** `06-system-constraints.md`; Proposal §5. Jangan dikerjakan tanpa addendum.

- [ ] ❌ Login petugas/admin/koordinator
- [ ] ❌ Input setoran sampah (hanya petugas di web admin)
- [ ] ❌ Payment gateway / e-wallet otomatis
- [ ] ❌ GPS live tracking penjemputan
- [ ] ❌ Scan KTP / face recognition / Dukcapil NIK validation
- [ ] ❌ Integrasi hardware timbangan/barcode
- [ ] ❌ Modul staff-only (1, 6, 8, 12, 13, 16) di mobile

---



# BAGIAN B — SELESAI (arsip) — urutan bawah

---



## Audit Temuan — selesai ✅

> **Sumber:** `temuan.md`. Backend T2–T8 ✅. Mobile M0–M10 ✅ (14 Agu 2026).



### M0. Navigasi & cache (umum)

- [x] **Bottom nav di halaman nested**
  - Opsi A (disarankan): sembunyikan bottom nav di route dalam (bukan tab root), **atau**
  - Opsi B: bottom nav tetap, tapi perilaku tab benar (lihat poin berikut)
- [x] **Tap ulang item bottom nav** selalu ke **root tab**, bukan sisa stack detail
  - Contoh: dari `/notif/detail` → pindah ke `/home` via bottom nav → tap Notif lagi → `/notif` **list**, bukan `/notif/detail`
  - Sama: dari `/notif/detail` tap tab Notif → pop ke `/notif`
  - Terapkan pola yang sama untuk semua tab (home, riwayat, dll.)
- [x] **Perbaiki cache / state provider** yang hilang mendadak
  - Data tidak “kosong total” tanpa alasan; pull-to-refresh cukup; jangan wajib restart server/app
  - Audit `HomeProvider` / SWR-like caching / invalidation setelah mutate
- [x] **Logout = clear semua cache + kembali state seperti cold start beranda**
  - Hapus token, user, list cached, badge; jangan sisakan data nasabah sebelumnya



### M1. Modul 2 — Auth, register, reset password

- [x] **Disable tombol Login** jika username/password kosong
- [x] **Pesan error login spesifik BI** (bukan “Terjadi kesalahan. Silakan coba lagi”)
  - Password salah / username tidak terdaftar — sesuai envelope backend T2
- [x] **Gate transaksi tanpa alamat**
  - Belum isi alamat (+ maps patokan + dropdown wilayah API) → blok jemput/tarik/tukar dengan dialog arahkan ke lengkapi profil
- [x] **Auto-fill alamat di form jemput** dari profil; tetap bisa diganti jika lokasi berbeda
- [x] Jika `phone_verified=false` setelah login (akun dibuat admin) → arahkan layar verifikasi OTP



### M2. Modul 3 / 15 — Profil, kartu digital, QR di Home

- [x] **ProfileScreen ringkas:** foto, nama, entry kartu digital — jangan dump semua field di atas
  - Edit data lewat icon pensil (sudah ada) / halaman edit



### Dari Fase 8: Pengembangan Lanjutan



### 8.1 Modul 2 — Autentikasi lanjutan

- [x] **Lupa password flow**
  - Layar: minta email/HP → kirim permintaan reset → layar masukkan token + password baru
  - Integrasi envelope error (token expired, user tidak ditemukan — pesan generik aman)
  - Link dari LoginScreen; password min 6 (selaras backend)
  - Setelah sukses → kembali ke login dengan pesan sukses BI



### 8.2 Modul 3 — Profil & kartu digital

> **Sumber:** Proposal modul 3.
> **API:** field kelurahan / RT / RW pada user — siap.
> Share / screenshot QR sudah ✅.

- [x] **Field RT / RW dan kelurahan** di profil edit + registrasi (opsional)
  - Tampil di ProfileScreen; kirim PATCH `/api/auth/me/` atau endpoint profil yang dipakai
  - Validasi/pesan error dari envelope jika wilayah tidak valid
  - Jangan wajibkan jika backend mengizinkan kosong



### M1. Modul 2 — Auth OTP WA + register singkat

- [x] **Alur lupa password → OTP WhatsApp**
  - Username → konfirmasi nomor HP → OTP WA → password baru (2 field + validasi) → LoginScreen
- [x] **Registrasi disingkat** — step 1 nama/username/password+consent; step 2 HP + OTP WA → login Home



### M2. Modul 3 / 15 — Kartu digital & QR Home

- [x] **Kartu digital redesign** — QR tengah + logo MIRU; flip depan/belakang (nama, id, RT/RW, alamat, bergabung)
- [x] **Home: ikon QR** kanan area saldo/poin → modal + kecerahan maksimum, restore saat tutup



### M3. Modul 7 — Form penjemputan

- [x] Pilih jenis sampah (bukan dump semua chip)
- [x] Estimasi nilai live (harga × kg)
- [x] Titik maps static/pin + izin lokasi; kirim lat/lng
- [x] Validasi jadwal realtime (~1 jam, WIT) + fix date picker
- [x] Dialog sukses besar; peringatan di luar jam operasional; refresh Home setelah ajukan



### M4. Modul 11 — Tukar poin UI

- [x] Rapikan UI; hapus “1 poin = Rp1.000”; detail vertikal center
- [x] Modal: Batal rata dengan primer; copy naratif SLA; qty=1 didokumentasikan



### M5. Modul 10 — Tarik saldo

- [x] Batal rata tengah; keyboard dismiss tanpa auto-fokus ulang
- [x] Dialog sukses SLA 1–2 hari; field error envelope di form
- [x] **Lampiran foto KTP** jika nominal ≥ Rp1.000.000 (bukan disimpan di profil; server hapus setelah proses)



### M6. Modul 9 — Riwayat & aktivitas Home

- [x] “Semua” → `go('/riwayat')` tab bottom nav
- [x] 3 aktivitas campur dari `/api/activity/` (setoran, penarikan, penukaran poin)
- [x] Detail setoran: jenis, berat, petugas, tanggal/jam proses (tanggal jemput jika API kirim)



### M7. Modul 4 — Edukasi Markdown

- [x] `MarkdownDocument` (`flutter_markdown_plus`) di detail edukasi — heading/list/bold; bukan raw `**` / `#`



### M8. Modul 14 — Pengaduan

- [x] Pilihan jenis **Lainnya** (`lainnya`) di form



### M9. Modul 5 — Banner harga H-3

- [x] Banner “harga akan berubah pada tanggal …” di Home + InfoSampah; hilang setelah tanggal lewat



### M10. Modul 17 — Settings mobile

- [x] Hub Settings dihapus; Kebijakan Data + Tentang di bawah ProfileScreen; edit tetap pensil
- [x] Tempat preferensi FCM di profil (placeholder sampai FCM Fase 8 dikerjakan)



## Fase 8 (sebagian) — sudah selesai ✅



### Modul 3 — Share QR ✅

- [x] Share / screenshot QR code intent (`share_plus` di `qrcode_screen.dart`)



### Modul 4 — Artikel edukasi ✅

- [x] Model `KontenEdukasi` + `EdukasiProvider` + list/detail screen
- [x] Preview edukasi di Home + route `/home/edukasi` & detail
- [x] Panduan pemilahan singkat tetap di `InfoSampahScreen`



### Modul 7 — Status penjemputan ✅

- [x] List penjemputan reload status dari API saat buka layar
- [x] Tampilkan nama petugas setelah dijadwalkan



### Modul 9 — Notifikasi in-app ✅

- [x] Wire layar notifikasi ke API list/mark-read (list, detail, tandai dibaca, mark-all)
- [x] Polling silent in-app (~8s) + refresh saat resume / buka lonceng
- [x] Popup lonceng: unread saja; badge unread di AppBar + bottom nav

---



## Fase 6 (sebagian) — sudah selesai ✅

- [x] Guard login hanya `nasabah`; tolak staff
- [x] Token di `flutter_secure_storage`; logout clear credential
- [x] Consent `setuju_kebijakan_data` di registrasi
- [x] QR payload JSON `{ id, nama_lengkap, no_hp }` — **bukan JWT**
- [x] `test/widget_test.dart` — splash/MIRU smoke (minimal)

---



## Fase 0: Scaffold ✅

- [x] Flutter project (`mirumobileapp`, Dart ^3.12.2)
- [x] Android/iOS folder structure; `flutter_lints`
- [x] Dokumentasi `.ai-steering/` selaras backend

---



## Fase 1: Foundation ✅

- [x] Dependencies: `provider`, `dio`, `go_router`, `flutter_secure_storage`, `qr_flutter`, `intl`, dll.
- [x] Folder `config/`, `models/`, `services/`, `providers/`, `screens/`, `widgets/`
- [x] Theme Material 3 primary `#16a34a`; routes + auth redirect
- [x] Dio + EnvelopeInterceptor + AuthInterceptor + refresh 401
- [x] Models & shared widgets (Loading, Error, Empty, SaldoCard, StatusBadge, AppScaffold)

---



## Fase 2: Auth Flow ✅

- [x] AuthProvider — guard `role == nasabah`; reject staff
- [x] Splash → me / login
- [x] LoginScreen + RegisterScreen (consent, password min 6)
- [x] go_router redirect unauthenticated

---



## Fase 3: MVP Screens ✅

- [x] Home — saldo, poin, quick actions, aktivitas, pull-to-refresh, banner jam layanan
- [x] Profile + edit; QR JSON
- [x] InfoSampah — kategori/harga/panduan singkat; min 1 kg
- [x] Penjemputan — tabs; ajukan min 5 kg, H+1; status badge
- [x] Riwayat — tabs; detail bottom sheet
- [x] TarikSaldo — min Rp50.000; tanpa gateway
- [x] Reward — katalog; tukar; disable jika poin/stok kurang
- [x] Pengaduan — form jenis + keluhan; tindak lanjut read-only

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


| Backend                        | Unblock Mobile                         |
| ------------------------------ | -------------------------------------- |
| Fase 1–5 ✅                     | Fase 0–5 MVP                           |
| Fase 7 HTTPS                   | Fase 7 Play Store                      |
| Fase 8.1 edukasi ✅             | List/detail edukasi ✅                  |
| Fase 8.2 harga H-3 ✅           | Banner harga 8.4                       |
| Fase 8.3 wilayah ✅             | Pesan error kuota 8.5; field RT/RW 8.2 |
| Fase 8.4 lupa password / PDF ✅ | Flow 8.1 / bukti 8.6                   |
| Fase 8.5 poin expire ✅         | Info poin 8.6                          |
| Fase 8.6 FCM trigger ✅         | Setup FCM client 8.4                   |
| Fase 8.7 Maps (belum)          | Pin lokasi opsional 8.5                |


---



## Checklist Integrasi End-to-End


| #   | Alur Nasabah (Mobile) | Aksi Staff (Web Admin)       | API              |
| --- | --------------------- | ---------------------------- | ---------------- |
| 1   | Register & login      | —                            | ✅                |
| 2   | Lihat saldo Home      | Petugas input setoran        | ✅                |
| 3   | Tunjukkan QR          | Petugas setoran              | ✅                |
| 4   | Ajukan penjemputan    | Approve & update status      | ✅                |
| 5   | Ajukan tarik saldo    | Admin approve manual         | ✅                |
| 6   | Tukar poin            | Admin serahkan & approve     | ✅                |
| 7   | Ajukan pengaduan      | Admin tindak lanjut          | ✅                |
| 8   | Lihat pengumuman      | Admin publish                | ✅                |
| 9   | Refresh riwayat       | —                            | ✅                |
| 10  | Baca artikel edukasi  | Admin kelola konten (web 🔲) | API ✅ / mobile ✅ |
| 11  | Lupa password         | —                            | API ✅ / mobile ✅ |
| 12  | Banner harga H-3      | Set tanggal berlaku (web 🔲) | API ✅ / mobile ✅ |


---



## Environment Testing


| Target                      | API Base URL                                              |
| --------------------------- | --------------------------------------------------------- |
| Android Emulator            | `http://10.0.2.2:8000`                                    |
| Device fisik (LAN)          | `http://<IP-PC>:8000`                                     |
| Play Internal testing (UAT) | `https://…` staging — lihat `12-play-internal-testing.md` |
| Production                  | `https://…` (domain final klien / Webekspres)             |


Seed: `python manage.py seed_data` di backend → akun demo nasabah.

---



## Definisi "Selesai" per Tahap


| Tahap                     | Kriteria                                                               |
| ------------------------- | ---------------------------------------------------------------------- |
| **Auth Ready**            | Fase 0–2                                                               |
| **MVP Nasabah**           | Fase 3–5                                                               |
| **UAT Ready**             | Fase 6 checklist lulus + backend + web admin                           |
| **Play Store Beta**       | Fase 7 internal testing — prosedurnya di `12-play-internal-testing.md` |
| **Go-Live Android**       | Production API + app published                                         |
| **Pengembangan Lanjutan** | Fase 8 aktif — hanya item persyaratan dalam modul mobile               |




## Indeks dokumen keamanan


| Repo              | Dokumen                                             |
| ----------------- | --------------------------------------------------- |
| Backend (kanonik) | `backend/.ai-steering/11-security-and-privacy.md`   |
| Web Admin         | `web-admin/.ai-steering/11-security-and-privacy.md` |
| Mobile            | `.ai-steering/11-security-and-privacy.md`           |


