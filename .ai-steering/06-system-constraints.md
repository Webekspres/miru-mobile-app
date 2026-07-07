# 06 — System Constraints (Mobile)

## ⚠️ Batasan KERAS — Jangan Implementasikan di Mobile

### 1. TIDAK ADA Pembayaran Otomatis
- **Jangan** tambahkan button "Bayar Sekarang" atau integrasi payment gateway.
- Tarik saldo hanya mengajukan permintaan — pembayaran dilakukan MANUAL oleh admin.

### 2. TIDAK ADA Live GPS Tracking
- **Jangan** implementasikan real-time location sharing atau map tracking.
- Cukup tampilkan alamat penjemputan sebagai text.
- Status penjemputan diperbarui MANUAL oleh petugas.

### 3. TIDAK ADA Scan KTP/Face Recognition
- **Jangan** minta KTP atau face recognition saat registrasi.
- Registrasi cukup dengan data dasar (nama, username, password, no HP, alamat).
- NIK opsional.

### 4. TIDAK ADA Integrasi Dukcapil
- NIK hanya text field biasa — tidak divalidasi ke database kependudukan.

### 5. Hanya Nasabah yang Login
- Aplikasi mobile **hanya untuk nasabah**.
- Tidak ada login untuk petugas, admin, atau role lain.
- Tidak ada fitur admin di mobile.

### 6. Prioritas Android
- Aplikasi dikembangkan untuk Android terlebih dahulu.
- iOS menyusul (post-MVP).
- Jangan gunakan plugin yang hanya support iOS tanpa alternatif Android.

### 7. Koneksi Internet Diperlukan
- Aplikasi membutuhkan koneksi internet untuk berfungsi (online-first).
- Tidak perlu implementasi offline mode di tahap MVP.
- Tampilkan pesan yang jelas jika tidak ada koneksi.

### 8. Bahasa Indonesia
- Semua teks UI dalam Bahasa Indonesia.
- Format angka: Rp1.000,00 (Indonesia format).
- Format tanggal: 3 Juli 2026.

---

## Referensi

| Dokumen | Isi |
|---------|-----|
| `10-integration-and-roles.md` | Role mobile & alur integrasi |
| **miru-backend-api** — `.ai-steering/06-system-constraints.md` | Batasan sistem lengkap |
