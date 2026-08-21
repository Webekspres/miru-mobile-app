# 10 — Integration & Roles (Mobile App)

> Dokumen ini mendefinisikan **role mobile (nasabah)**, **alur integrasi** dengan backend & web admin, dan **batasan akses**.
>
> **Referensi backend:** repositori **miru-backend-api** — `.ai-steering/01-project-overview.md` §6 Role Pengguna

---

## 1. Role di Mobile App

Mobile app **hanya** untuk **nasabah**. Semua role staff menggunakan web admin.

| Role | Kode API | Login Mobile | Aplikasi |
|------|----------|--------------|----------|
| **Nasabah** | `nasabah` | ✅ | Mobile App |
| Petugas | `petugas` | ❌ | Web Admin |
| Admin | `admin` | ❌ | Web Admin |
| Koordinator | `koordinator` | ❌ | Web Admin |
| Pemerintah Distrik | `pemerintah` | ❌ | Web Admin |
| Mitra/Pengepul | — | ❌ | — |

### Login Guard

```dart
const allowedRoles = {'nasabah'};

if (!allowedRoles.contains(user.role)) {
  throw ApiException(
    'Akun petugas/admin hanya dapat login melalui Web Admin MIRU.',
  );
}
```

---

## 2. Matriks Fitur Nasabah vs Staff

| Fitur | Nasabah (Mobile) | Petugas/Admin (Web) |
|-------|:----------------:|:-------------------:|
| Registrasi akun | ✅ | ❌ (admin create staff) |
| Login | ✅ | ✅ (web admin) |
| Lihat profil sendiri | ✅ | ✅ (admin lihat semua) |
| QR Code ID | ✅ | ❌ (scan saja) |
| Lihat harga sampah | ✅ (read) | ✅ (CRUD) |
| Input setoran | ❌ | ✅ |
| Ajukan penjemputan | ✅ | ❌ (kelola status) |
| Update status penjemputan | ❌ | ✅ |
| Ajukan penarikan | ✅ | ❌ (approve) |
| Approve penarikan | ❌ | ✅ |
| Tukar poin | ✅ (ajukan) | ❌ (approve) |
| Ajukan pengaduan | ✅ | ❌ (tindak lanjut) |
| Dashboard program | ❌ | ✅ |
| Laporan | ❌ | ✅ |

---

## 3. Alur User Journey Nasabah

### 3.1 Onboarding

```
[Install App]
    ↓
[SplashScreen → cek token tersimpan]
    ↓
[Belum login → LoginScreen / RegisterScreen]
    ↓
[POST /api/auth/login/ atau POST /api/users/]
    ↓
[Validasi role == nasabah]
    ↓
[HomeScreen — dashboard saldo & poin]
```

### 3.2 Setor Sampah (Langsung ke Bank)

Nasabah **tidak** input setoran di mobile. Alurnya:

```
[Nasabah bawa sampah fisik ke lokasi bank]
    ↓
[Tunjukkan QR Code di mobile]
    ↓
[Petugas scan → input setoran di Web Admin]
    ↓
[Backend update saldo & poin]
    ↓
[Nasabah pull-to-refresh HomeScreen / RiwayatScreen]
```

### 3.3 Penjemputan Sampah

```
[HomeScreen → Ajukan Penjemputan]
    ↓
[Form: jenis, estimasi berat (min 5 kg), alamat, jadwal (min H+1)]
    ↓
[POST /api/pickups/]
    ↓
[PenjemputanScreen — status: menunggu]
    ↓
[Petugas update status di Web Admin]
    ↓
[Mobile refresh — badge status berubah]
    ↓
[Status selesai → muncul di riwayat setoran jika sudah ditimbang]
```

### 3.4 Penarikan Saldo

```
[TarikSaldoScreen — input nominal min Rp50.000]
    ↓
[Validasi: nominal <= saldo]
    ↓
[POST /api/withdrawals/]
    ↓
[Status: menunggu]
    ↓
[Admin approve di Web Admin — saldo berkurang otomatis]
    ↓
[Admin bayar TUNAI/transfer manual]
    ↓
[Mobile: status selesai]
```

### 3.5 Tukar Poin

```
[RewardScreen — pilih reward]
    ↓
[Validasi: poin >= reward.poin_dibutuhkan, stok > 0]
    ↓
[POST /api/reward-redemptions/]
    ↓
[Admin serahkan reward fisik → approve di Web Admin]
    ↓
[Mobile: status selesai, poin berkurang]
```

---

## 4. Data yang Bisa Diakses Nasabah

Nasabah hanya bisa akses **data milik sendiri** (enforced backend via `IsOwnerOrAdmin`):

| Resource | Scope Nasabah |
|----------|---------------|
| Profil | `GET/PATCH /api/users/{own_id}/` |
| Setoran | `GET /api/deposits/?nasabah={own_id}` |
| Penjemputan | `GET/POST /api/pickups/` (own only) |
| Penarikan | `GET/POST /api/withdrawals/` (own only) |
| Penukaran | `GET/POST /api/reward-redemptions/` (own only) |
| Pengaduan | `GET/POST /api/complaints/` (own only) |
| Kategori sampah | `GET /api/waste-categories/` (public) |
| Reward katalog | `GET /api/rewards/` |

---

## 5. QR Code — Kartu Digital

Data yang di-encode (JSON):

```json
{
  "id": 15,
  "nama_lengkap": "Budi Santoso",
  "no_hp": "08123456789"
}
```

- Petugas scan → lookup `GET /api/users/15/`
- **Jangan** encode token JWT di QR
- QR hanya identitas nasabah, bukan credential

---

## 6. Integrasi dengan Web Admin

| Aksi Nasabah (Mobile) | Respons Staff (Web Admin) |
|-----------------------|---------------------------|
| Registrasi | Admin verifikasi/aktivasi (jika diperlukan) |
| Ajukan penjemputan | Petugas approve & jadwalkan |
| — | Petugas input setoran setelah timbang |
| Ajukan penarikan | Admin approve & bayar manual |
| Tukar poin | Admin approve & serahkan reward |
| Ajukan pengaduan | Admin tindak lanjut |

---

## 7. Dependensi Backend

| Fitur Mobile | Endpoint | Status Backend |
|--------------|----------|----------------|
| Login/Register | `/api/auth/*`, `/api/users/` | ✅ |
| Profil & saldo | `/api/auth/me/` | ✅ |
| Harga sampah | `/api/waste-categories/` | ✅ |
| Penjemputan | `/api/pickups/` | ✅ CRUD + status machine + assign petugas |
| Penarikan | `/api/withdrawals/` | ✅ CRUD dasar |
| Reward | `/api/rewards/`, `/api/reward-redemptions/` | ✅ CRUD dasar |
| Pengaduan | `/api/complaints/` | ✅ CRUD dasar |
| Notifikasi in-app | `/api/notifications/` | ✅ list / mark-read / mark-all (Modul 9) |
| Push FCM (OS) | `/api/device-tokens/` + FCM backend | 🔲 Fase 8 — client Flutter belum |
| Pengumuman / edukasi | `/api/pengumuman/`, edukasi API | ✅ (banner beranda; artikel lanjutan) |

Progress backend: **miru-backend-api** — `.ai-steering/08-task-list.md`

---

## 8. Diagram Arsitektur

```
┌─────────────────────────────────────────────────────────┐
│                 MOBILE APP (Flutter)                     │
│                                                          │
│  Splash → Auth (JWT) → Home → [Fitur Nasabah]           │
│                              │                           │
│                    Provider + Dio Client                 │
│                    (JSON Envelope unwrap)                │
└────────────────────────────┬────────────────────────────┘
                             │ HTTPS + JWT
                             ▼
┌─────────────────────────────────────────────────────────┐
│              BACKEND (Django REST API)                   │
│         Permission: IsOwnerOrAdmin untuk data nasabah    │
└────────────────────────────┬────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────┐
│              WEB ADMIN (Staff Operations)                │
│    Setoran │ Penjemputan │ Approve │ Laporan             │
└─────────────────────────────────────────────────────────┘
```

---

## 9. Checklist Implementasi

- [ ] Auth guard: hanya `role == nasabah'`
- [ ] Token di `flutter_secure_storage`
- [ ] Envelope interceptor unwrap `data`
- [ ] Auto refresh token on 401
- [ ] Pull-to-refresh di Home & Riwayat
- [ ] Validasi form sesuai business rules (`05-business-rules-sops.md`)
- [ ] Pesan error Bahasa Indonesia
- [ ] Offline/network error handling
- [ ] QR code screen tanpa sensitive data
