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
          title: Text(
            'Konfirmasi Penukaran',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Anda akan menukar ${widget.reward.poinDibutuhkan} poin dengan '
            '${widget.reward.nama}. Poin dipotong setelah admin menyetujui. '
            'Diproses 1–2 hari kerja.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ya, Tukar'),
                  ),
                ),
              ],
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
      context.read<HomeProvider>().refresh();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tukar Poin')),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            color: Color(0xFFD97706),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.reward.nama,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
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
                                size: 16,
                                color: Color(0xFFD97706),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.reward.poinDibutuhkan} poin',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: const Color(0xFFD97706),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Stok tersedia: ${widget.reward.stok}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Setiap penukaran untuk 1 reward.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Poin dipotong setelah admin menyetujui. '
                    'Diproses 1–2 hari kerja. Reward diambil di kantor MIRU Bank Sampah.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _confirmRedemption,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        minimumSize: const Size.fromHeight(48),
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
                          : const Text('Tukar Poin'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
