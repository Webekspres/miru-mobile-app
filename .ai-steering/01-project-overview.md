# 01 — Project Overview (Mobile App)

## Latar Belakang

Aplikasi mobile **MIRU Bank Sampah (Miru-G)** memungkinkan masyarakat Distrik Mimika Baru berpartisipasi dalam program bank sampah digital: daftar, cek saldo, ajukan penjemputan, tarik saldo, tukar poin, dan ajukan pengaduan.

> **"Sampah Bernilai, Lingkungan Bersih, Warga Sejahtera"**

Mobile app adalah klien **nasabah**; MVP layar utama selesai. Kerja aktif = UAT/Production + **Fase 8 lanjutan** (modul 2–5, 7, 9–11, 14–15, 17 saja).

## Posisi dalam Ekosistem

Ketiga proyek MIRU adalah **repositori GitHub terpisah**, terintegrasi via REST API:

```
mirumobileapp (Nasabah) ← repo ini    miru-web-admin (Staff)
        │                                  │
        └──────── JWT + JSON Envelope ─────┘
                         │
              miru-backend-api (Django REST API)
```

## Target Pengguna

| Role | Akses Mobile | Keterangan |
|------|--------------|------------|
| **Nasabah/Masyarakat** | ✅ Pengguna utama | Registrasi, dashboard, penjemputan, saldo, reward, pengaduan |
| Petugas | ❌ | Gunakan repositori **miru-web-admin** |
| Admin | ❌ | Gunakan **miru-web-admin** |
| Koordinator | ❌ | Gunakan **miru-web-admin** |
| Pemerintah Distrik | ❌ | Gunakan **miru-web-admin** |
| Mitra/Pengepul | ❌ | Tidak punya login |

Detail alur nasabah: **`10-integration-and-roles.md`**

## Fitur Utama (Mobile — Nasabah)

| Fitur | Deskripsi |
|-------|-----------|
| **Registrasi & Login** | Daftar akun baru, login/logout, JWT persistence |
| **Dashboard** | Saldo, poin, aktivitas terbaru, info harga sampah |
| **Kartu Digital** | QR Code ID nasabah untuk scan petugas |
| **Info Sampah** | Jenis sampah, harga per kg, panduan pemilahan |
| **Ajukan Penjemputan** | Pilih jenis, estimasi berat, alamat, jadwal |
| **Cek Status Jemput** | Lihat status penjemputan aktif |
| **Riwayat Transaksi** | Setoran, penarikan, penukaran poin |
| **Tarik Saldo** | Ajukan pencairan saldo (min Rp50.000) |
| **Tukar Poin** | Lihat reward, tukar poin |
| **Pengaduan** | Ajukan keluhan, cek status |

## Platform

| Platform | Status | Prioritas |
|----------|--------|-----------|
| Android | 🎯 Target utama | 1 |
| iOS | Menyusul | 2 (post-MVP) |

## Informasi Branding

| Item | Detail |
|------|--------|
| Nama Aplikasi | **MIRU Bank Sampah** (Miru-G) |
| Slogan | "Sampah Bernilai, Lingkungan Bersih, Warga Sejahtera" |
| Tema Warna | Hijau `#16a34a` |
| Bahasa UI | Bahasa Indonesia |
| Format angka | Rp125.000,00 |
| Format tanggal | 3 Juli 2026 |

## Jam Layanan

Senin–Sabtu, 08.00–17.00 WIT. Informasikan di home screen jika di luar jam layanan.

## Standar Integrasi dengan Backend

| Aspek | Standar | Referensi |
|-------|---------|-----------|
| Auth | `/api/auth/login/`, `/api/auth/refresh/`, `/api/auth/me/` | **miru-backend-api** — `.ai-steering/04-api-contracts-and-standards.md` |
| Registrasi | `POST /api/users/` (public, role default `nasabah`) | §6.2 dokumen di atas |
| Response | JSON Envelope — baca dari field `data` | §3 dokumen di atas |
| Emulator Android | `http://10.0.2.2:8000` | Mapping localhost host |

## Referensi Dokumen Terkait

| Topik | File |
|-------|------|
| Kontrak API lengkap | **miru-backend-api** — `.ai-steering/04-api-contracts-and-standards.md` |
| Integrasi Dio & envelope | `04-api-integration.md` |
| Alur nasabah & batasan | `10-integration-and-roles.md` |
| Business rules (UI) | `05-business-rules-sops.md` |
| System constraints | `06-system-constraints.md` |
| Wireframe & modul | `07-modules-and-features.md` |
| Roadmap | `08-task-list.md` |
| Data dictionary | `09-data-dictionary.md` |
