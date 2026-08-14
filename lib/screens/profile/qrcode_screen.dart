import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/login_prompt.dart';
import '../../widgets/miru_logo.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final _cardKey = GlobalKey();
  bool _isSharing = false;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDataLoaded());
  }

  void _ensureDataLoaded() {
    if (!context.read<AuthSession>().isLoggedIn) return;
    final profile = context.read<ProfileProvider>();
    final seed = profile.user ?? context.read<HomeProvider>().user;
    if (seed != null) profile.hydrateFrom(seed);
    profile.ensureLoaded();
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
          content: Text(
            'Gagal membagikan gambar. Gunakan salin data QR sebagai alternatif.',
          ),
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
          message:
              'Masuk untuk melihat dan membagikan kartu digital ${AppConstants.appName} Anda.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Digital'),
      ),
      body: Consumer2<ProfileProvider, HomeProvider>(
        builder: (context, profile, home, _) {
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

          final qrPayload = jsonEncode({
            'id': user.id,
            'nama_lengkap': user.namaLengkap,
            'no_hp': user.noHp,
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                RepaintBoundary(
                  key: _cardKey,
                  child: ColoredBox(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        _buildQrBlock(context, qrPayload),
                        const SizedBox(height: 24),
                        _buildFlipCard(context, user),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildUsageInfo(context),
                const SizedBox(height: 24),
                _buildActionButtons(context, qrPayload),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrBlock(BuildContext context, String qrPayload) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: QrImageView(
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
      ),
    );
  }

  Widget _buildFlipCard(BuildContext context, User user) {
    return GestureDetector(
      onTap: () => setState(() => _showBack = !_showBack),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _showBack ? 1 : 0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
        builder: (context, value, _) {
          final angle = value * math.pi;
          final isBack = value > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _cardBack(context, user),
                  )
                : _cardFront(context, user),
          );
        },
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryDark,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      );

  Widget _cardFront(BuildContext context, User user) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MiruLogo(
            variant: MiruLogoVariant.fullWhite,
            height: 28,
          ),
          const Spacer(),
          Text(
            'Kartu Anggota',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  letterSpacing: 0.6,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            user.namaLengkap.isEmpty ? 'Nasabah MIRU' : user.namaLengkap,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.flip_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                'Ketuk untuk melihat data',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBack(BuildContext context, User user) {
    final theme = Theme.of(context);
    final joined = user.dateJoined == null
        ? '—'
        : DateFormat('d MMMM yyyy', 'id_ID').format(user.dateJoined!.toLocal());

    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: _cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data anggota',
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _backRow('Nama', user.namaLengkap),
                  _backRow('ID', '${user.id}'),
                  _backRow('RT/RW', _rtRw(user)),
                  _backRow(
                    'Alamat',
                    user.alamat.trim().isEmpty ? '—' : user.alamat.trim(),
                  ),
                  _backRow('Tanggal bergabung', joined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ketuk untuk membalik',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _rtRw(User user) {
    final rt = user.rt.trim();
    final rw = user.rw.trim();
    if (rt.isEmpty && rw.isEmpty) return '—';
    return 'RT ${rt.isEmpty ? '—' : rt} / RW ${rw.isEmpty ? '—' : rw}';
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
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tunjukkan kode ini kepada petugas saat setor sampah. '
              'Ketuk kartu di bawah kode untuk melihat data diri.',
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
