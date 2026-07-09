import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Shows a confirmation dialog with centered layout and stacked buttons.
///
/// - [title] — dialog title
/// - [message] — confirmation message
/// - [confirmLabel] — text for confirm button (default: "Ya, Keluar")
/// - [cancelLabel] — text for cancel button (default: "Batal")
/// - [icon] — optional icon widget shown above title
///
/// Returns `true` if user confirmed, `false` if cancelled.
Future<bool> showExitDialog(
  BuildContext context, {
  String title = 'Keluar Aplikasi',
  required String message,
  String confirmLabel = 'Ya, Keluar',
  String cancelLabel = 'Batal',
  Widget? icon,
}) async {
  final theme = Theme.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            icon ??
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.exit_to_app_rounded,
                    color: Color(0xFFDC2626),
                    size: 26,
                  ),
                ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          message,
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
              // Cancel button (primary — more prominent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text(
                    cancelLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Confirm button (secondary — less prominent)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    confirmLabel,
                    style: const TextStyle(
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

  return confirmed ?? false;
}
