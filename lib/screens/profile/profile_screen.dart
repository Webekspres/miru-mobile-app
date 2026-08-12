import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/auth_session.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/exit_dialog.dart';
import '../../widgets/error_view.dart';
import '../../widgets/login_prompt.dart';
import '../../widgets/bottom_nav_scaffold.dart';
import '../../services/avatar_picker.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/user_avatar.dart';

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

  void _openEditProfile(ProfileProvider profile) {
    if (profile.user == null) return;
    context.push('/profile/edit', extra: profile.user!);
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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () => context.push('/settings'),
          ),
          Consumer<ProfileProvider>(
            builder: (context, profile, _) {
              if (profile.user == null) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit profil',
                onPressed: () => _openEditProfile(profile),
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
                  // Ringkas: foto + nama
                  _buildAvatarSection(context, profile, user),
                  const SizedBox(height: 24),
                  // Entry kartu digital
                  _buildQRCard(context),
                  const SizedBox(height: 20),
                  // Edit data lewat tile / ikon pencil AppBar
                  _buildEditProfileTile(context, profile),
                  const SizedBox(height: 20),
                  // Saldo & poin (berguna, di bawah)
                  _buildSaldoSection(context, user),
                  const SizedBox(height: 24),
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
          SizedBox(height: 20),
          SkeletonCard(height: 56),
          SizedBox(height: 20),
          SkeletonCard(height: 100),
        ],
      ),
    );
  }

  Future<void> _changeAvatar(BuildContext context, ProfileProvider profile) async {
    final file = await pickAndCropAvatar(context);
    if (file == null || !context.mounted) return;
    final ok = await profile.updateAvatar(file);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Foto profil berhasil diperbarui' : (profile.error ?? 'Gagal menyimpan foto')),
        backgroundColor: ok ? AppTheme.primaryColor : AppTheme.errorColor,
      ),
    );
  }

  Widget _buildAvatarSection(
    BuildContext context,
    ProfileProvider profile,
    User user,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: profile.isSaving ? null : () => _changeAvatar(context, profile),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              UserAvatar(
                name: user.namaLengkap,
                imageUrl: user.avatarUrl,
                radius: 40,
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.namaLengkap,
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

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

  Widget _buildEditProfileTile(
    BuildContext context,
    ProfileProvider profile,
  ) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openEditProfile(profile),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data diri',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Edit nama, nomor HP, alamat, dan lainnya',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              Divider(
                height: 1,
                thickness: 1,
                indent: 56,
                color: theme.colorScheme.outlineVariant,
              ),
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
}

class _StaticField extends StatelessWidget {
  const _StaticField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
