import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/api_exception.dart';
import 'package:mirumobileapp/providers/auth_provider.dart';
import 'package:mirumobileapp/providers/auth_session.dart';
import 'package:mirumobileapp/services/api_client.dart';
import 'package:mirumobileapp/services/auth_service.dart';
import 'package:mirumobileapp/services/storage_service.dart';

import '../helpers/test_http.dart';

AuthProvider _build(ScriptedAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api'));
  dio.httpClientAdapter = adapter;
  final storage = StorageService();
  final session = AuthSession(storage);
  final api = ApiClient(
    storageService: storage,
    authSession: session,
    dio: dio,
  );
  return AuthProvider(
    authService: AuthService(
      apiClient: api,
      storageService: storage,
      authSession: session,
    ),
    storageService: storage,
    authSession: session,
  );
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('login accepts nasabah and stores the user', () async {
    final auth = _build(
      ScriptedAdapter(
        (_) => jsonBody({
          'access': 'access-token',
          'refresh': 'refresh-token',
          'user': userJson(),
        }),
      ),
    );

    await auth.login(username: 'nasabah001', password: 'nasabah123');

    expect(auth.isNasabah, isTrue);
    expect(auth.user?.username, 'nasabah001');
    expect(auth.authSession.isLoggedIn, isTrue);
  });

  test('login rejects staff with the Web Admin message', () async {
    final auth = _build(
      ScriptedAdapter(
        (_) => jsonBody({
          'access': 'access-token',
          'refresh': 'refresh-token',
          'user': userJson(username: 'admin', role: 'admin', nama: 'Admin'),
        }),
      ),
    );

    await expectLater(
      auth.login(username: 'admin', password: 'admin123'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Akun petugas/admin hanya dapat login melalui Web Admin MIRU.',
        ),
      ),
    );
    expect(auth.isLoggedIn, isFalse);
    expect(auth.authSession.isLoggedIn, isFalse);
  });

  test('register does not auto-login', () async {
    final auth = _build(
      ScriptedAdapter((_) => jsonBody(userJson(username: 'baru'))),
    );

    await auth.register(
      username: 'baru',
      password: 'secret1',
      namaLengkap: 'Nasabah Baru',
    );

    expect(auth.isLoggedIn, isFalse);
    expect(auth.user, isNull);
  });
}
