import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/deposit.dart';
import '../../models/waste_category.dart';
import '../../providers/home_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/saldo_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final homeProvider = context.read<HomeProvider>();
    if (!homeProvider.isLoading && homeProvider.user == null) {
      homeProvider.loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (context, home, _) {
          if (home.isLoading && home.user == null) {
            return const LoadingIndicator(message: 'Memuat data...');
          }

          if (home.hasError && home.user == null) {
            return ErrorView(
              title: 'Gagal memuat data',
              message: home.error!,
              onRetry: () => home.loadData(),
            );
          }

          return RefreshIndicator(
            onRefresh: home.refresh,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildAppBar(context, home),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      // ── Saldo Card ──
                      _buildSaldoSection(context, home),
                      const SizedBox(height: 20),
                      // ── Service Hours Banner ──
                      _buildServiceHoursBanner(context),
                      const SizedBox(height: 20),
                      // ── Quick Actions ──
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      // ── Info Harga Sampah ──
                      _buildPriceInfoSection(context, home),
                      const SizedBox(height: 24),
                      // ── Aktivitas Terbaru ──
                      _buildRecentActivity(context, home),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────

  Widget _buildAppBar(
    BuildContext context,
    HomeProvider home,
  ) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      title: Text(
        AppConstants.appName,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      centerTitle: false,
      actions: [
        // Notification / placeholder
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Pengumuman',
          onPressed: () {
            // Navigate to pengumuman (Fase 5)
          },
        ),
        // Profile icon
        CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          child: Text(
            (home.namaLengkap.isNotEmpty
                    ? home.namaLengkap[0]
                    : 'U')
                .toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Saldo Section
  // ─────────────────────────────────────────────

  Widget _buildSaldoSection(BuildContext context, HomeProvider home) {
    return SaldoCard(
      saldo: home.saldo,
      poin: home.poin,
      isLoading: false,
    );
  }

  // ─────────────────────────────────────────────
  // Service Hours Banner
  // ─────────────────────────────────────────────

  Widget _buildServiceHoursBanner(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dayOfWeek = now.weekday; // 1=Monday ... 7=Sunday
    final hour = now.hour;
    final minute = now.minute;
    final currentMinutes = hour * 60 + minute;

    // Operating hours: Monday-Saturday 08:00-17:00 WIT
    const openMinutes = 8 * 60; // 08:00
    const closeMinutes = 17 * 60; // 17:00

    final bool isSunday = dayOfWeek == DateTime.sunday;
    final bool isOpen = !isSunday &&
        currentMinutes >= openMinutes &&
        currentMinutes < closeMinutes;

    final String message;
    final IconData icon;
    final Color bgColor;
    final Color textColor;

    if (isOpen) {
      message = 'Sedang buka — Sen–Sab 08.00–17.00 WIT';
      icon = Icons.access_time_rounded;
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF166534);
    } else if (isSunday) {
      message = 'Hari Minggu libur — Sen–Sab 08.00–17.00 WIT';
      icon = Icons.event_busy_rounded;
      bgColor = const Color(0xFFFEF2F2);
      textColor = const Color(0xFF991B1B);
    } else {
      message = 'Di luar jam layanan — Sen–Sab 08.00–17.00 WIT';
      icon = Icons.nightlight_round;
      bgColor = const Color(0xFFF3F4F6);
      textColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Quick Actions
  // ─────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.local_shipping_outlined,
        label: 'Jemput\nSampah',
        color: const Color(0xFF16A34A),
        bgColor: const Color(0xFFDCFCE7),
        route: '/home/penjemputan',
      ),
      _QuickAction(
        icon: Icons.account_balance_outlined,
        label: 'Tarik\nSaldo',
        color: const Color(0xFF2563EB),
        bgColor: const Color(0xFFDBEAFE),
        route: '/home/tarik-saldo',
      ),
      _QuickAction(
        icon: Icons.card_giftcard_outlined,
        label: 'Tukar\nPoin',
        color: const Color(0xFFD97706),
        bgColor: const Color(0xFFFEF3C7),
        route: '/home/reward',
      ),
      _QuickAction(
        icon: Icons.recycling_outlined,
        label: 'Info\nSampah',
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFEDE9FE),
        route: '/home/info-sampah',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Layanan Cepat',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push(action.route),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: action.bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          action.icon,
                          color: action.color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.label,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  height: 1.3,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Price Info Section
  // ─────────────────────────────────────────────

  Widget _buildPriceInfoSection(BuildContext context, HomeProvider home) {
    final theme = Theme.of(context);
    final categories = home.topCategories;

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Info Harga Sampah',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/home/info-sampah'),
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('Lihat semua'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...categories.map(
          (cat) => _PriceInfoItem(category: cat),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Recent Activity
  // ─────────────────────────────────────────────

  Widget _buildRecentActivity(BuildContext context, HomeProvider home) {
    final theme = Theme.of(context);
    final deposits = home.recentDeposits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push('/riwayat'),
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('Semua'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (deposits.isEmpty)
          _buildEmptyActivity()
        else
          ...deposits.map((deposit) => _ActivityItemWidget(deposit: deposit)),
        const SizedBox(height: 8),
        // Quick navigate buttons row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/home/penjemputan'),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: const Text('Jemput'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push('/home/pengaduan'),
                icon: const Icon(Icons.report_outlined, size: 18),
                label: const Text('Pengaduan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyActivity() {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum ada aktivitas',
        description: 'Setelah Anda melakukan setoran, riwayat akan muncul di sini.',
        expand: false,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Quick Action Data
// ─────────────────────────────────────────────

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.route,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final String route;
}

// ─────────────────────────────────────────────
// Price Info Item
// ─────────────────────────────────────────────

class _PriceInfoItem extends StatelessWidget {
  const _PriceInfoItem({required this.category});

  final WasteCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco_outlined, size: 18, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.nama,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${formatter.format(category.hargaBeliPerKgAsDouble)}/kg',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Activity Item
// ─────────────────────────────────────────────

class _ActivityItemWidget extends StatelessWidget {
  const _ActivityItemWidget({required this.deposit});

  final Deposit deposit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    final dateStr = DateFormat('d MMM', 'id_ID').format(deposit.tanggal);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_shopping_cart_outlined,
              size: 18,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setoran Sampah',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${formatter.format(deposit.totalNilaiAsDouble)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
