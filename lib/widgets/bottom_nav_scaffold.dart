import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/notification_provider.dart';
import 'exit_dialog.dart';

class BottomNavScaffold extends StatelessWidget {
  const BottomNavScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isOnHomeTab = navigationShell.currentIndex == 0;

    return PopScope(
      canPop: !isOnHomeTab,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showExitDialog(
          context,
          message: 'Apakah Anda yakin ingin keluar dari aplikasi ${AppConstants.appName}?',
        );
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Consumer<NotificationProvider>(
          builder: (context, notifProvider, _) {
            final unreadCount = notifProvider.unreadCount;
            return NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              height: 64,
              backgroundColor: Colors.white,
              indicatorColor: AppTheme.primaryColor.withValues(alpha: 0.15),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon:
                      Icon(Icons.home_rounded, color: AppTheme.primaryColor),
                  label: 'Beranda',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded,
                      color: AppTheme.primaryColor),
                  label: 'Riwayat',
                ),
                NavigationDestination(
                  icon: unreadCount > 0
                      ? Badge(
                          label: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                          child: const Icon(Icons.notifications_outlined),
                        )
                      : const Icon(Icons.notifications_outlined),
                  selectedIcon: unreadCount > 0
                      ? Badge(
                          label: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                          child: const Icon(Icons.notifications_rounded,
                              color: AppTheme.primaryColor),
                        )
                      : const Icon(Icons.notifications_rounded,
                          color: AppTheme.primaryColor),
                  label: 'Notifikasi',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon:
                      Icon(Icons.person_rounded, color: AppTheme.primaryColor),
                  label: 'Profil',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
