import 'package:flutter/material.dart';

enum MiruLogoVariant {
  icon,
  iconBg,
  full,
  fullBg,
}

class MiruLogo extends StatelessWidget {
  const MiruLogo({
    super.key,
    required this.variant,
    this.height = 48,
    this.width,
    this.fit = BoxFit.contain,
  });

  final MiruLogoVariant variant;
  final double height;
  final double? width;
  final BoxFit fit;

  static const _assetPaths = {
    MiruLogoVariant.icon: 'assets/images/logo.png',
    MiruLogoVariant.iconBg: 'assets/images/logo_bg.png',
    MiruLogoVariant.full: 'assets/images/logo_with_text.png',
    MiruLogoVariant.fullBg: 'assets/images/logo_with_text_bg.png',
  };

  static const _aspectRatios = {
    MiruLogoVariant.icon: 119 / 118,
    MiruLogoVariant.iconBg: 139 / 142,
    MiruLogoVariant.full: 312 / 118,
    MiruLogoVariant.fullBg: 399 / 218,
  };

  @override
  Widget build(BuildContext context) {
    final asset = _assetPaths[variant]!;
    final resolvedWidth = width ?? height * _aspectRatios[variant]!;

    return Image.asset(
      asset,
      height: height,
      width: resolvedWidth,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}
