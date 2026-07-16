import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../widgets/miru_logo.dart';
import '../../providers/settings_provider.dart';

class TentangScreen extends StatefulWidget {
  const TentangScreen({super.key});

  @override
  State<TentangScreen> createState() => _TentangScreenState();
}

class _TentangScreenState extends State<TentangScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang ${AppConstants.appName}'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          final settings = provider.settings;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Logo & Nama ──
              Center(
                child: Column(
                  children: [
                    const MiruLogo(
                      variant: MiruLogoVariant.fullBg,
                      height: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      settings?.namaInstitusi ?? 'MIRU Bank Sampah',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.appName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'v1.0.0',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Slogan ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '"Sampah Bernilai, Lingkungan Bersih, Warga Sejahtera"',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // ── Informasi Aplikasi ──
              _TentangSection(
                theme: theme,
                title: 'Tentang Aplikasi',
                icon: Icons.info_outline,
                iconBgColor: const Color(0xFFDCFCE7),
                iconColor: AppTheme.primaryColor,
                children: [
                  'Aplikasi ${AppConstants.appName} adalah platform digital bank sampah '
                      'yang dikelola oleh Pemerintah Distrik Mimika Baru, Kabupaten '
                      'Mimika, Provinsi Papua Tengah.',
                  'Aplikasi ini memungkinkan masyarakat untuk berpartisipasi dalam '
                      'program bank sampah: mendaftar sebagai nasabah, mengecek '
                      'saldo, mengajukan penjemputan sampah, menarik saldo, '
                      'menukar poin, dan mengajukan pengaduan.',
                ],
              ),
              const SizedBox(height: 16),

              // ── Informasi Institusi ──
              _TentangSection(
                theme: theme,
                title: 'Informasi Institusi',
                icon: Icons.business_outlined,
                iconBgColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
                children: [
                  settings != null
                      ? '${settings.namaInstitusi}\n${settings.alamat}'
                      : 'MIRU Bank Sampah\nDistrik Mimika Baru\nKabupaten Mimika, Papua Tengah',
                  'Jam Layanan:\n${settings?.jamOperasional ?? 'Senin – Sabtu: 08.00 – 17.00 WIT'}',
                ],
              ),
              const SizedBox(height: 16),

              // ── Kontak ──
              _TentangSection(
                theme: theme,
                title: 'Kontak',
                icon: Icons.contact_phone_outlined,
                iconBgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                children: [
                  settings != null
                      ? 'Telepon: ${settings.kontak}\nEmail: ${settings.email}\nAlamat: ${settings.alamat}'
                      : 'Telepon: 08123456789\nEmail: miru@banksampah.id\nAlamat: Kantor Distrik Mimika Baru, Timika',
                ],
              ),
              const SizedBox(height: 16),

              // ── Teknologi ──
              _TentangSection(
                theme: theme,
                title: 'Teknologi',
                icon: Icons.code_outlined,
                iconBgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF7C3AED),
                children: [
                  'Dikembangkan dengan Flutter & Django REST Framework.\n'
                      'Dirancang untuk masyarakat Distrik Mimika Baru.',
                ],
              ),
              const SizedBox(height: 32),

              // ── Copyright ──
              Center(
                child: Text(
                  '© 2026 Pemerintah Distrik Mimika Baru\n'
                  'Hak Cipta Dilindungi',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // ── Loading indicator for settings ──
              if (provider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Tentang Section
// ─────────────────────────────────────────────

class _TentangSection extends StatelessWidget {
  const _TentangSection({
    required this.theme,
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.children,
  });

  final ThemeData theme;
  final String title;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final List<String> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
