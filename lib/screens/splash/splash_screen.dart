import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';
import '../../services/storage_service.dart';
import '../../widgets/shimmer_loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final storage = context.read<StorageService>();
    final token = await storage.read(AppConstants.accessTokenKey);

    if (!mounted) return;

    // Always go to /home — let HomeScreen handle login prompt
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // MIRU Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.recycling_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'MIRU',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Bank Sampah',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            // Skeleton sebagai pengganti spinner
            const SkeletonBlock(height: 14, width: 140),
            const SizedBox(height: 12),
            const SkeletonBlock(height: 10, width: 100),
          ],
        ),
      ),
    );
  }
}
