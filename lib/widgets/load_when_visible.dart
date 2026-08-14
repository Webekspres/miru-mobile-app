import 'package:flutter/material.dart';

/// Runs [onVisible] once each time this widget becomes the active tab/route
/// (TickerMode on) while [enabled] is true.
///
/// Used with [StatefulShellRoute.indexedStack]: offstage tabs stay mounted, so
/// `initState` does not re-run after logout → login. Fetch from here instead
/// so only the visible screen hits the network.
class LoadWhenVisible extends StatefulWidget {
  const LoadWhenVisible({
    super.key,
    required this.onVisible,
    required this.child,
    this.enabled = true,
  });

  final VoidCallback onVisible;
  final Widget child;
  final bool enabled;

  @override
  State<LoadWhenVisible> createState() => _LoadWhenVisibleState();
}

class _LoadWhenVisibleState extends State<LoadWhenVisible> {
  bool _wasActive = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(LoadWhenVisible oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _sync();
  }

  void _sync() {
    final active = widget.enabled && TickerMode.valuesOf(context).enabled;
    if (active && !_wasActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (!(widget.enabled && TickerMode.valuesOf(context).enabled)) return;
        widget.onVisible();
      });
    }
    _wasActive = active;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
