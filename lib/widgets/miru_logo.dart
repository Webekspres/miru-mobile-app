import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Logo variants composed from 4 base assets:
/// [logo.png], [logo_white.png], [text.png], [text_white.png].
enum MiruLogoVariant {
  /// Colored icon only.
  icon,

  /// Colored icon on a soft rounded background.
  iconBg,

  /// Icon + wordmark in a horizontal row (colored).
  full,

  /// [full] inside a soft rounded background.
  fullBg,

  /// Icon + wordmark in a horizontal row (white).
  fullWhite,

  /// Icon above wordmark (colored).
  textBottom,
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

  static const _logo = 'assets/images/logo.png';
  static const _logoWhite = 'assets/images/logo_white.png';
  static const _text = 'assets/images/text.png';
  static const _textWhite = 'assets/images/text_white.png';

  /// Wordmark width relative to icon/row height.
  static const _textWidthFactor = 2.2;
  static const _gapFactor = 0.12;
  static const _bgPaddingFactor = 0.18;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case MiruLogoVariant.icon:
        return _iconOnly(asset: _logo, size: height);

      case MiruLogoVariant.iconBg:
        return _withSoftBg(
          child: _iconOnly(asset: _logo, size: height),
          height: height,
        );

      case MiruLogoVariant.full:
        return _horizontal(
          iconAsset: _logo,
          textAsset: _text,
          height: height,
        );

      case MiruLogoVariant.fullBg:
        return _withSoftBg(
          child: _horizontal(
            iconAsset: _logo,
            textAsset: _text,
            height: height,
          ),
          height: height,
        );

      case MiruLogoVariant.fullWhite:
        return _horizontal(
          iconAsset: _logoWhite,
          textAsset: _textWhite,
          height: height,
        );

      case MiruLogoVariant.textBottom:
        return _stacked(
          iconAsset: _logo,
          textAsset: _text,
          height: height,
        );
    }
  }

  Widget _asset(String path, {required double height, double? width}) {
    return Image.asset(
      path,
      height: height,
      width: width,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }

  Widget _iconOnly({required String asset, required double size}) {
    return SizedBox(
      width: width ?? size,
      height: size,
      child: _asset(asset, height: size, width: size),
    );
  }

  Widget _horizontal({
    required String iconAsset,
    required String textAsset,
    required double height,
  }) {
    final gap = height * _gapFactor;
    final textW = height * _textWidthFactor;
    final totalW = width ?? (height + gap + textW);

    return SizedBox(
      width: totalW,
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _asset(iconAsset, height: height, width: height),
          SizedBox(width: gap),
          _asset(textAsset, height: height * 0.55, width: textW),
        ],
      ),
    );
  }

  Widget _stacked({
    required String iconAsset,
    required String textAsset,
    required double height,
  }) {
    // [height] is total stack height (icon + gap + text).
    final gap = height * 0.06;
    final textH = height * 0.22;
    final iconH = height - gap - textH;
    final textW = iconH * _textWidthFactor;
    final totalW = width ?? textW.clamp(iconH, double.infinity);

    return SizedBox(
      width: totalW,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _asset(iconAsset, height: iconH, width: iconH),
          SizedBox(height: gap),
          _asset(textAsset, height: textH, width: textW),
        ],
      ),
    );
  }

  Widget _withSoftBg({required Widget child, required double height}) {
    final pad = height * _bgPaddingFactor;
    return Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(pad * 1.4),
      ),
      child: child,
    );
  }
}
