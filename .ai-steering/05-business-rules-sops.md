# 05 — Business Rules & SOPs (Mobile)

> **Referensi lengkap**: repositori **miru-backend-api** — `.ai-steering/05-business-rules-sops.md`
> **Data referensi**: Lihat `09-data-dictionary.md` untuk harga sampah, reward, status badge, format tampilan.

## Ringkasan Aturan untuk UI Mobile

### 1. Registrasi Nasabah
- Field: Nama Lengkap, Username, Password, No HP, Alamat, RT/RW, Kelurahan
- NIK opsional (tidak wajib)
- Password minimal 6 karakter
- Setelah register → langsung login → masuk dashboard

### 2. Dashboard
- Tampilkan **Saldo** (besar, menonjol)
- Tampilkan **Poin** (jumlah poin saat ini)
- Tampilkan **Info Harga Sampah** (3-4 kategori teratas)
- Tampilkan **Aktivitas Terbaru** (3 transaksi terakhir)
- Tombol cepat: [Jemput Sampah] [Tarik Saldo] [Tukar Poin]
- **Jam layanan**: Senin–Sabtu, 08.00–17.00 WIT — informasikan di footer/home jika di luar jam layanan
- **Wilayah penjemputan**: Tahap awal terbatas — tampilkan pemberitahuan jika alamat di luar wilayah layanan

### 3. Informasi Sampah
- List kategori sampah: nama, harga per kg, contoh sampah
- Panduan pemilahan singkat
- **Minimal setoran**: 1 kg per jenis

### 4. Ajukan Penjemputan (Form)
- Pilih jenis sampah (checkbox / multi-select)
- Estimasi berat (input number, **minimal 5 kg** — validasi di form)
- Alamat penjemputan (text field, bisa diisi manual atau pilih dari profil)
- Jadwal (date picker, minimal H+1)
- Setelah submit → tampilkan konfirmasi "Pengajuan berhasil"

### 5. Cek Status Penjemputan
- List penjemputan dengan filter: aktif (menunggu, disetujui, dijadwalkan), selesai
- Tampilkan status badge dengan warna:
  - Menunggu → 🟡 Kuning
  - Disetujui → 🟢 Hijau
  - Dijadwalkan → 🔵 Biru
  - Dalam Perjalanan → 🟠 Oranye
  - Dijemput → 🟣 Ungu
  - Selesai → ⚪ Abu-abu
  - Ditolak → 🔴 Merah

### 6. Riwayat Transaksi
- Tab: Semua, Setoran, Penarikan, Penukaran Poin
- Per item tampilkan: Tanggal, Jenis, Jumlah (Rp), Status

### 7. Tarik Saldo
- Tampilkan saldo saat ini
- Input nominal (min **Rp50.000** — validasi)
- Metode: Tunai (default), Transfer (future)
- Submit → "Pengajuan penarikan berhasil dikirim"

### 8. Tukar Poin
- Tampilkan jumlah poin saat ini
- List reward yang tersedia: Nama, Poin dibutuhkan, Stok
- Tombol [Tukar] pada reward yang poinnya cukup
- Konfirmasi: "Tukar {reward_name} dengan {poin} poin?"

### 9. Pengaduan
- Form: Input keluhan (text area, max 500 karakter)
- Setelah submit → tampilkan nomor laporan (ID) — "Pengaduan #{id} berhasil dikirim"
- Riwayat pengaduan: list dengan status (terbuka/ditutup)

### 10. Kartu Digital (QR Code)
- Tampilkan QR Code yang berisi: `{"id": 1, "nama": "Budi Santoso"}`
- Petugas bisa scan QR ini untuk memilih nasabah tanpa search
- QR Code bisa di-screenshot/disimpan

## Aturan Numerik Ringkas (untuk validasi di form)

| Aturan | Nilai | Dimana Validasi |
|--------|-------|-----------------|
| Min setoran | 1 kg | Form penjemputan (estimasi per jenis) |
| Min penjemputan | 5 kg (total estimasi) | Form ajukan penjemputan |
| Min tarik saldo | Rp50.000 | Form tarik saldo |
| Konversi poin | 1 poin per Rp1.000 | Ditampilkan sebagai info |
| Masa berlaku poin | 1 tahun | Info di halaman reward |
| Min jadwal penjemputan | H+1 (minimal besok) | Date picker |

## Aturan Tambahan

### 11. Standar Waktu yang Ditampilkan ke Nasabah
| Layanan | Info Tampilan |
|---------|--------------|
| Verifikasi pendaftaran | "Proses verifikasi maksimal 1 hari kerja" |
| Konfirmasi penjemputan | "Konfirmasi maksimal 1 hari kerja" |
| Penarikan saldo | "Pemrosesan maksimal 1–2 hari kerja" |
| Pengaduan | "Ditindaklanjuti maksimal 2 hari kerja" |

### 12. Jam Layanan
Tampilkan informasi jam layanan di halaman profil atau footer:
- **Senin – Sabtu: 08.00 – 17.00 WIT**
- **Minggu & Hari Libur: Libur**
- Penjemputan: Max 2x/minggu/wilayah, pesan H-1

### 13. Informasi Penting Lainnya
- Penjemputan **tahap awal** terbatas pada kelurahan sekitar kantor distrik
- Poin tidak bisa diuangkan
- Minimal 1 kg per jenis sampah per setoran
