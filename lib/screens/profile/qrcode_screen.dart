import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/login_prompt.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final _cardKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDataLoaded());
  }

  void _ensureDataLoaded() {
    final profile = context.read<ProfileProvider>();
    final home = context.read<HomeProvider>();
    if (profile.user == null && home.user == null) {
      profile.loadProfile();
    }
  }

  Future<void> _shareQR() async {
    setState(() => _isSharing = true);

    try {
      final boundary = _cardKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to capture image');

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/miru_qr_card.png');
      await file.writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Kartu Digital MIRU Bank Sampah',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membagikan gambar. Gunakan salin data QR sebagai alternatif.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kartu Digital')),
        body: const LoginPrompt(
          title: 'Kartu Digital',
          message: 'Masuk untuk melihat dan membagikan kartu digital MIRU Anda.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Digital'),
      ),
      body: Consumer2<ProfileProvider, HomeProvider>(
        builder: (context, profile, home, _) {
          // Use profile provider if available, fallback to home provider
          final user = profile.user ?? home.user;

          if ((profile.isLoading || home.isLoading) && user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profile.hasError && user == null) {
            return ErrorView(
              title: 'Gagal memuat data',
              message: profile.error!,
              onRetry: () => profile.loadProfile(),
            );
          }

          if (user == null) {
            return ErrorView(
              title: 'Data tidak tersedia',
              message: 'Silakan buka halaman Beranda terlebih dahulu.',
              onRetry: () => profile.loadProfile(),
            );
          }

          // Build QR payload: { id, nama_lengkap, no_hp }
          final qrPayload = jsonEncode({
            'id': user.id,
            'nama_lengkap': user.namaLengkap,
            'no_hp': user.noHp,
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // ── Kartu Digital Card (wrapped for screenshot) ──
                RepaintBoundary(
                  key: _cardKey,
                  child: _buildDigitalCard(context, user, qrPayload),
                ),
                const SizedBox(height: 32),
                // ── Info Penggunaan ──
                _buildUsageInfo(context),
                const SizedBox(height: 24),
                // ── Tombol Aksi ──
                _buildActionButtons(context, qrPayload),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDigitalCard(
    BuildContext context,
    dynamic user,
    String qrPayload,
  ) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'MIRU Bank Sampah',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── QR Code ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            child: QrImageView(
              data: qrPayload,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF16A34A),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── User Info ──
          Text(
            user.namaLengkap,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.noHp.isNotEmpty ? user.noHp : '(belum ada no. HP)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // ── Saldo ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Saldo: ${formatter.format(user.saldoAsDouble)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── ID ──
          Text(
            'ID: ${user.id}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tunjukkan QR code ini kepada petugas saat melakukan '
              'setoran sampah. QR code berisi data diri Anda untuk '
              'mempermudah pencatatan transaksi.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF1E40AF),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String qrPayload) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // ── Bagikan Kartu Digital ──
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSharing ? null : _shareQR,
            icon: _isSharing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.share_rounded, size: 18),
            label: Text(_isSharing ? 'Membagikan...' : 'Bagikan Kartu Digital'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ── Salin Data QR ──
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: qrPayload));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data QR berhasil disalin'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Salin Data QR'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              side: BorderSide(color: theme.colorScheme.outlineVariant),
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
}
