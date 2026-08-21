# 12 — Play Console Internal Testing (Staging untuk Stakeholder)

> **Keputusan distribusi UAT:** Google Play **Internal testing** (bukan kirim APK manual).  
> **Fase roadmap:** `08-task-list.md` → Fase 7 (§7.1–7.2).  
> **Keamanan release:** `11-security-and-privacy.md` §9–10.

Dokumen ini menjelaskan cara membuat build MIRU Mobile tersedia untuk stakeholder terbatas (klien, dinas, QA) lewat Play Store Internal testing, plus opsi otomatisasi GitHub Actions.

---

## 1. Mengapa Internal testing

| Aspek | Internal testing | Kirim APK (chat/Drive) |
|-------|------------------|------------------------|
| Instalasi | Dari Play Store | Sideload (sering ditolak HP) |
| Update | Lewat Play setelah release baru | Kirim ulang file tiap versi |
| Akses | Hanya email di allowlist (≤100) | Link mudah bocor |
| Jalur ke production | Track berjenjang di Play Console | Setup Play tetap harus diulang nanti |
| Kesan stakeholder | Distribusi resmi | File ad-hoc |

**Batasan:** Internal testing mendistribusikan **aplikasi Android**. API staging/production harus sudah HTTPS dan bisa diakses dari internet — Play tidak menggantikan backend.

---

## 2. Prasyarat

### 2.1 Akun & organisasi

- [ ] Google Play Console aktif (akun developer — biasanya milik **klien**; one-time fee)
- [ ] App listing MIRU Bank Sampah / Miru-G dibuat di Console
- [ ] Tim punya akses Play Console (Owner / Admin / Release manager sesuai kebutuhan)

### 2.2 Backend & konfigurasi app

- [ ] API target (staging atau prod-preview) **HTTPS** — lihat `lib/config/constants.dart` (`API_BASE_URL` via `--dart-define`)
- [ ] Backend `ALLOWED_HOSTS` mencakup host API tersebut
- [ ] Akun demo / seed nasabah untuk tester (bukan data production sensitif)
- [ ] Privacy policy URL publik (koordinasi backend `/api/privacy-policy/` + hosting HTTPS)
- [ ] Cleartext HTTP **mati** di release (`usesCleartextTraffic=false` atau setara)

### 2.3 Listing minimal agar track testing aktif

Play meminta kelengkapan listing sebelum release testing (detail bisa berubah; cek Console):

- [ ] Deskripsi singkat & lengkap (Bahasa Indonesia)
- [ ] Screenshot perangkat
- [ ] Icon / graphic assets
- [ ] Content rating questionnaire
- [ ] Data safety form (akun, transaksi, FCM token jika aktif — jujur)
- [ ] Privacy policy URL

---

## 3. Alur one-time (setup)

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────────┐
│ Play Console    │────▶│ Internal testing │────▶│ Email list tester   │
│ buat app +      │     │ track + link     │     │ (stakeholder)       │
│ listing dasar   │     │ invite           │     │                     │
└─────────────────┘     └──────────────────┘     └─────────────────────┘
         │
         ▼
┌─────────────────┐     ┌──────────────────┐
│ Keystore release│────▶│ Play App Signing │
│ (simpan aman)   │     │ (disarankan)     │
└─────────────────┘     └──────────────────┘
```

1. Buat aplikasi di Play Console (package name = `applicationId` Android — harus tetap selamanya).
2. Aktifkan **Play App Signing** (disarankan Google).
3. Siapkan **upload keystore** lokal/CI; jangan commit ke git.
4. Buka **Testing → Internal testing** → buat release pertama (boleh draft sampai AAB siap).
5. Buat **email list** (mis. `miru-uat-stakeholders`) — masukkan Gmail tester.
6. Salin **link invite** Internal testing untuk dibagikan ke stakeholder.

---

## 4. Build AAB untuk Internal testing

Target utama Play: **Android App Bundle (`.aab`)**, bukan APK.

### 4.1 Versi

Di `android/app/build.gradle` (atau setara):

- `versionName` — tampilan manusia (contoh `0.1.0-uat`)
- `versionCode` — integer **selalu naik** tiap upload (contoh `1`, `2`, `3`…)

Upload dengan `versionCode` yang sama/lebih rendah dari yang sudah di Play akan **ditolak**.

### 4.2 Perintah build (manual)

```bash
# Dari folder mirumobileapp/
flutter pub get

flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://<HOST-API-STAGING>/api
```

Output tipikal: `build/app/outputs/bundle/release/app-release.aab`

Ganti `<HOST-API-STAGING>` dengan domain staging yang disepakati (usulan production di README: `api.mirubanksampah.id` — staging biasanya subdomain terpisah).

### 4.3 Environment API

| Konteks | `API_BASE_URL` |
|---------|----------------|
| Emulator lokal | default `http://10.0.2.2:8000/api` (jangan untuk Play) |
| Internal testing / UAT | `https://<staging>/api` |
| Production store | `https://<production>/api` |

Sumber di kode: `AppConstants.apiBaseUrl` ← `String.fromEnvironment('API_BASE_URL')`.

---

## 5. Upload & rilis Internal testing

### 5.1 Manual (Play Console)

1. Play Console → app MIRU → **Testing → Internal testing**
2. **Create new release**
3. Upload `app-release.aab`
4. Isi release notes singkat (Bahasa Indonesia), contoh: `UAT build 3 — perbaikan login & riwayat`
5. **Review release** → **Start rollout to Internal testing**
6. Tunggu status **Available** (biasanya menit–beberapa jam)

### 5.2 Stakeholder: install pertama kali

1. Buka **link invite** Internal testing (dari email list)
2. Login Google dengan **email yang di-invite**
3. Accept menjadi tester
4. Buka link Play Store app → **Install** / **Update**

Tanpa accept invite, app tidak muncul / tidak bisa di-install dari track internal.

### 5.3 Stakeholder: update berikutnya

Setelah release baru **Available** di Internal testing:

- Play Store menampilkan **Update** (kadang perlu buka halaman app atau sync Play)
- Tidak perlu kirim file baru lewat chat
- Latency: tidak selalu instan; beri buffer waktu setelah “Available”

---

## 6. Otomasi GitHub Actions (opsional, fase lanjut)

`mirumobileapp` saat ini **belum** punya `.github/workflows/`. Setelah signing + Play Console siap, CI bisa:

1. Trigger: push ke branch `staging` / tag `uat-*` / `workflow_dispatch`
2. `flutter build appbundle --release` + `API_BASE_URL` dari secret/var
3. Sign dengan keystore dari GitHub Secrets
4. Upload ke track **internal** (mis. action `r0adkll/upload-google-play` atau Fastlane `supply`)
5. Naikkan `versionCode` otomatis (mis. dari `GITHUB_RUN_NUMBER` atau tag)

### Secrets yang dibutuhkan (rencana)

| Secret | Fungsi |
|--------|--------|
| `PLAY_SERVICE_ACCOUNT_JSON` | Service account dengan akses Play Console API |
| `ANDROID_KEYSTORE_BASE64` | Upload keystore (encoded) |
| `ANDROID_KEYSTORE_PASSWORD` | Password keystore |
| `ANDROID_KEY_ALIAS` | Alias key |
| `ANDROID_KEY_PASSWORD` | Password key |
| `API_BASE_URL_STAGING` | URL API untuk build UAT |

### Guardrail

- **Jangan** auto-promote ke Production tanpa approval manual / environment protection.
- Jangan commit keystore, service account JSON, atau password.
- Production track = proses terpisah + checklist `11-security-and-privacy.md` §10.

Implementasi workflow = tugas terpisah setelah dokumen ini dan prasyarat Console terpenuhi.

---

## 7. Checklist rilis UAT (per build)

### Sebelum build

- [ ] API staging sehat; akun demo siap
- [ ] `versionCode` sudah dinaikkan
- [ ] `API_BASE_URL` HTTPS benar untuk UAT
- [ ] Tidak ada secret di source / log debug sensitif

### Build & upload

- [ ] `flutter build appbundle --release --dart-define=...`
- [ ] Upload AAB ke Internal testing
- [ ] Rollout started; status Available
- [ ] Release notes diisi

### Setelah Available

- [ ] Satu perangkat tim verifikasi install/update
- [ ] Stakeholder diberitahu (link invite hanya untuk anggota baru)
- [ ] Catat `versionName` / `versionCode` di catatan UAT

---

## 8. Troubleshooting singkat

| Gejala | Periksa |
|--------|---------|
| Tester tidak bisa install | Email belum di list / belum accept invite / salah akun Google di HP |
| Upload ditolak `versionCode` | Naikkan `versionCode` lebih tinggi dari release sebelumnya |
| App crash saat buka API | `API_BASE_URL`, cleartext, certificate, `ALLOWED_HOSTS` |
| Update tidak muncul | Tunggu propagasi Play; buka halaman app di Play Store; clear cache Play |
| Service account upload gagal (nanti CI) | Permission Play Console API + app linked ke service account |

---

## 9. Referensi silang

| Dokumen | Isi terkait |
|---------|-------------|
| `08-task-list.md` § Fase 7 | Build AAB, listing, internal testing |
| `11-security-and-privacy.md` §9–10 | Privacy policy, data safety, checklist go-live |
| `02-architecture-and-stack.md` § Environment | Pola URL API |
| `README.md` | Tabel `API_BASE_URL` lokal vs production |
| `lib/config/constants.dart` | `String.fromEnvironment('API_BASE_URL')` |

---

## 10. Definisi selesai (untuk jalur ini)

**Play Internal UAT Ready** bila:

1. App ada di Play Console dengan Internal testing track aktif  
2. Minimal satu AAB release **Available** mengarah ke API HTTPS yang benar  
3. Minimal satu stakeholder eksternal berhasil install dari invite link  
4. Tim punya prosedur (manual atau CI) untuk naikkan `versionCode` + upload ulang  

Go-live production track **bukan** bagian dokumen ini — tetap Fase 7 penuh + checklist keamanan.
