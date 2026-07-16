import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/miru_logo.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Always go to /home — let HomeScreen handle login prompt
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiruLogo(
              variant: MiruLogoVariant.fullBg,
              height: 72,
            ),
            const SizedBox(height: 20),
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
