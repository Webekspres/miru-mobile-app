import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/theme.dart';

Future<void> showWelcomeBackModal(
  BuildContext context, {
  String? namaLengkap,
}) {
  final name = namaLengkap?.trim();
  final title = (name == null || name.isEmpty)
      ? 'Selamat datang kembali'
      : 'Selamat datang kembali, $name';

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF14532D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Senang melihat Anda lagi di ${AppConstants.appName}. Lanjut kelola sampah dan kumpulkan saldo.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset(
                    'assets/images/welcome_back.png',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Lanjutkan',
                  style: TextStyle(color: AppTheme.primaryDark),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
