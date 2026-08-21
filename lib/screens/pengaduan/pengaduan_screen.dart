import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/complaint.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/pengaduan_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/login_prompt.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/status_badge.dart';

class PengaduanScreen extends StatefulWidget {
  const PengaduanScreen({super.key});

  @override
  State<PengaduanScreen> createState() => _PengaduanScreenState();
}

class _PengaduanScreenState extends State<PengaduanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _loadedUserId;

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
    final pengaduan = context.read<PengaduanProvider>();
    final home = context.read<HomeProvider>();
    final userId = home.user?.id;
    if (userId != null &&
        pengaduan.complaints.isEmpty &&
        !pengaduan.isLoading) {
      _loadedUserId = userId;
      pengaduan.loadComplaints(userId: userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pengaduan')),
        body: const LoginPrompt(
          title: 'Pengaduan',
          message: 'Masuk untuk melihat dan mengajukan pengaduan Anda.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaduan'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Terbuka'),
            Tab(text: 'Selesai'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/home/pengaduan/form'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Pengaduan'),
      ),
      body: Consumer<PengaduanProvider>(
        builder: (context, pengaduan, _) {
          if (pengaduan.isLoading) {
            return const SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, 16, 0, 24),
              child: ListSkeleton(itemCount: 4),
            );
          }

          if (pengaduan.hasError && pengaduan.complaints.isEmpty) {
            return ErrorView(
              title: 'Gagal memuat data',
              message: pengaduan.error!,
              onRetry: () => _loadData(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              if (_loadedUserId != null) {
                await pengaduan.refreshForUser(userId: _loadedUserId!);
              }
            },
            color: AppTheme.primaryColor,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTabContent(
                  context,
                  complaints: pengaduan.openComplaints,
                  isEmptyMessage: 'Tidak ada pengaduan terbuka',
                  isEmptyDetail:
                      'Pengaduan yang sedang diproses akan muncul di sini.',
                ),
                _buildTabContent(
                  context,
                  complaints: pengaduan.closedComplaints,
                  isEmptyMessage: 'Belum ada pengaduan selesai',
                  isEmptyDetail:
                      'Pengaduan yang sudah ditindaklanjuti akan muncul di sini.',
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
    required List<Complaint> complaints,
    required String isEmptyMessage,
    required String isEmptyDetail,
  }) {
    if (complaints.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: EmptyState(
              icon: Icons.report_outlined,
              title: isEmptyMessage,
              description: isEmptyDetail,
              expand: false,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: complaints.length,
      itemBuilder: (context, index) => _ComplaintCard(
        complaint: complaints[index],
        onTap: () => _showDetailSheet(context, complaints[index]),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, Complaint complaint) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm', 'id_ID');

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

              // Header: Status + Jenis
              Row(
                children: [
                  StatusBadge.complaint(status: complaint.status),
                  const Spacer(),
                  Text(
                    '#${complaint.id}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Jenis pengaduan
              Text(
                complaint.jenisPengaduan.displayLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),

              // Tanggal
              Text(
                '${dateFormat.format(complaint.tanggal)} ${timeFormat.format(complaint.tanggal)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Keluhan
              Text(
                'Keluhan',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                complaint.keluhan,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),

              // Tindak lanjut (if any)
              if (complaint.tindakLanjut.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.reply_rounded,
                            size: 16,
                            color: Color(0xFF166534),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tindak Lanjut Admin',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        complaint.tindakLanjut,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF166534),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

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
}

// ─────────────────────────────────────────────
// Complaint Card
// ─────────────────────────────────────────────

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.complaint, required this.onTap});

  final Complaint complaint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy', 'id_ID');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Status + Nomor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge.complaint(status: complaint.status),
                    Text(
                      '#${complaint.id}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Jenis
                Row(
                  children: [
                    Icon(
                      Icons.report_problem_outlined,
                      size: 16,
                      color: complaint.status == ComplaintStatus.terbuka
                          ? const Color(0xFFEAB308)
                          : const Color(0xFF22C55E),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        complaint.jenisPengaduan.displayLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Keluhan preview (max 2 lines)
                Text(
                  complaint.keluhan,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Footer: Tanggal + arrow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(complaint.tanggal),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
