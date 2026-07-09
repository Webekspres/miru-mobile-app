import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/reward.dart';
import '../../providers/home_provider.dart';
import '../../providers/reward_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final reward = context.read<RewardProvider>();
    if (reward.rewards.isEmpty && !reward.isLoading) {
      reward.loadRewards();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tukar Poin'),
      ),
      body: Consumer2<HomeProvider, RewardProvider>(
        builder: (context, home, reward, _) {
          if (reward.isLoading && reward.rewards.isEmpty) {
            return const LoadingIndicator(message: 'Memuat katalog reward...');
          }

          if (reward.hasError && reward.rewards.isEmpty) {
            return ErrorView(
              title: 'Gagal memuat data',
              message: reward.error!,
              onRetry: () => reward.loadRewards(),
            );
          }

          final userPoin = home.poin;

          return RefreshIndicator(
            onRefresh: reward.refresh,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Poin Header ──
                SliverToBoxAdapter(
                  child: _PoinHeaderCard(
                    poin: userPoin,
                    theme: theme,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // ── Reward List ──
                if (reward.rewards.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.card_giftcard_outlined,
                      title: 'Belum ada reward',
                      description: 'Reward akan tersedia segera.',
                      expand: false,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: reward.rewards.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = reward.rewards[index];
                        return _RewardCard(
                          reward: item,
                          userPoin: userPoin,
                          theme: theme,
                          onTukar: () => _onTukarTap(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onTukarTap(Reward reward) {
    context.push('/home/reward/tukar', extra: reward);
  }
}

// ─────────────────────────────────────────────
// Poin Header Card
// ─────────────────────────────────────────────

class _PoinHeaderCard extends StatelessWidget {
  const _PoinHeaderCard({required this.poin, required this.theme});

  final int poin;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.stars_rounded,
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
                  'Poin Anda',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$poin poin',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Info: 1 poin = Rp1.000
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '1 poin = Rp1.000',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reward Card
// ─────────────────────────────────────────────

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.userPoin,
    required this.theme,
    required this.onTukar,
  });

  final Reward reward;
  final int userPoin;
  final ThemeData theme;
  final VoidCallback onTukar;

  @override
  Widget build(BuildContext context) {
    final canRedeem = userPoin >= reward.poinDibutuhkan && reward.stok > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: Icon + Nama ──
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.nama,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stok: ${reward.stok}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: reward.stok > 0
                            ? theme.colorScheme.onSurfaceVariant
                            : const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Poin dibutuhkan ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: canRedeem
                      ? const Color(0xFFFEF3C7)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 14,
                      color: canRedeem
                          ? const Color(0xFFD97706)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.poinDibutuhkan}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: canRedeem
                            ? const Color(0xFFD97706)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Tukar Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canRedeem ? onTukar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade500,
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                canRedeem
                    ? 'Tukar'
                    : userPoin < reward.poinDibutuhkan
                        ? 'Poin tidak cukup'
                        : 'Stok habis',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
