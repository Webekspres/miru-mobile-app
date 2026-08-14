import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/widgets/load_when_visible.dart';

void main() {
  testWidgets('does not load while offstage / ticker disabled', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      TickerMode(
        enabled: false,
        child: LoadWhenVisible(
          onVisible: () => calls++,
          child: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pump();
    expect(calls, 0);
  });

  testWidgets('loads once when becoming visible', (tester) async {
    var calls = 0;

    Widget build({required bool visible}) {
      return TickerMode(
        enabled: visible,
        child: LoadWhenVisible(
          onVisible: () => calls++,
          child: const SizedBox.shrink(),
        ),
      );
    }

    await tester.pumpWidget(build(visible: false));
    await tester.pump();
    expect(calls, 0);

    await tester.pumpWidget(build(visible: true));
    await tester.pump();
    expect(calls, 1);

    await tester.pumpWidget(build(visible: true));
    await tester.pump();
    expect(calls, 1);
  });

  testWidgets('loads when enabled flips on while already visible', (tester) async {
    var calls = 0;

    Widget build({required bool enabled}) {
      return TickerMode(
        enabled: true,
        child: LoadWhenVisible(
          enabled: enabled,
          onVisible: () => calls++,
          child: const SizedBox.shrink(),
        ),
      );
    }

    await tester.pumpWidget(build(enabled: false));
    await tester.pump();
    expect(calls, 0);

    await tester.pumpWidget(build(enabled: true));
    await tester.pump();
    expect(calls, 1);
  });
}
