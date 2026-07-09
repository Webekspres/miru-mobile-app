import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/exit_dialog.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _noHpController;
  late TextEditingController _alamatController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _noHpController = TextEditingController();
    _alamatController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final profile = context.read<ProfileProvider>();
    if (!profile.isLoading && profile.user == null) {
      profile.loadProfile();
    }
  }

  void _populateFields(ProfileProvider profile) {
    final user = profile.user;
    if (user == null) return;
    _namaController.text = user.namaLengkap;
    _noHpController.text = user.noHp;
    _alamatController.text = user.alamat;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = context.read<ProfileProvider>();
    final success = await profile.updateProfile(
      namaLengkap: _namaController.text.trim(),
      noHp: _noHpController.text.trim(),
      alamat: _alamatController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else if (profile.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profile.error!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Consumer<ProfileProvider>(
            builder: (context, profile, _) {
              if (profile.user == null) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  profile.isEditMode ? Icons.close_rounded : Icons.edit_outlined,
                ),
                tooltip: profile.isEditMode ? 'Batal' : 'Edit profil',
                onPressed: () {
                  if (profile.isEditMode) {
                    profile.disableEditMode();
                    _populateFields(profile);
                  } else {
                    profile.enableEditMode();
                    _populateFields(profile);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profile, _) {
          if (profile.isLoading && profile.user == null) {
            return const LoadingIndicator(message: 'Memuat profil...');
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

          if (!profile.isEditMode) {
            _populateFields(profile);
          }

          return RefreshIndicator(
            onRefresh: profile.loadProfile,
            color: AppTheme.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ── Avatar & Nama ──
                    _buildAvatarSection(context, user.namaLengkap),
                    const SizedBox(height: 24),
                    // ── Kartu Digital Link ──
                    _buildQRCard(context),
                    const SizedBox(height: 20),
                    // ── Informasi Profil ──
                    _buildInfoSection(context, profile, user),
                    const SizedBox(height: 24),
                    // ── Saldo & Poin ──
                    _buildSaldoSection(context, user),
                    const SizedBox(height: 24),
                    // ── Info Akun ──
                    _buildAccountInfo(context, user),
                    const SizedBox(height: 24),
                    // ── Logout Button ──
                    if (!profile.isEditMode) _buildLogoutSection(context),
                    const SizedBox(height: 16),

                    // ── Save Button (edit mode) ──
                    if (profile.isEditMode) _buildSaveButton(context, profile),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
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
  // Info Section (read-only or editable)
  // ─────────────────────────────────────────────

  Widget _buildInfoSection(
    BuildContext context,
    ProfileProvider profile,
    dynamic user,
  ) {
    final theme = Theme.of(context);
    final isEdit = profile.isEditMode;

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
              _InfoField(
                icon: Icons.person_outline,
                label: 'Nama Lengkap',
                value: user.namaLengkap,
                isEdit: isEdit,
                controller: _namaController,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              _divider(theme),
              _InfoField(
                icon: Icons.phone_outlined,
                label: 'No. Handphone',
                value: user.noHp,
                isEdit: isEdit,
                controller: _noHpController,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'No. HP tidak boleh kosong' : null,
              ),
              _divider(theme),
              _InfoField(
                icon: Icons.location_on_outlined,
                label: 'Alamat',
                value: user.alamat,
                isEdit: isEdit,
                controller: _alamatController,
                maxLines: 2,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              _divider(theme),
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
        if (isEdit)
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 4),
            child: Text(
              'Saldo, poin, dan role tidak dapat diubah.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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
  // Save Button
  // ─────────────────────────────────────────────

  Widget _buildSaveButton(BuildContext context, ProfileProvider profile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: profile.isSaving ? null : _saveProfile,
        child: profile.isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Simpan Perubahan'),
      ),
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
      message: 'Apakah Anda yakin ingin keluar dari akun MIRU?\n\n'
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
// Editable Field
// ─────────────────────────────────────────────

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.icon,
    required this.label,
    required this.value,
    required this.isEdit,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isEdit;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

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
            child: isEdit
                ? TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    validator: validator,
                    decoration: InputDecoration(
                      labelText: label,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                  )
                : Column(
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
