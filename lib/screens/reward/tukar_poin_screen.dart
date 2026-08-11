import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/reward.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/reward_provider.dart';
import '../../widgets/complete_profile_dialog.dart';
import '../../widgets/login_prompt.dart';

class TukarPoinScreen extends StatelessWidget {
  const TukarPoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reward = GoRouterState.of(context).extra as Reward?;
    if (reward == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tukar Poin')),
        body: const Center(child: Text('Data reward tidak ditemukan')),
      );
    }

    return _TukarPoinContent(reward: reward);
  }
}

class _TukarPoinContent extends StatefulWidget {
  const _TukarPoinContent({required this.reward});

  final Reward reward;

  @override
  State<_TukarPoinContent> createState() => _TukarPoinContentState();
}

class _TukarPoinContentState extends State<_TukarPoinContent> {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tukar Poin')),
        body: const LoginPrompt(
          title: 'Tukar Poin',
          message: 'Masuk untuk menukarkan poin Anda.',
        ),
      );
    }

    return _TukarPoinBody(reward: widget.reward);
  }
}

class _TukarPoinBody extends StatefulWidget {
  const _TukarPoinBody({required this.reward});

  final Reward reward;

  @override
  State<_TukarPoinBody> createState() => _TukarPoinBodyState();
}

class _TukarPoinBodyState extends State<_TukarPoinBody> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      guardTransactionRequiresAddress(context);
    });
  }

  Future<void> _confirmRedemption() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Konfirmasi Penukaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _detailRow(theme, 'Reward', widget.reward.nama),
              const SizedBox(height: 10),
              _detailRow(
                theme,
                'Poin',
                '${widget.reward.poinDibutuhkan} poin',
                valueColor: const Color(0xFFD97706),
              ),
              const SizedBox(height: 10),
              _detailRow(
                theme,
                'Stok tersisa',
                '${widget.reward.stok}',
              ),
              const SizedBox(height: 16),
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Poin akan dipotong setelah admin menyetujui penukaran. '
                        'Penukaran dapat diproses dalam 1-2 hari kerja.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ya, Tukar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _submitRedemption();
    }
  }

  Future<void> _submitRedemption() async {
    setState(() => _isProcessing = true);

    final rewardProv = context.read<RewardProvider>();
    final result = await rewardProv.createRedemption(
      rewardId: widget.reward.id,
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (result != null) {
      // Refresh HomeProvider to update poin balance
      if (mounted) {
        context.read<HomeProvider>().refresh();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penukaran berhasil diajukan'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      context.pop();
    } else if (rewardProv.hasSubmitError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(rewardProv.submitError!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Widget _detailRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tukar Poin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Reward Detail Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  // Reward icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.card_giftcard_rounded,
                      color: Color(0xFFD97706),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama reward
                  Text(
                    widget.reward.nama,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Poin dibutuhkan
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          size: 18,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${widget.reward.poinDibutuhkan} poin',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFD97706),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stok info
                  Text(
                    'Stok tersedia: ${widget.reward.stok}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Info SLA ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Color(0xFF0369A1),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Informasi Penukaran',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _infoBullet(theme, 'Penukaran diproses dalam 1-2 hari kerja'),
                  const SizedBox(height: 6),
                  _infoBullet(
                    theme,
                    'Poin akan dipotong setelah disetujui admin',
                  ),
                  const SizedBox(height: 6),
                  _infoBullet(
                    theme,
                    'Reward dapat diambil di kantor MIRU Bank Sampah',
                  ),
                  const SizedBox(height: 6),
                  _infoBullet(
                    theme,
                    'Poin tidak dapat diuangkan',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Tukar Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _confirmRedemption,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Tukar Poin',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoBullet(ThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(Icons.circle, size: 5, color: Color(0xFF0369A1)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF0C4A6E),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
