import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_session.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/exit_dialog.dart';
import '../../widgets/error_view.dart';
import '../../widgets/login_prompt.dart';
import '../../widgets/bottom_nav_scaffold.dart';
import '../../widgets/shimmer_loading.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  void _loadProfile() {
    final profile = context.read<ProfileProvider>();
    if (!profile.isLoading && profile.user == null) {
      profile.loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Saya')),
        body: const LoginPrompt(
          title: 'Profil Nasabah',
          message:
              'Masuk untuk melihat dan mengedit profil Anda, QR kartu digital, serta informasi akun.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () => context.push('/settings'),
          ),
          // Edit button — navigates to dedicated edit page
          Consumer<ProfileProvider>(
            builder: (context, profile, _) {
              if (profile.user == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit profil',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        initialUser: profile.user!,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profile, _) {
          if (profile.isLoading) {
            return _buildSkeleton(context);
          }

          if (profile.hasError && profile.user == null) {
            return ErrorView(
              title: 'Gagal memuat profil',
              message: profile.error!,
              onRetry: () => profile.loadProfile(),
            );
          }

          final user = profile.user;
          if (user == null) {
            return const ErrorView(
              title: 'Data tidak tersedia',
              message: 'Silakan coba kembali.',
            );
          }

          return RefreshIndicator(
            onRefresh: profile.loadProfile,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                BottomNavScaffold.scrollBottomPadding(context),
              ),
              child: Column(
                children: [
                  // ── Avatar & Nama ──
                  _buildAvatarSection(context, user.namaLengkap),
                  const SizedBox(height: 24),
                  // ── Kartu Digital Link ──
                  _buildQRCard(context),
                  const SizedBox(height: 20),
                  // ── Informasi Profil ──
                  _buildInfoSection(context, user),
                  const SizedBox(height: 24),
                  // ── Saldo & Poin ──
                  _buildSaldoSection(context, user),
                  const SizedBox(height: 24),
                  // ── Info Akun ──
                  _buildAccountInfo(context, user),
                  const SizedBox(height: 24),
                  // ── Logout Button ──
                  _buildLogoutSection(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Skeleton (only dynamic parts)
  // ─────────────────────────────────────────────

  Widget _buildSkeleton(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(height: 40),
          SkeletonCircle(size: 80),
          SizedBox(height: 12),
          SkeletonBlock(height: 20, width: 160),
          SizedBox(height: 24),
          SkeletonCard(height: 64),
          SizedBox(height: 24),
          SkeletonBlock(height: 14, width: 80),
          SizedBox(height: 12),
          SkeletonCard(height: 200),
          SizedBox(height: 24),
          SkeletonBlock(height: 14, width: 80),
          SizedBox(height: 12),
          SkeletonCard(height: 100),
          SizedBox(height: 24),
          SkeletonBlock(height: 14, width: 80),
          SizedBox(height: 12),
          SkeletonCard(height: 100),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Avatar Section
  // ─────────────────────────────────────────────

  Widget _buildAvatarSection(BuildContext context, String namaLengkap) {
    final initial = namaLengkap.isNotEmpty ? namaLengkap[0].toUpperCase() : 'U';
    final theme = Theme.of(context);

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          child: Text(
            initial,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          namaLengkap,
          style: theme.textTheme.titleLarge,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // QR Card
  // ─────────────────────────────────────────────

  Widget _buildQRCard(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/profile/qrcode'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF6D28D9),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kartu Digital',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tunjukkan QR code saat setor sampah',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.7),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Info Section (read-only view)
  // ─────────────────────────────────────────────

  Widget _buildInfoSection(BuildContext context, dynamic user) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Data Diri',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _StaticField(
                icon: Icons.person_outline,
                label: 'Nama Lengkap',
                value: user.namaLengkap,
              ),
              _divider(theme),
              _StaticField(
                icon: Icons.phone_outlined,
                label: 'No. Handphone',
                value: user.noHp,
              ),
              _divider(theme),
              _StaticField(
                icon: Icons.location_on_outlined,
                label: 'Alamat',
                value: user.alamat,
              ),
              _divider(theme),
              if (user.rt.isNotEmpty || user.rw.isNotEmpty) ...[
                _StaticField(
                  icon: Icons.signpost_outlined,
                  label: 'RT / RW',
                  value: [
                    if (user.rt.isNotEmpty) 'RT ${user.rt}',
                    if (user.rw.isNotEmpty) 'RW ${user.rw}',
                  ].join(' / '),
                ),
                _divider(theme),
              ],
              if (user.kelurahanNama.isNotEmpty) ...[
                _StaticField(
                  icon: Icons.location_city_outlined,
                  label: 'Kelurahan',
                  value: user.kelurahanNama,
                ),
                _divider(theme),
              ],
              _StaticField(
                icon: Icons.badge_outlined,
                label: 'NIK',
                value: user.nik.isNotEmpty ? user.nik : 'Belum diisi',
                isOptional: true,
              ),
              _divider(theme),
              _StaticField(
                icon: Icons.person_2_outlined,
                label: 'Username',
                value: user.username,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Saldo & Poin
  // ─────────────────────────────────────────────

  Widget _buildSaldoSection(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Keuangan',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _StaticField(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Saldo',
                value: formatter.format(user.saldoAsDouble),
              ),
              _divider(theme),
              _StaticField(
                icon: Icons.stars_rounded,
                label: 'Poin',
                value:
                    '${NumberFormat.decimalPattern('id_ID').format(user.poin)} poin',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Account Info
  // ─────────────────────────────────────────────

  Widget _buildAccountInfo(BuildContext context, dynamic user) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Info Akun',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _StaticField(
                icon: Icons.badge_outlined,
                label: 'Role',
                value: 'Nasabah',
              ),
              if (user.dateJoined != null) ...[
                _divider(theme),
                _StaticField(
                  icon: Icons.calendar_month_outlined,
                  label: 'Bergabung',
                  value: dateFormat.format(user.dateJoined!),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Logout Section
  // ─────────────────────────────────────────────

  Widget _buildLogoutSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Akun',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showLogoutConfirmation,
            icon: const Icon(
              Icons.logout_rounded,
              color: Color(0xFFDC2626),
            ),
            label: const Text(
              'Keluar',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFECACA)),
              backgroundColor: const Color(0xFFFEF2F2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showExitDialog(
      context,
      title: 'Konfirmasi Keluar',
      message: 'Apakah Anda yakin ingin keluar dari akun ${AppConstants.appName}?\n\n'
          'Anda dapat masuk kembali menggunakan username dan password.',
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.logout_rounded,
          color: Color(0xFFDC2626),
          size: 26,
        ),
      ),
    );

    if (confirmed && mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  static Widget _divider(ThemeData theme) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: theme.colorScheme.outlineVariant,
    );
  }
}

// ─────────────────────────────────────────────
// Static (Read-only) Field
// ─────────────────────────────────────────────

class _StaticField extends StatelessWidget {
  const _StaticField({
    required this.icon,
    required this.label,
    required this.value,
    this.isOptional = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isOptional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isOptional && value == 'Belum diisi'
                        ? theme.colorScheme.onSurfaceVariant
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
