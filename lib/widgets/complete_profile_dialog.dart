import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/user.dart';
import '../providers/home_provider.dart';
import '../providers/profile_provider.dart';

/// Dialog gaya mirip [showExitDialog]: arahkan user melengkapi alamat di profil.
///
/// Returns `true` jika user memilih "Lengkapi Profil", `false` jika dibatalkan.
Future<bool> showCompleteProfileDialog(BuildContext context) async {
  final theme = Theme.of(context);

  final goEdit = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: AppTheme.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Lengkapi Alamat Profil',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Anda perlu mengisi alamat di profil sebelum dapat mengajukan '
          'penjemputan, menarik saldo, atau menukar poin.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        actionsOverflowDirection: VerticalDirection.down,
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lengkapi Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Nanti',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );

  return goEdit ?? false;
}

User? _resolveUser(BuildContext context) {
  final home = context.read<HomeProvider>().user;
  final profile = context.read<ProfileProvider>().user;
  // Prefer sumber yang sudah punya alamat (Profile sering lebih mutakhir setelah edit).
  if (profile != null && profile.hasCompleteAddress) return profile;
  if (home != null && home.hasCompleteAddress) return home;
  return profile ?? home;
}

/// Memastikan alamat profil terisi sebelum fitur transaksi.
///
/// - Jika sudah lengkap → `true`
/// - Jika belum → tampilkan dialog; "Lengkapi Profil" membuka [EditProfileScreen]
/// - Jika user batal / masih belum lengkap setelah edit → `pop` route saat ini & `false`
Future<bool> guardTransactionRequiresAddress(BuildContext context) async {
  var user = _resolveUser(context);

  if (user == null) {
    final profile = context.read<ProfileProvider>();
    if (!profile.isLoading) {
      await profile.loadProfile();
    }
    if (!context.mounted) return false;
    user = _resolveUser(context);
  }

  if (user != null && user.hasCompleteAddress) {
    return true;
  }

  final goEdit = await showCompleteProfileDialog(context);
  if (!context.mounted) return false;

  if (!goEdit) {
    if (context.canPop()) context.pop();
    return false;
  }

  var editUser = user ?? _resolveUser(context);
  if (editUser == null) {
    await context.read<ProfileProvider>().loadProfile();
    if (!context.mounted) return false;
    editUser = _resolveUser(context);
  }

  if (editUser == null) {
    if (context.canPop()) context.pop();
    return false;
  }

  // Standalone GoRoute (bukan MaterialPageRoute) agar bottom nav tersembunyi.
  await context.push<void>('/profile/edit', extra: editUser);

  if (!context.mounted) return false;

  // Setelah edit, ProfileProvider biasanya paling mutakhir.
  final updated = context.read<ProfileProvider>().user ??
      context.read<HomeProvider>().user;
  if (updated != null && updated.hasCompleteAddress) {
    // Sinkronkan cache Home agar prefill / saldo tetap konsisten.
    await context.read<HomeProvider>().refresh();
    return true;
  }

  if (context.canPop()) context.pop();
  return false;
}
