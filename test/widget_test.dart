import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mirumobileapp/app.dart';

void main() {
  testWidgets('App shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MiruApp());

    expect(
      find.image(const AssetImage('assets/images/splash_logo.png')),
      findsOneWidget,
    );
  });
}
