import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/pickup.dart';
import '../../providers/home_provider.dart';
import '../../providers/penjemputan_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_badge.dart';

class PenjemputanScreen extends StatefulWidget {
  const PenjemputanScreen({super.key});

  @override
  State<PenjemputanScreen> createState() => _PenjemputanScreenState();
}

class _PenjemputanScreenState extends State<PenjemputanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final penjemputan = context.read<PenjemputanProvider>();
    final home = context.read<HomeProvider>();
    final userId = home.user?.id;
    if (userId != null && penjemputan.pickups.isEmpty && !penjemputan.isLoading) {
      penjemputan.loadPickups(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjemputan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Riwayat'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/home/penjemputan/ajukan'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajukan'),
      ),
      body: Consumer<PenjemputanProvider>(
        builder: (context, penjemputan, _) {
          if (penjemputan.isLoading && penjemputan.pickups.isEmpty) {
            return const LoadingIndicator(message: 'Memuat data penjemputan...');
          }

          if (penjemputan.hasError && penjemputan.pickups.isEmpty) {
            return ErrorView(
              title: 'Gagal memuat data',
              message: penjemputan.error!,
              onRetry: () => _loadData(),
            );
          }

          return RefreshIndicator(
            onRefresh: penjemputan.refresh,
            color: AppTheme.primaryColor,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(
                  context,
                  pickups: penjemputan.activePickups,
                  isEmptyMessage: 'Tidak ada penjemputan aktif',
                  isEmptyDetail: 'Ajukan penjemputan sampah dengan menekan tombol +',
                ),
                _buildTabContent(
                  context,
                  pickups: penjemputan.historyPickups,
                  isEmptyMessage: 'Belum ada riwayat penjemputan',
                  isEmptyDetail: 'Riwayat penjemputan akan muncul di sini.',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context, {
    required List<Pickup> pickups,
    required String isEmptyMessage,
    required String isEmptyDetail,
  }) {
    if (pickups.isEmpty) {
      return ListView(
        // Enable pull-to-refresh even when empty
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: EmptyState(
              icon: Icons.local_shipping_outlined,
              title: isEmptyMessage,
              description: isEmptyDetail,
              expand: false,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: pickups.length,
      itemBuilder: (context, index) => _PickupCard(pickup: pickups[index]),
    );
  }
}

// ─────────────────────────────────────────────
// Pickup Card
// ─────────────────────────────────────────────

class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.pickup});

  final Pickup pickup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');
    final weightFormat = NumberFormat.decimalPattern('id_ID');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Status + Berat ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge.pickup(status: pickup.status),
              Text(
                '${weightFormat.format(pickup.estimasiBeratAsDouble)} kg',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Alamat ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  pickup.alamatJemput,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Jadwal ──
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(pickup.jadwal),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
