import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      _goHomeAfterDelay();
    }
  }

  Future<void> _goHomeAfterDelay() async {
    await Future<void>.delayed(_minDisplay);
    if (!mounted) return;
    // Always go to /home — let HomeScreen handle login prompt
    context.go('/home');
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
            ),
          ),
        ),
      ),
    );
  }
}
