import 'dart:async';

import 'package:flutter/material.dart';

import 'notif_style.dart';

OverlayEntry? _current;

/// Banner push bergaya (muncul dari atas) saat aplikasi sedang terbuka.
/// Ketuk untuk membuka, geser ke atas untuk menutup; hilang sendiri 5 detik.
void showPushBanner(
  OverlayState overlay, {
  required String title,
  String? body,
  String? kategori,
  VoidCallback? onTap,
}) {
  _current?.remove();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _PushBanner(
      title: title,
      body: body,
      style: notifStyleFor(kategori),
      onTap: onTap,
      onDismissed: () {
        if (_current == entry) _current = null;
        if (entry.mounted) entry.remove();
      },
    ),
  );
  _current = entry;
  overlay.insert(entry);
}

class _PushBanner extends StatefulWidget {
  const _PushBanner({
    required this.title,
    required this.body,
    required this.style,
    required this.onTap,
    required this.onDismissed,
  });

  final String title;
  final String? body;
  final NotifStyle style;
  final VoidCallback? onTap;
  final VoidCallback onDismissed;

  @override
  State<_PushBanner> createState() => _PushBannerState();
}

class _PushBannerState extends State<_PushBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), _hide);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _hide() async {
    _timer?.cancel();
    if (!mounted) return;
    await _anim.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.style;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -1.2), end: Offset.zero)
              .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Dismissible(
              key: const ValueKey('push-banner'),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onDismissed(),
              child: Material(
                elevation: 8,
                shadowColor: style.color.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    widget.onTap?.call();
                    _hide();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: style.color, width: 5)),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: style.background,
                          child: Icon(style.icon, color: style.color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (widget.body != null && widget.body!.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  widget.body!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.onTap != null) ...[
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: style.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
