import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screen_brightness/screen_brightness.dart';

import '../config/theme.dart';
import '../models/user.dart';
import '../providers/home_provider.dart';
import '../providers/profile_provider.dart';

/// Compact white QR button for the right of the home saldo/poin header.
/// Parent wires this into [HomeScreen]; do not import from here into routes.
class HomeQrButton extends StatelessWidget {
  const HomeQrButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Kartu digital',
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryColor,
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(Icons.qr_code_2_rounded, size: 22),
      onPressed: () => _openQrModal(context),
    );
  }

  void _openQrModal(BuildContext context) {
    final user = context.read<HomeProvider>().user ??
        context.read<ProfileProvider>().user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kartu belum siap. Coba buka ulang beranda.'),
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _HomeQrDialog(user: user),
    );
  }
}

class _HomeQrDialog extends StatefulWidget {
  const _HomeQrDialog({required this.user});

  final User user;

  @override
  State<_HomeQrDialog> createState() => _HomeQrDialogState();
}

class _HomeQrDialogState extends State<_HomeQrDialog> {
  bool _alive = true;

  @override
  void initState() {
    super.initState();
    _setMaxBrightness();
  }

  @override
  void dispose() {
    _alive = false;
    _restoreBrightness();
    super.dispose();
  }

  Future<void> _setMaxBrightness() async {
    try {
      await ScreenBrightness.instance.setApplicationScreenBrightness(1);
      if (!_alive) {
        await ScreenBrightness.instance.resetApplicationScreenBrightness();
      }
    } catch (_) {}
  }

  Future<void> _restoreBrightness() async {
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final qrPayload = jsonEncode({
      'id': user.id,
      'nama_lengkap': user.namaLengkap,
      'no_hp': user.noHp,
    });

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Kartu Digital',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            QrImageView(
              data: qrPayload,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF16A34A),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF16A34A),
              ),
              embeddedImage: const AssetImage('assets/images/logo.png'),
              embeddedImageStyle: const QrEmbeddedImageStyle(
                size: Size(44, 44),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.namaLengkap,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tunjukkan kepada petugas saat setor',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
