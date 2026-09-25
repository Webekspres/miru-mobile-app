import 'package:flutter/material.dart';

import '../config/theme.dart';
import 'miru_logo.dart';

/// Onboarding / welcome layout: floating illustration over decorative shapes
/// (not a full-bleed boxed photo).
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onButton,
    this.pageIndex = 0,
    this.pageCount = 3,
    this.showSkip = false,
    this.onSkip,
  });

  final String imageAsset;
  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onButton;
  final int pageIndex;
  final int pageCount;
  final bool showSkip;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF0FDF4),
              Color(0xFFD1FAE5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    const MiruLogo(variant: MiruLogoVariant.icon, height: 32),
                    const Spacer(),
                    if (showSkip && onSkip != null)
                      TextButton(
                        onPressed: onSkip,
                        child: const Text('Lewati'),
                      ),
                  ],
                ),
                const Spacer(flex: 1),
                _IllustrationHero(asset: imageAsset),
                const Spacer(flex: 1),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF14532D),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 168,
                  child: ElevatedButton(
                    onPressed: onButton,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(buttonLabel),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pageCount, (i) {
                    final active = i == pageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IllustrationHero extends StatelessWidget {
  const _IllustrationHero({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 28,
            top: 18,
            child: _shape(132, const Color(0xFFBBF7D0), 0.9),
          ),
          Positioned(
            right: 16,
            bottom: 12,
            child: _shape(108, const Color(0xFF6EE7B7), 0.55),
          ),
          Positioned(
            right: 48,
            top: 8,
            child: _shape(42, const Color(0xFFA7F3D0), 1),
          ),
          Positioned(
            left: 18,
            bottom: 28,
            child: _shape(36, const Color(0xFF86EFAC), 0.8),
          ),
          Positioned(
            right: 72,
            top: 88,
            child: Transform.rotate(
              angle: 0.6,
              child: _shape(64, const Color(0xFFD9F99D), 0.7, squircle: true),
            ),
          ),
          Image.asset(
            asset,
            height: 210,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            // White studio backdrop blends into the mint page so it is not a photo box.
            color: const Color(0xFFF0FDF4),
            colorBlendMode: BlendMode.multiply,
          ),
        ],
      ),
    );
  }

  Widget _shape(
    double size,
    Color color,
    double opacity, {
    bool squircle = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(squircle ? size * 0.38 : size / 2),
      ),
    );
  }
}
