import 'package:flutter/material.dart';

/// Shimmer animation helper: wraps child with a gradient shimmer overlay.
class ShimmerWidget extends StatefulWidget {
  const ShimmerWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE5E7EB),
                Color(0xFFF3F4F6),
                Color(0xFFE5E7EB),
              ],
              stops: [
                (_animation.value).clamp(0.0, 1.0),
                (_animation.value + 0.4).clamp(0.0, 1.0),
                (_animation.value + 0.8).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

/// Rounded rectangle skeleton block.
class SkeletonBlock extends StatelessWidget {
  const SkeletonBlock({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Circular skeleton (for avatars/icons).
class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({
    super.key,
    this.size = 48,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Color(0xFFE5E7EB),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// A row of skeleton blocks mimicking a list item.
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SkeletonCircle(size: 42),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBlock(height: 14, width: 160),
                SizedBox(height: 8),
                SkeletonBlock(height: 12, width: 100),
              ],
            ),
          ),
          SizedBox(width: 8),
          SkeletonBlock(height: 14, width: 80),
        ],
      ),
    );
  }
}

/// Skeleton card with border mimicking a container card.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 80});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ShimmerWidget(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
      ),
    );
  }
}

/// Skeleton for list screens (Riwayat, Penjemputan, Pengaduan).
/// Header/app bar stays visible; this only fills the dynamic list area.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.itemCount = 6,
    this.padding,
  });

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      child: Column(
        children: List.generate(
          itemCount,
          (_) => const SkeletonListItem(),
        ),
      ),
    );
  }
}
