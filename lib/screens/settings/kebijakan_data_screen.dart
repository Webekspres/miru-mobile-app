import 'package:flutter/material.dart';

import '../../config/theme.dart';

class KebijakanDataScreen extends StatelessWidget {
  const KebijakanDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebijakan Data'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ──
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.privacy_tip_outlined,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Kebijakan Perlindungan Data Pribadi',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'MIRU Bank Sampah',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Berlaku efektif: 1 Juli 2026',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // ── Isi Kebijakan ──
          _buildSection(
            theme: theme,
            title: '1. Pendahuluan',
            content:
                'MIRU Bank Sampah ("kami", "MIRU") berkomitmen untuk melindungi '
                'data pribadi Anda. Kebijakan ini menjelaskan bagaimana kami '
                'mengumpulkan, menggunakan, menyimpan, dan melindungi data '
                'pribadi Anda sesuai dengan Undang-Undang Perlindungan Data '
                'Pribadi (UU PDP) Nomor 27 Tahun 2022.',
          ),
          const SizedBox(height: 20),

          _buildSection(
            theme: theme,
            title: '2. Data yang Dikumpulkan',
            content:
                'Kami mengumpulkan data pribadi berikut saat Anda mendaftar '
                'dan menggunakan aplikasi Miru G:\n\n'
                '• Nama lengkap\n'
                '• Nomor handphone\n'
                '• Alamat tempat tinggal\n'
                '• Username dan password\n'
                '• NIK (opsional)\n'
                '• Riwayat transaksi (setoran, penarikan, penukaran poin)\n'
                '• Foto profil (jika diunggah)',
          ),
          const SizedBox(height: 20),

          _buildSection(
            theme: theme,
            title: '3. Tujuan Penggunaan Data',
            content:
                'Data pribadi Anda digunakan untuk:\n\n'
                '• Membuat dan mengelola akun Miru G Anda\n'
                '• Memproses transaksi setoran, penarikan, dan penukaran poin\n'
                '• Menghubungi Anda terkait jadwal penjemputan\n'
                '• Memberikan informasi mengenai program bank sampah\n'
                '• Meningkatkan kualitas layanan Miru G\n'
                '• Memenuhi kewajiban pelaporan kepada pemerintah daerah',
          ),
          const SizedBox(height: 20),

          _buildSection(
            theme: theme,
            title: '4. Penyimpanan dan Keamanan',
            content:
                'Data pribadi Anda disimpan di server yang aman dengan '
                'enkripsi. Kami menerapkan langkah-langkah keamanan teknis '
                'dan organisasi untuk melindungi data Anda dari akses tidak '
                'sah, perubahan, pengungkapan, atau penghancuran yang tidak sah.',
          ),
          const SizedBox(height: 20),

          _buildSection(
            theme: theme,
            title: '5. Hak Anda',
            content:
                'Sebagai pemilik data pribadi, Anda memiliki hak untuk:\n\n'
                '• Mengakses data pribadi Anda\n'
                '• Memperbaiki data yang tidak akurat\n'
                '• Menghapus data pribadi Anda (permintaan penonaktifan akun)\n'
                '• Membatasi pemrosesan data Anda\n'
                '• Menarik persetujuan penggunaan data\n\n'
                'Untuk menggunakan hak-hak tersebut, silakan hubungi kami '
                'melalui kontak yang tertera di aplikasi.',
          ),
          const SizedBox(height: 20),

          _buildSection(
            theme: theme,
            title: '6. Pembagian Data dengan Pihak Ketiga',
            content:
                'Kami tidak membagikan data pribadi Anda kepada pihak ketiga, '
                'kecuali:\n\n'
                '• Atas persetujuan eksplisit dari Anda\n'
                '• Untuk memenuhi kewajiban hukum dan peraturan\n'
                '• Dalam rangka kerja sama dengan pemerintah daerah setempat\n\n'
                'Data Anda tidak akan dijual atau disewakan kepada pihak mana pun.',
          ),
          const SizedBox(height: 20),

          _buildSection(
            theme: theme,
            title: '7. Masa Retensi Data',
            content:
                'Kami menyimpan data pribadi Anda selama akun Anda masih '
                'aktif. Setelah akun dinonaktifkan, data akan disimpan '
                'untuk jangka waktu yang diperlukan sesuai dengan ketentuan '
                'peraturan perundang-undangan yang berlaku.',
          ),
          const SizedBox(height: 20),

          _buildSection(
            theme: theme,
            title: '8. Perubahan Kebijakan',
            content:
                'Kebijakan ini dapat diperbarui dari waktu ke waktu. '
                'Perubahan akan diumumkan melalui aplikasi Miru G. '
                'Dengan terus menggunakan aplikasi setelah perubahan, '
                'Anda menyetujui kebijakan yang telah diperbarui.',
          ),
          const SizedBox(height: 20),

          _buildSection(
            theme: theme,
            title: '9. Kontak',
            content:
                'Jika Anda memiliki pertanyaan mengenai kebijakan data '
                'ini, silakan hubungi:\n\n'
                'MIRU Bank Sampah\n'
                'Distrik Mimika Baru, Timika\n'
                'Email: miru@banksampah.id\n'
                'Telepon: 08123456789',
          ),
          const SizedBox(height: 32),

          // ── Footer ──
          Center(
            child: Text(
              'Terakhir diperbarui: 1 Juli 2026',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
