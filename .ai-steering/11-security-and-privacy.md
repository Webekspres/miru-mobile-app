# 11 — Security & Privacy (Mobile — mirumobileapp)

> Pedoman keamanan & privasi untuk **mirumobileapp** (Flutter, Android prioritas).
> **Sumber kanonik ekosistem:** repositori backend → `.ai-steering/11-security-and-privacy.md`
>
> Dokumen ini menjabarkan kontrol yang **wajib di aplikasi nasabah**.
>
> **Referensi lokal:** `06-system-constraints.md`, `10-integration-and-roles.md`, `04-api-integration.md`  
> **Task:** `08-task-list.md` (Fase 6–8 + checklist keamanan)

---

## 1. Ruang Lingkup

Aplikasi mobile **hanya untuk role `nasabah`**.

| Wajib | Dilarang |
|-------|----------|
| Tolak login staff (`petugas`/`admin`/`koordinator`/`pemerintah`) | Fitur admin / input setoran |
| Token di secure storage | Payment gateway / e-wallet otomatis |
| HTTPS production | GPS live tracking armada |
| Consent PDP saat registrasi | Scan KTP / face recognition / Dukcapil |
| QR = data identitas publik terbatas | Encode JWT di QR |

---

## 2. Autentikasi & Token Storage

| Aturan | Detail |
|--------|--------|
| Login | `POST /api/auth/login/` → guard `role == nasabah` |
| Tolak non-nasabah | Pesan: akun staff hanya untuk Web Admin MIRU |
| Storage | `flutter_secure_storage` untuk access + refresh token |
| Restore | Splash → `GET /api/auth/me/` |
| Refresh | Interceptor 401 → refresh → retry 1× → logout jika gagal |
| Logout | Hapus semua credential di secure storage + navigasi login |
| Password | Min 6 karakter; jangan log; field obscure |

### Registrasi & PDP

- Checkbox `setuju_kebijakan_data` **wajib** sebelum submit
- Link/halaman kebijakan data tersedia dari settings & registrasi
- **Jangan** minta NIK atau foto KTP di registrasi. Foto KTP hanya saat tarik ≥ Rp1.000.000 (lampiran sementara).

---

## 3. Keamanan Kartu Digital (QR)

| Aturan | Detail |
|--------|--------|
| Payload QR | JSON saja: `{ id, nama_lengkap, no_hp }` |
| Bukan JWT | QR tidak boleh berisi token akses |
| Share/screenshot | Post-MVP; peringatkan pengguna agar tidak sebar luas |
| Scan | Dilakukan petugas di web (kamera HP) — bukan biometrik identitas legal |

---

## 4. Komunikasi API

| Aturan | Detail |
|--------|--------|
| Base URL production | **HTTPS only** (ganti `10.0.2.2` / LAN IP) |
| Envelope | Unwrap aman; pesan error Bahasa Indonesia tanpa stack |
| Auth | Bearer dari secure storage |
| Timeout | Tetapkan timeout Dio wajar; jangan hang diam |
| Certificate pinning | Evaluasi post-launch (opsional) — jangan blocking MVP |

### Cleartext HTTP

- Emulator/LAN HTTP **hanya** development
- Release build **wajib** HTTPS (`usesCleartextTraffic=false` atau setara production)

---

## 5. Privasi Data di Device

| Data | Perlakuan |
|------|-----------|
| Token | Secure storage only |
| Saldo/poin cache | Boleh memory/provider; jangan tulis dokumen identitas ke disk |
| Screenshot sensitive | Jangan tampilkan foto KTP di screenshot berbagi |
| Logs | Release: **tidak** log token, password, body auth, path file KTP |
| Backup Android | Pertimbangkan exclude secure prefs dari auto-backup jika berisi sesi |

### eng_falcon tidak boleh minta berlebihan

- Lokasi: hanya untuk Maps sederhana post-MVP (alamat pin) — **bukan** tracking continuous
- Kamera: hanya jika fitur scan/share yang disepakati; bukan wajib registrasi
- Notifikasi: minta permission FCM hanya saat fitur push aktif (Fase 8)

---

## 6. Otorisasi Fungsional Nasabah

Nasabah hanya:

- Data milik sendiri (backend memfilter queryset)
- Ajukan jemput, tarik, tukar poin, pengaduan
- Lihat harga, edukasi, pengumuman, settings

Nasabah **tidak**:

- Approve transaksi orang lain
- Ubah role/saldo/poin sendiri via PATCH
- Akses laporan/dashboard admin

UI harus menghormati error 403/409 dari server tanpa workaround.

---

## 7. Keamanan Alur Finansial di UI

| Alur | Kontrol |
|------|---------|
| Tarik saldo | Validasi min Rp50.000 & ≤ saldo; konfirmasi; sebutkan proses manual 1–2 hari; **tanpa** gateway |
| Tukar poin | Disable jika poin/stok kurang; konfirmasi |
| Double tap | Disable tombol submit saat request jalan |
| Optimistic UI | Jangan kurangi saldo lokal sebelum server confirm |

---

## 8. Push Notification (Fase 8) — Keamanan

| Aturan | Detail |
|--------|--------|
| FCM token | Kirim ke backend terautentikasi; ikat ke user |
| Payload | Jangan kirim NIK/saldo lengkap di notifikasi publik |
| Tap action | Deep link hanya ke screen yang diizinkan nasabah |
| Opt-out | Sediakan cara nonaktifkan di settings bila memungkinkan |

WhatsApp notifikasi adalah **backend/gateway** — bukan diimplementasi sebagai scraper di app.

---

## 9. Build & Store Security

| Kontrol | Fase |
|---------|------|
| `flutter build` release tanpa debug flag | 7 |
| ProGuard/R8 jika perlu | 7 |
| Tidak embed secret di source | Selalu |
| Privacy policy URL di Play Console | 7 |
| Data safety form jujur (data dikumpulkan) | 7 |
| Internal testing track sebelum production | 7 — prosedur: `12-play-internal-testing.md` |
| Certificate pinning | Evaluasi post-MVP |

---

## 10. Checklist Go-Live Keamanan (Mobile)

### Wajib (Fase 6–7)

- [ ] Release pakai HTTPS API
- [ ] Cleartext HTTP dimatikan di release
- [ ] Token hanya di `flutter_secure_storage`; logout bersih
- [ ] Guard role nasabah di login
- [ ] Consent PDP di registrasi
- [ ] QR tanpa JWT
- [ ] Tidak ada log sensitif di release
- [ ] Double-submit & error 401/403 tertangani
- [ ] Privacy policy URL siap Play Store

### Selaras Backend Fase 8

- [ ] Lupa password dengan alur token aman (bukan SMS plain tanpa kebijakan)
- [ ] FCM tanpa PII berlebih di payload
- [ ] Field wilayah/RT-RW tanpa menumpuk data berlebih
- [ ] Share QR dengan peringatan privasi

---

## 11. Mapping Task List

| Item keamanan | Fase di `08-task-list.md` |
|---------------|---------------------------|
| UAT edge token/error/double-tap | Fase 6 |
| HTTPS, Play Store, secure storage verify, no log secrets | Fase 7 |
| Lupa password, FCM, Maps sederhana, bukti PDF | Fase 8 |
| Gateway / GPS live / Dukcapil / login staff | Out of Scope |

---

## 12. Aturan untuk AI / Engineer

1. Jangan simpan JWT di `SharedPreferences` plain.  
2. Jangan encode token ke QR.  
3. Jangan tambah login role non-nasabah.  
4. Jangan integrasi payment gateway atau live GPS.  
5. Patuhi kanonik backend `11-security-and-privacy.md`.
