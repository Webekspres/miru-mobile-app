import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/user.dart';
import 'package:mirumobileapp/providers/auth_session.dart';
import 'package:mirumobileapp/providers/home_provider.dart';
import 'package:mirumobileapp/providers/profile_provider.dart';
import 'package:mirumobileapp/providers/saldo_provider.dart';
import 'package:mirumobileapp/screens/saldo/tarik_saldo_screen.dart';
import 'package:mirumobileapp/services/storage_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_http.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('nominal below Rp50.000 is rejected in the UI', (tester) async {
    final api = apiClientWith(ScriptedAdapter((_) => jsonBody({})));
    final storage = StorageService();
    final session = AuthSession(storage)..setLoggedIn(true);
    final user = User.fromJson(userJson(saldo: '200000.00'));
    final home = HomeProvider(apiClient: api)..hydrateFrom(user);
    final profile = ProfileProvider(apiClient: api)..hydrateFrom(user);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: session),
          ChangeNotifierProvider.value(value: home),
          ChangeNotifierProvider.value(value: profile),
          ChangeNotifierProvider(
            create: (_) => SaldoProvider(apiClient: api),
          ),
        ],
        child: const MaterialApp(home: TarikSaldoScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Lengkapi Alamat Profil'), findsNothing);

    await tester.enterText(find.byType(TextFormField), '10000');
    await tester.pump();

    expect(find.textContaining('Minimal penarikan'), findsWidgets);
    final submit = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Ajukan Penarikan'),
    );
    expect(submit.onPressed, isNull);
  });
}
