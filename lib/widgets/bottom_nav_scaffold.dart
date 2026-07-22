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

  static const double _barHeight = 64;
  static const double _fabSize = 58;
  /// ~1/4 FAB di atas tepi bar; ~3/4 overlap dengan bar.
  static const double _fabProtrude = _fabSize * 0.25;

  /// Padding bawah untuk scroll di tab utama (body di bawah nav via [extendBody]).
  static double scrollBottomPadding(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom +
        _barHeight +
        _fabProtrude +
        6;
  }

  void _onTabSelected(int branchIndex) {
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnHomeTab = navigationShell.currentIndex == 0;
    final currentIndex = navigationShell.currentIndex;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: !isOnHomeTab,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showExitDialog(
          context,
          message:
              'Apakah Anda yakin ingin keluar dari aplikasi ${AppConstants.appName}?',
        );
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        // Body digambar di bawah nav (FAB mengambang). Clearance lewat
        // [scrollBottomPadding] di tiap tab — jangan Padding di sini (jadi strip abu).
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: Consumer<NotificationProvider>(
          builder: (context, notifProvider, _) {
            final unreadCount = notifProvider.unreadCount;

            return SizedBox(
              height: _barHeight + _fabProtrude + bottomInset,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Bar putih — tinggi normal, tanpa ikut tinggi FAB.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Material(
                      color: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.black26,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomInset),
                        child: SizedBox(
                          height: _barHeight,
                          child: Row(
                            children: [
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.home_outlined,
                                  selectedIcon: Icons.home_rounded,
                                  label: 'Beranda',
                                  selected: currentIndex == 0,
                                  onTap: () => _onTabSelected(0),
                                ),
                              ),
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.receipt_long_outlined,
                                  selectedIcon: Icons.receipt_long_rounded,
                                  label: 'Riwayat',
                                  selected: currentIndex == 1,
                                  onTap: () => _onTabSelected(1),
                                ),
                              ),
                              const SizedBox(width: _fabSize + 8),
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.notifications_outlined,
                                  selectedIcon: Icons.notifications_rounded,
                                  label: 'Notifikasi',
                                  selected: currentIndex == 2,
                                  badgeCount: unreadCount,
                                  onTap: () => _onTabSelected(2),
                                ),
                              ),
                              Expanded(
                                child: _NavItem(
                                  icon: Icons.person_outline,
                                  selectedIcon: Icons.person_rounded,
                                  label: 'Profil',
                                  selected: currentIndex == 3,
                                  onTap: () => _onTabSelected(3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // FAB mengambang: tepi atas bar di ~3/4 tinggi tombol.
                  Positioned(
                    bottom: bottomInset + (_barHeight - _fabSize * 0.75),
                    child: _JemputCenterButton(
                      size: _fabSize,
                      onTap: () => context.push('/home/penjemputan'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Elevated circular center action — symmetrical icon for jemput sampah.
class _JemputCenterButton extends StatelessWidget {
  const _JemputCenterButton({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Jemput sampah',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Icon(
            // Recycling mark is left-right symmetrical — fits a center FAB.
            Icons.recycling_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppTheme.primaryColor
        : Theme.of(context).colorScheme.onSurfaceVariant;

    Widget iconWidget = Icon(
      selected ? selectedIcon : icon,
      color: color,
      size: 24,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text(
          badgeCount > 99 ? '99+' : badgeCount.toString(),
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
        child: iconWidget,
      );
    }

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
