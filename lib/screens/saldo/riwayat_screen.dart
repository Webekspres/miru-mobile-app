import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/activity_item.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/saldo_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/login_prompt.dart';
import '../../widgets/shimmer_loading.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    _FilterTab(label: 'Semua', filter: null),
    _FilterTab(label: 'Setoran', filter: 'setoran'),
    _FilterTab(label: 'Penarikan', filter: 'penarikan'),
    _FilterTab(label: 'Poin', filter: 'poin'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = _tabs[_tabController.index].filter;
      context.read<SaldoProvider>().setFilter(filter);
    }
  }

  void _loadData() {
    final saldo = context.read<SaldoProvider>();
    final home = context.read<HomeProvider>();
    final userId = home.user?.id;
    if (userId != null && !saldo.isLoading) {
      saldo.loadActivity(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat')),
        body: const LoginPrompt(
          title: 'Riwayat Transaksi',
          message: 'Masuk untuk melihat riwayat setoran, penarikan, dan penukaran poin Anda.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: Consumer<SaldoProvider>(
        builder: (context, saldo, _) {
          if (saldo.isLoading) {
            return const SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, 60, 0, 24),
              child: ListSkeleton(itemCount: 6),
            );
          }

          if (saldo.hasError && saldo.items.isEmpty) {
            return ErrorView(
              title: 'Gagal memuat riwayat',
              message: saldo.error!,
              onRetry: () => _loadData(),
            );
          }

          if (saldo.items.isEmpty) {
            final emptyTheme = Theme.of(context);
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 36,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Belum ada transaksi',
                        style: emptyTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Setoran, penarikan, dan penukaran poin akan muncul di sini.',
                        style: emptyTheme.textTheme.bodyMedium?.copyWith(
                          color: emptyTheme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: saldo.refresh,
            color: AppTheme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: saldo.filteredItems.length,
              itemBuilder: (context, index) {
                final item = saldo.filteredItems[index];
                return _ActivityCard(
                  item: item,
                  onTap: () => _showDetailSheet(context, item),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDetailSheet(BuildContext context, ActivityItem item) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final (icon, color, bgColor) = switch (item.type) {
      ActivityType.setoran => (
        Icons.add_shopping_cart_outlined,
        AppTheme.primaryColor,
        const Color(0xFFDCFCE7),
      ),
      ActivityType.penarikan => (
        Icons.account_balance_outlined,
        const Color(0xFF2563EB),
        const Color(0xFFDBEAFE),
      ),
      ActivityType.penukaranPoin => (
        Icons.card_giftcard_outlined,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
      ),
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 24, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type.displayLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dateFormat.format(item.tanggal)} ${timeFormat.format(item.tanggal)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Nominal / Poin
              if (item.nominalAsDouble != null || item.poin != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: item.nominalAsDouble != null
                      ? Row(
                          children: [
                            Icon(
                              item.isCredit
                                  ? Icons.add_circle_outline
                                  : Icons.remove_circle_outline,
                              size: 20,
                              color: color,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${item.isCredit ? '+' : '-'}${formatter.format(item.nominalAsDouble)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              size: 20,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${item.poin} poin',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
              ],

              // Keterangan
              if (item.keterangan.isNotEmpty) ...[
                Text(
                  'Keterangan',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.keterangan,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],

              // Status
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Status: ${_statusLabel(item.status)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tutup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'menunggu' => 'Menunggu',
      'selesai' => 'Selesai',
      'ditolak' => 'Ditolak',
      _ => status,
    };
  }
}

// ─────────────────────────────────────────────
// Filter Tab Data
// ─────────────────────────────────────────────

class _FilterTab {
  const _FilterTab({required this.label, required this.filter});

  final String label;
  final String? filter;
}

// ─────────────────────────────────────────────
// Activity Card
// ─────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.item, required this.onTap});

  final ActivityItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM', 'id_ID');
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    final (icon, color, bgColor) = switch (item.type) {
      ActivityType.setoran => (
        Icons.add_shopping_cart_outlined,
        AppTheme.primaryColor,
        AppTheme.primaryColor.withValues(alpha: 0.1),
      ),
      ActivityType.penarikan => (
        Icons.account_balance_outlined,
        const Color(0xFF2563EB),
        const Color(0xFF2563EB).withValues(alpha: 0.1),
      ),
      ActivityType.penukaranPoin => (
        Icons.card_giftcard_outlined,
        const Color(0xFFD97706),
        const Color(0xFFD97706).withValues(alpha: 0.1),
      ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type.displayLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateFormat.format(item.tanggal),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.nominalAsDouble != null)
                  Text(
                    '${item.isCredit ? '+' : '-'}${formatter.format(item.nominalAsDouble)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: item.isCredit
                          ? AppTheme.primaryColor
                          : const Color(0xFFDC2626),
                    ),
                  )
                else if (item.poin != null)
                  Text(
                    '${item.poin} poin',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
