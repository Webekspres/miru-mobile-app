import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/poin_info.dart';
import '../../models/reward.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/reward_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/login_prompt.dart';
import '../../widgets/shimmer_loading.dart';

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
    reward.loadPoinInfo();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tukar Poin')),
        body: const LoginPrompt(
          title: 'Tukar Poin',
          message:
              'Masuk untuk menukarkan poin Anda dengan berbagai reward menarik.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tukar Poin')),
      body: Consumer2<HomeProvider, RewardProvider>(
        builder: (context, home, reward, _) {
          if (reward.hasError && reward.rewards.isEmpty) {
            return Column(
              children: [
                _PoinHeaderCard(poin: home.poin, theme: theme),
                Expanded(
                  child: ErrorView(
                    title: 'Gagal memuat data',
                    message: reward.error!,
                    onRetry: () => reward.loadRewards(),
                  ),
                ),
              ],
            );
          }

          final userPoin = home.poin;
          final loadingList = reward.isLoading && reward.rewards.isEmpty;

          return RefreshIndicator(
            onRefresh: reward.refresh,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Poin Header ──
                SliverToBoxAdapter(
                  child: _PoinHeaderCard(poin: userPoin, theme: theme),
                ),
                SliverToBoxAdapter(
                  child: _PoinExpiryInfo(info: reward.poinInfo, theme: theme),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                if (loadingList)
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _RewardSkeletonItem(),
                          _RewardSkeletonItem(),
                          _RewardSkeletonItem(),
                          _RewardSkeletonItem(),
                        ],
                      ),
                    ),
                  )
                else if (reward.rewards.isEmpty)
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    sliver: SliverList.separated(
                      itemCount: reward.rewards.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
          const SizedBox(width: 14),
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
                const SizedBox(height: 2),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Masa berlaku poin
// ─────────────────────────────────────────────

class _PoinExpiryInfo extends StatelessWidget {
  const _PoinExpiryInfo({required this.info, required this.theme});

  final PoinInfo? info;
  final ThemeData theme;

  /// Tanggal kedaluwarsa dalam kalender WIT (UTC+9).
  static String _formatWit(DateTime utc) => DateFormat(
    'd MMMM yyyy',
    'id_ID',
  ).format(utc.toUtc().add(const Duration(hours: 9)));

  @override
  Widget build(BuildContext context) {
    final info = this.info;
    final expiring = info != null && info.hasExpiringPoin;
    final color = expiring
        ? const Color(0xFFB45309)
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: expiring
            ? const Color(0xFFFEF3C7)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            expiring ? Icons.schedule_rounded : Icons.info_outline_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expiring) ...[
                  Text(
                    '${info.poinHangusTerdekat} poin akan hangus pada '
                    '${_formatWit(info.tanggalKedaluwarsaTerdekat!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  info?.catatan ?? PoinInfo.defaultCatatan,
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
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
// Reward Card
// ─────────────────────────────────────────────

class _RewardSkeletonItem extends StatelessWidget {
  const _RewardSkeletonItem();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: SkeletonCard(height: 120),
    );
  }
}

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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
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
                      color: canRedeem ? const Color(0xFFD97706) : Colors.grey,
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canRedeem ? onTukar : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade200,
                disabledForegroundColor: Colors.grey.shade500,
                minimumSize: const Size.fromHeight(40),
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
