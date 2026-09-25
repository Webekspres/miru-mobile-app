import 'package:flutter/material.dart';

import '../config/constants.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackButton,
    this.onBack,
    this.bodyPadding,
    this.resizeToAvoidBottomInset = true,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool? showBackButton;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry? bodyPadding;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final shouldShowBack = showBackButton ?? canPop;

    Widget content = body;
    if (bodyPadding != null) {
      content = Padding(
        padding: bodyPadding!,
        child: body,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: AppBar(
        title: Text(title),
        leading: shouldShowBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Kembali',
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              )
            : null,
        actions: actions,
      ),
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// AppBar untuk layar utama tanpa tombol kembali.
class HomeAppScaffold extends StatelessWidget {
  const HomeAppScaffold({
    super.key,
    this.title = AppConstants.appName,
    required this.body,
    this.actions,
    this.bodyPadding = const EdgeInsets.all(16),
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? bodyPadding;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      showBackButton: false,
      actions: actions,
      bodyPadding: bodyPadding,
      body: body,
    );
  }
}
