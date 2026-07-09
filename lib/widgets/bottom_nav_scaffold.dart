import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
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
      // Only block back on Home tab; other tabs navigate naturally
      canPop: !isOnHomeTab,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        // Only intercept on Home tab
        final shouldExit = await showExitDialog(
          context,
          message: 'Apakah Anda yakin ingin keluar dari aplikasi MIRU?',
        );
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
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
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon:
                  Icon(Icons.home_rounded, color: AppTheme.primaryColor),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded,
                  color: AppTheme.primaryColor),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon:
                  Icon(Icons.person_rounded, color: AppTheme.primaryColor),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
