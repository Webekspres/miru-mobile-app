import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/notification.dart';
import '../../providers/auth_session.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/load_when_visible.dart';
import '../../widgets/login_prompt.dart';
import '../../widgets/bottom_nav_scaffold.dart';
import '../../widgets/shimmer_loading.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  void _loadData() {
    context.read<NotificationProvider>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthSession>().isLoggedIn;

    if (!isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifikasi')),
        body: const LoginPrompt(
          title: 'Notifikasi',
          message: 'Masuk untuk melihat notifikasi aktivitas akun Anda.',
        ),
      );
    }

    return LoadWhenVisible(
      onVisible: _loadData,
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notif, _) {
              if (notif.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => notif.markAllAsRead(),
                child: const Text(
                  'Tandai sudah dibaca',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notif, _) {
          if (notif.isLoading && notif.notifications.isEmpty) {
            return ListSkeleton(
              itemCount: 6,
              padding: EdgeInsets.fromLTRB(
                0,
                4,
                0,
                BottomNavScaffold.scrollBottomPadding(context),
              ),
            );
          }

          if (notif.hasError && notif.notifications.isEmpty) {
            return ErrorView(
              title: 'Gagal memuat notifikasi',
              message: notif.error!,
              onRetry: () => notif.loadNotifications(),
            );
          }

          if (notif.notifications.isEmpty) {
            final theme = Theme.of(context);
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          size: 32,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Belum ada notifikasi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Notifikasi tentang setoran, penjemputan, penarikan, dan aktivitas lainnya akan muncul di sini.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
            onRefresh: () => notif.refresh(),
            color: AppTheme.primaryColor,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                BottomNavScaffold.scrollBottomPadding(context),
              ),
              itemCount: notif.notifications.length,
              itemBuilder: (context, index) {
                final item = notif.notifications[index];
                final isUnread = !item.isRead;
                return _NotifCard(
                  item: item,
                  isUnread: isUnread,
                  onTap: () {
                    if (isUnread) {
                      notif.markAsRead(item.id);
                    }
                    context.push('/notifikasi/detail', extra: item);
                  },
                );
              },
            ),
          );
        },
      ),
    ),
    );
  }
}

// ─────────────────────────────────────────────
// Notification Card
// ─────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.item,
    required this.isUnread,
    required this.onTap,
  });

  final AppNotification item;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM HH:mm', 'id_ID');

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
              color: isUnread
                  ? AppTheme.primaryColor.withValues(alpha: 0.04)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUnread
                    ? AppTheme.primaryColor.withValues(alpha: 0.2)
                    : theme.colorScheme.outlineVariant,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread dot
                if (isUnread)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, right: 10),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.deskripsi,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateFormat.format(item.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
