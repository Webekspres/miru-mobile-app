import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../models/deposit.dart';
import '../../models/waste_category.dart';
import '../../providers/auth_session.dart';
import '../../providers/home_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/pengumuman_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/miru_logo.dart';
import '../../widgets/error_view.dart';
import '../../widgets/saldo_card.dart';
import '../../widgets/shimmer_loading.dart';
import '../notifikasi/detail_notifikasi_screen.dart';

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
    final isLoggedIn = context.read<AuthSession>().isLoggedIn;
    if (!isLoggedIn) return;
    final homeProvider = context.read<HomeProvider>();
    if (!homeProvider.isLoading && homeProvider.user == null) {
      homeProvider.loadData();
    }
    // Load announcements for banners
    final pengumuman = context.read<PengumumanProvider>();
    if (pengumuman.announcements.isEmpty && !pengumuman.isLoading) {
      pengumuman.loadPengumuman();
    }
    // Load notifications
    final notif = context.read<NotificationProvider>();
    if (notif.notifications.isEmpty && !notif.isLoading) {
      notif.loadNotifications();
    }
  }

  /// Public home screen shown when user is not logged in.
  Widget _buildPublicHome() {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            titleSpacing: 16,
            title: Text(
              AppConstants.appName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: false,
            actions: [
              _buildNotifBell(context),
              const SizedBox(width: 4),
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.outlineVariant,
                child: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Login Prompt Card
                _buildLoginPromptCard(context),
                const SizedBox(height: 20),

                // Service Hours (public)
                _buildServiceHoursBanner(context),
                const SizedBox(height: 20),

                // Quick Actions (public — each will show login prompt)
                _buildQuickActions(context),
                const SizedBox(height: 24),

                // Price Info (public data)
                _buildPublicPriceInfo(context),
                const SizedBox(height: 24),

                // Info Links
                _buildPublicLinks(context),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPromptCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            const Color(0xFF15803D),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MiruLogo(
                variant: MiruLogoVariant.icon,
                height: 48,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MIRU Bank Sampah',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    'Saldo Anda',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Rp *** ***',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Masuk untuk melihat saldo Anda',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                minimumSize: const Size.fromHeight(42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Masuk / Daftar',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublicPriceInfo(BuildContext context) {
    final theme = Theme.of(context);

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
              label: const Text('Lihat detail'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ketahui harga sampah terkini',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF166534),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap untuk melihat daftar harga',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF166534).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: const Color(0xFF166534).withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPublicLinks(BuildContext context) {
    final theme = Theme.of(context);

    final links = [
      _PublicLink(
        icon: Icons.info_outline_rounded,
        label: 'Info Sampah',
        subtitle: 'Jenis, harga, dan panduan pemilahan',
        color: const Color(0xFF7C3AED),
        bgColor: const Color(0xFFEDE9FE),
        route: '/home/info-sampah',
      ),
      _PublicLink(
        icon: Icons.description_outlined,
        label: 'Kebijakan Data',
        subtitle: 'Kebijakan privasi dan data',
        color: const Color(0xFF6B7280),
        bgColor: const Color(0xFFF3F4F6),
        route: '/settings/kebijakan-data',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.push(link.route),
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: link.bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(link.icon, size: 22, color: link.color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                link.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                link.subtitle,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Notification Bell with Unread Badge & Popup
  // ─────────────────────────────────────────────

  Widget _buildNotifBell(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notif, _) {
        final unread = notif.unreadCount;
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifikasi',
              onPressed: () => _showNotifPopup(context, notif),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unread > 99 ? '99+' : unread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotifPopup(
      BuildContext context, NotificationProvider notif) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM HH:mm', 'id_ID');
    final latest = notif.latestNotifications;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
              const SizedBox(height: 16),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifikasi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (notif.unreadCount > 0)
                    TextButton(
                      onPressed: () {
                        notif.markAllAsRead();
                        Navigator.of(ctx).pop();
                      },
                      child: const Text(
                        'Tandai sudah dibaca',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (latest.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'Tidak ada notifikasi baru',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...latest.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            if (!item.isRead) {
                              notif.markAsRead(item.id);
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailNotifikasiScreen(
                                        notification: item),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: !item.isRead
                                  ? AppTheme.primaryColor
                                      .withValues(alpha: 0.04)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                if (!item.isRead)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(
                                            top: 5, right: 8),
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.judul,
                                        style: theme.textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.deskripsi,
                                        style: theme.textTheme
                                            .bodySmall
                                            ?.copyWith(
                                          color: theme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateFormat
                                            .format(item.createdAt),
                                        style: theme.textTheme
                                            .labelSmall
                                            ?.copyWith(
                                          color: theme.colorScheme
                                              .onSurfaceVariant
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),

              if (latest.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.push('/notifikasi');
                    },
                    child: const Text('Lihat Semua Notifikasi'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return _buildPublicHome();
    }

    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (context, home, _) {
          if (home.isLoading && home.user == null) {
            return const HomeSkeleton();
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
                      _buildSaldoSection(context, home),
                      const SizedBox(height: 16),

                      // ── Announcement Banners ──
                      _buildAnnouncementBanners(context),
                      const SizedBox(height: 16),

                      _buildServiceHoursBanner(context),
                      const SizedBox(height: 20),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildPriceInfoSection(context, home),
                      const SizedBox(height: 24),
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
  // Announcement Banners (like ad banners)
  // ─────────────────────────────────────────────

  Widget _buildAnnouncementBanners(BuildContext context) {
    return Consumer<PengumumanProvider>(
      builder: (context, pengumuman, _) {
        final items = pengumuman.announcements;
        if (items.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _AnnouncementBanner(item: item);
            },
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, HomeProvider home) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      snap: true,
      titleSpacing: 16,
      title: Text(
        AppConstants.appName,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      centerTitle: false,
      actions: [
        _buildNotifBell(context),
        const SizedBox(width: 4),
        CircleAvatar(
          radius: 16,
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          child: Text(
            (home.namaLengkap.isNotEmpty ? home.namaLengkap[0] : 'U').toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildSaldoSection(BuildContext context, HomeProvider home) {
    return SaldoCard(
      saldo: home.saldo,
      poin: home.poin,
      isLoading: false,
    );
  }

  Widget _buildServiceHoursBanner(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final hour = now.hour;
    final minute = now.minute;
    final currentMinutes = hour * 60 + minute;

    const openMinutes = 8 * 60;
    const closeMinutes = 17 * 60;

    final bool isSunday = dayOfWeek == DateTime.sunday;
    final bool isOpen = !isSunday && currentMinutes >= openMinutes && currentMinutes < closeMinutes;

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
        const SizedBox(height: 8),
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
                        child: Icon(action.icon, color: action.color, size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        ...categories.map((cat) => _PriceInfoItem(category: cat)),
      ],
    );
  }

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
// Announcement Banner (horizontal card)
// ─────────────────────────────────────────────

class _AnnouncementBanner extends StatelessWidget {
  const _AnnouncementBanner({required this.item});

  final dynamic item; // Announcement

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM', 'id_ID');
    final colors = [
      const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFF16A34A), Color(0xFF15803D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      const LinearGradient(
        colors: [Color(0xFFD97706), Color(0xFFB45309)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];

    // Use different gradient based on index (cycling through colors)
    final int safeIndex =
        item.id is int ? item.id.abs() % colors.length : 0;
    final gradient = colors[safeIndex];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigate to settings/pengumuman or show detail
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Pengumuman')),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateFormat.format(item.tanggal),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: theme.colorScheme.outlineVariant),
                        ),
                        child: Text(
                          item.isi.isNotEmpty ? item.isi : 'Tidak ada konten.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors[0].withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dateFormat.format(item.tanggal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.judul,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (item.isi.isNotEmpty)
                Text(
                  item.isi,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Helper Classes
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

class _PublicLink {
  const _PublicLink({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.bgColor,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color bgColor;
  final String route;
}

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
