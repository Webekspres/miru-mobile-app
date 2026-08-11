import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  /// Jika `true`, splash screen tidak akan auto-navigate.
  /// Berguna untuk development/preview agar layout bisa diedit
  /// menggunakan Flutter hot-reload tanpa pindah halaman.
  final bool previewMode;

  const SplashScreen({super.key, this.previewMode = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minDisplay = Duration(milliseconds: 2200);
  static const _splashAsset = 'assets/images/splash_logo.png';

  @override
  void initState() {
    super.initState();
    if (!widget.previewMode) {
      _bootstrap();
    }
  }

  Future<void> _bootstrap() async {
    // Cold start: native Android splash menutupi Flutter sampai frame pertama
    // ter-rasterize. Jika timer dihitung dari initState, delay habis di balik
    // native splash → user langsung melihat /home (hot restart tidak kena ini).
    await WidgetsBinding.instance.waitUntilFirstFrameRasterized;
    if (!mounted) return;

    final authFuture = context.read<AuthProvider>().checkAuthStatus();
    await precacheImage(const AssetImage(_splashAsset), context);
    await Future.wait([
      authFuture,
      Future<void>.delayed(_minDisplay),
    ]);
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn && auth.needsPhoneVerification) {
      context.go('/verify-phone');
    } else {
      // Always go to /home — let HomeScreen handle login prompt
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoWidth =
        (MediaQuery.sizeOf(context).shortestSide * 0.68).clamp(240.0, 420.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Image.asset(
              _splashAsset,
              width: logoWidth,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
        ),
      ),
    );
  }
}
