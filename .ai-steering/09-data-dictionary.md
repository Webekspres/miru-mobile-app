# 09 — Data Dictionary & Reference Values (Mobile)

> **Sumber:** Dokumen jawaban klien (2 Juli 2026), SOP Aplikasi MIRU Bank Sampah
>
> **Referensi data lengkap:** repositori **miru-backend-api** — `.ai-steering/09-data-dictionary.md`

---

## A. INFORMASI HARGA — Tampilkan di Home & Info Sampah

Harga yang ditampilkan ke nasabah di aplikasi mobile:

| Kategori | Harga (Rp/kg) | Contoh |
|----------|--------------|--------|
| 🥤 Plastik PET | **Rp3.000** | Botol air mineral |
| 🥤 Gelas Plastik | **Rp4.000** | Gelas minuman |
| 📦 Kardus | **Rp1.500** | Kardus kemasan |
| 📄 Kertas Putih | **Rp2.000** | Buku bekas, koran |
| 🥫 Aluminium | **Rp10.000** | Kaleng minuman |
| 🔩 Besi/Logam | **Rp3.000** | Besi tua |
| 🍾 Kaca | **Rp500** | Botol sirup |
| 🛢️ Minyak Jelantah | **Rp5.000/liter** | Minyak goreng bekas |

> ⚠️ Tampilkan keterangan: "Harga dapat berubah sewaktu-waktu. Update terakhir: [tanggal]"

---

## B. PANDUAN PEMILAHAN (untuk Info Edukasi)

| Jenis | Contoh | Tips |
|-------|--------|------|
| Plastik | Botol, gelas, kemasan bersih | Bilas, keringkan, pipihkan botol |
| Kertas | Koran, buku, kardus | Pisahkan dari plastik, jaga tetap kering |
| Logam | Kaleng, besi | Bersihkan dari sisa makanan |
| Kaca | Botol | Bungkus dengan aman |
| Minyak Jelantah | Minyak goreng bekas | Simpan dalam botol tertutup |

> Ketentuan: Sampah sebaiknya dalam kondisi **kering dan bersih**. Minimal setoran **1 kg per jenis**.

---

## C. KATALOG REWARD (tampilkan di menu Tukar Poin)

| Reward | Poin Dibutuhkan | Stok |
|--------|-----------------|------|
| 📱 Pulsa Rp10.000 | **100 poin** | (dari database) |
| 🌱 Bibit Tanaman | **50 poin** | (dari database) |
| 🎁 Sembako | **250 poin** | (dari database) |
| 🧹 Alat Kebersihan | **300 poin** | (dari database) |

> **Info tambahan:** Poin tidak dapat diuangkan. Masa berlaku poin: **1 tahun**.

---

## D. STATUS PENJEMPUTAN — Warna & Ikon untuk UI

| Status | Warna | Ikon | Teks Tampilan |
|--------|-------|------|--------------|
| menunggu | 🟡 **Kuning** (#EAB308) | ⏳ | Menunggu Persetujuan |
| disetujui | 🟢 **Hijau** (#22C55E) | ✅ | Disetujui |
| dijadwalkan | 🔵 **Biru** (#3B82F6) | 📅 | Terjadwal |
| dalam_perjalanan | 🟠 **Oranye** (#F97316) | 🚚 | Dalam Perjalanan |
| dijemput | 🟣 **Ungu** (#A855F7) | 📦 | Sampah Diambil |
| selesai | ⚪ **Abu-abu** (#6B7280) | ✅ | Selesai |
| ditolak | 🔴 **Merah** (#EF4444) | ❌ | Ditolak |

---

## E. INDIKATOR POIN (informasi di halaman Tukar Poin)

| Informasi | Detail |
|-----------|--------|
| Cara dapat poin | Setiap Rp1.000 setoran = **1 poin** |
| Masa berlaku | **1 tahun** sejak didapat |
| Penukaran | Via aplikasi, ambil reward di kantor |
| Poin tidak bisa | **Diuangkan** (hanya untuk reward) |

---

## F. JENIS PENGADUAN (untuk dropdown pilihan)

1. Saldo belum masuk
2. Jadwal penjemputan terlambat
3. Berat sampah tidak sesuai
4. Harga sampah tidak sesuai
5. Petugas tidak datang
6. Kesalahan data nasabah
7. Bukti transaksi tidak muncul

> Maksimal 500 karakter untuk deskripsi pengaduan.

---

## G. FORMAT TAMPILAN DATA

### Format Rupiah
```
Rp1.000.000  → Tampilkan tanpa desimal untuk nilai bulat
Rp1.500,50  → Tampilkan 2 desimal untuk nilai pecahan
```

### Format Berat
```
5 kg      → Integer tanpa desimal
5.5 kg    → 1 desimal
```

### Format Tanggal
```
3 Juli 2026          → Format Indonesia
3 Jul 2026, 10:30    → Format singkat
Hari ini, 10:30      → Relative (hari yang sama)
Kemarin, 10:30       → Relative (H-1)
```

### Format Poin
```
1.250 poin  → Gunakan pemisah ribuan
```

---

## H. STATUS BADGE TEXT UNTUK UI

### Status Transaksi
| Status | Teks |
|--------|------|
| selesai | ✅ Selesai |
| menunggu | ⏳ Menunggu |

### Status Penjemputan
| Status | Teks |
|--------|------|
| menunggu | ⏳ Menunggu Persetujuan |
| disetujui | ✅ Disetujui |
| dijadwalkan | 📅 Terjadwal [tanggal] |
| dalam_perjalanan | 🚚 Dalam Perjalanan |
| dijemput | 📦 Sampah Diambil |
| selesai | ✅ Selesai |
| ditolak | ❌ Ditolak |

### Status Pengaduan
| Status | Teks |
|--------|------|
| terbuka | 🟡 Diproses |
| ditutup | ✅ Selesai |
