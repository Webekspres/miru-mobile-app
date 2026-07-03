# 07 — Modules & Features (Mobile)

## 14 Fitur Mobile — untuk Nasabah

Dari 17 modul sistem, **14 modul** memiliki komponen mobile (3 modul khusus web admin).

| No | Modul | Halaman Mobile | Fitur |
|----|-------|----------------|-------|
| 1 | Manajemen Akses | ❌ (admin only) | - |
| 2 | **Autentikasi** | `LoginScreen`, `RegisterScreen` | Login, register, logout, lupa password |
| 3 | **Profil & Kartu Digital** | `ProfileScreen`, `QRCodeScreen` | Lihat/edit profil, QR code ID |
| 4 | **Info & Edukasi** | `InfoSampahScreen` | List kategori, harga, panduan pemilahan |
| 5 | Katalog & Harga | (bagian dari InfoSampah) | Lihat harga per kg |
| 6 | Setor Langsung | ❌ (dilakukan petugas) | - |
| 7 | **Penjemputan** | `PenjemputanScreen`, `PengajuanScreen` | Ajukan jemput, cek status |
| 8 | Penimbangan | ❌ (dilakukan petugas) | - |
| 9 | **Saldo & Riwayat** | `SaldoScreen`, `RiwayatScreen` | Cek saldo, riwayat transaksi |
| 10 | **Tarik Saldo** | `TarikSaldoScreen` | Ajukan penarikan |
| 11 | **Poin & Reward** | `RewardScreen`, `TukarPoinScreen` | Lihat reward, tukar poin |
| 12 | Stok Gudang | ❌ (admin only) | - |
| 13 | Penjualan Mitra | ❌ (admin only) | - |
| 14 | **Pengaduan** | `PengaduanScreen`, `PengaduanForm` | Ajukan pengaduan, cek status |
| 15 | Dashboard | `HomeScreen` | Ringkasan saldo, poin, info terbaru |
| 16 | Laporan | ❌ (admin only) | - |
| 17 | Pengaturan | `SettingsScreen` | Notifikasi, about, logout |

## Desain Halaman

### HomeScreen (Dashboard)
```
┌─────────────────────────────┐
│ MIRU Bank Sampah            │
│                             │
│ ┌─────────────────────────┐ │
│ │ Rp 125.000              │ │  ← Saldo (besar)
│ │ Saldo Tabungan            │ │
│ └─────────────────────────┘ │
│                             │
│ Poin: 125 poin              │  ← Poin
│                             │
│ ┌─────────┐ ┌─────────┐    │
│ │ Jemput   │ │ Tarik   │    │  ← Quick actions
│ │ Sampah   │ │ Saldo   │    │
│ └─────────┘ └─────────┘    │
│ ┌─────────┐ ┌─────────┐    │
│ │ Tukar   │ │ Info    │    │
│ │ Poin    │ │ Sampah  │    │
│ └─────────┘ └─────────┘    │
│                             │
│ Info Harga Sampah:          │
│ 🥤 Plastik: Rp3.000/kg     │
│ 📦 Kardus: Rp1.500/kg      │
│ 🥫 Aluminium: Rp10.000/kg  │
│                             │
│ Aktivitas Terbaru:          │
│ • 3 Jul - Setoran +Rp15.000│
│ • 2 Jul - Setoran +Rp8.500 │
│ • 1 Jul - Tarik -Rp50.000  │
└─────────────────────────────┘
```

### PenjemputanScreen
```
┌─────────────────────────────┐
│ ← Penjemputan      [+ Ajukan]│
│                             │
│ [Aktif] [Riwayat]          │  ← Tab
│                             │
│ 🟡 Menunggu                 │
│ 5 kg - 4 Jul 2026           │
│ Jl. Merdeka No. 10          │
│                             │
│ 🟢 Disetujui                │
│ 3 kg - 3 Jul 2026           │
│ Jl. Sudirman No. 5          │
└─────────────────────────────┘
```

### TarikSaldoScreen
```
┌─────────────────────────────┐
│ ← Tarik Saldo               │
│                             │
│ Saldo Anda: Rp125.000       │
│                             │
│ Nominal Penarikan:          │
│ ┌─────────────────────────┐ │
│ │ Rp                       │ │
│ └─────────────────────────┘ │
│ Minimal Rp50.000            │
│                             │
│ [Metode: Tunai]             │
│                             │
│ ┌─────────────────────────┐ │
│ │     Ajukan Penarikan    │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

### RewardScreen
```
┌─────────────────────────────┐
│ ← Tukar Poin                │
│                             │
│ Poin Anda: 125 poin         │
│                             │
│ 🎁 Pulsa Rp10.000           │
│   100 poin  Stok: 5        │
│   [Tukar]                   │
│                             │
│ 🌱 Bibit Tanaman            │
│   50 poin  Stok: 10         │
│   [Tukar]                   │
│                             │
│ 📦 Sembako                  │
│   250 poin  Stok: 2         │
│   (poin tidak cukup)        │
└─────────────────────────────┘
```
