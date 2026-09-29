import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/providers/auth_provider.dart';
import 'package:mirumobileapp/providers/auth_session.dart';
import 'package:mirumobileapp/providers/profile_provider.dart';
import 'package:mirumobileapp/screens/profile/change_email_screen.dart';
import 'package:mirumobileapp/services/api_client.dart';
import 'package:mirumobileapp/services/auth_service.dart';
import 'package:mirumobileapp/services/storage_service.dart';
import 'package:provider/provider.dart';

import '../helpers/test_http.dart';

void main() {
  late List<Map<String, dynamic>> otpRequests;
  late String currentEmail;

  Map<String, dynamic> user() =>
      {...userJson(), 'email': currentEmail, 'email_verified': true};

  Future<void> openScreen(WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    otpRequests = [];
    currentEmail = 'lama@gmail.com';
    final adapter = ScriptedAdapter((options) {
      final path = options.path;
      if (path.endsWith('/auth/login/')) {
        return jsonBody({'access': 'a', 'refresh': 'r', 'user': user()});
      }
      if (path.endsWith('/auth/email/request-otp/')) {
        otpRequests.add(Map<String, dynamic>.from(
          options.data is String ? jsonDecode(options.data as String) : options.data as Map,
        ));
        return jsonBody({'masked_email': 'ba***@gmail.com', 'purpose': 'email_verify'});
      }
      if (path.endsWith('/auth/email/verify-otp/')) {
        currentEmail = 'baru@gmail.com';
        return jsonBody({'user': user()});
      }
      return jsonBody(user()); // profil
    });
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api'))..httpClientAdapter = adapter;
    final storage = StorageService();
    final session = AuthSession(storage);
    final api = ApiClient(storageService: storage, authSession: session, dio: dio);
    final auth = AuthProvider(
      authService: AuthService(apiClient: api, storageService: storage, authSession: session),
      storageService: storage,
      authSession: session,
    );
    await tester.runAsync(() => auth.login(username: 'nasabah001', password: 'nasabah123'));
    final profile = ProfileProvider(apiClient: api);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: profile),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ChangeEmailScreen()),
              ),
              child: const Text('buka'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
  }

  testWidgets('asks for the password only when changing a verified email', (tester) async {
    await openScreen(tester);
    expect(find.text('Email saat ini: lama@gmail.com'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'lama@gmail.com');
    await tester.pump();
    expect(find.text('Kata sandi'), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, 'baru@gmail.com');
    await tester.pump();
    expect(find.text('Kata sandi'), findsOneWidget);

    await tester.tap(find.text('Kirim kode ke email baru'));
    await tester.pumpAndSettle();
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    expect(otpRequests, isEmpty);
  });

  testWidgets('sends email + password, verifies the OTP and closes', (tester) async {
    await openScreen(tester);

    await tester.enterText(find.byType(TextFormField).first, 'baru@gmail.com');
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(1), 'nasabah123');
    await tester.tap(find.text('Kirim kode ke email baru'));
    await tester.pumpAndSettle();

    expect(otpRequests.single, {'email': 'baru@gmail.com', 'password': 'nasabah123'});
    expect(find.textContaining('ba***@gmail.com'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Verifikasi'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangeEmailScreen), findsNothing);
    expect(find.text('Email berhasil diperbarui.'), findsOneWidget);
  });
}
