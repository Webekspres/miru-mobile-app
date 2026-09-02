import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/providers/auth_provider.dart';
import 'package:mirumobileapp/providers/auth_session.dart';
import 'package:mirumobileapp/providers/launch_experience.dart';
import 'package:mirumobileapp/screens/auth/login_screen.dart';
import 'package:mirumobileapp/services/auth_service.dart';
import 'package:mirumobileapp/services/storage_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_http.dart';

Widget _loginApp() {
  final storage = StorageService();
  final session = AuthSession(storage);
  final api = apiClientWith(ScriptedAdapter((_) => jsonBody({})));
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LaunchExperience()),
      ChangeNotifierProvider(
        create: (_) => AuthProvider(
          authService: AuthService(
            apiClient: api,
            storageService: storage,
            authSession: session,
          ),
          storageService: storage,
          authSession: session,
        ),
      ),
    ],
    child: const MaterialApp(home: LoginScreen()),
  );
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('empty form keeps Masuk disabled', (tester) async {
    await tester.pumpWidget(_loginApp());
    await tester.pump();

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Masuk'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('short password is rejected in the form', (tester) async {
    await tester.pumpWidget(_loginApp());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'nasabah001');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.pump();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Password minimal 6 karakter'), findsOneWidget);
  });
}
