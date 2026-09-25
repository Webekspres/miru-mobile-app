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

  group('email OTP', () {
    Map<String, dynamic> loginBody({required bool emailRequired}) => {
          'access': 'access-token',
          'refresh': 'refresh-token',
          'user': {
            ...userJson(),
            'email': '',
            'email_verified': !emailRequired,
            'email_required': emailRequired,
          },
        };

    test('login without verified email opens the email gate', () async {
      final auth = _build(
        ScriptedAdapter((_) => jsonBody(loginBody(emailRequired: true))),
      );
      await auth.login(username: 'nasabah001', password: 'nasabah123');

      expect(auth.needsEmailVerification, isTrue);
      expect(auth.authSession.needsEmailVerification, isTrue);
    });

    test('verifying OTP while logged in clears the gate', () async {
      final sent = <String, dynamic>{};
      final auth = _build(
        ScriptedAdapter((options) {
          if (options.path.endsWith('/auth/login/')) {
            return jsonBody(loginBody(emailRequired: true));
          }
          sent.addAll(Map<String, dynamic>.from(options.data as Map));
          return jsonBody({
            'email_verified': true,
            'user': {
              ...userJson(),
              'email': 'budi@gmail.com',
              'email_verified': true,
              'email_required': false,
            },
          });
        }),
      );
      await auth.login(username: 'nasabah001', password: 'nasabah123');
      await auth.verifyEmailOtp(otp: '123456');

      expect(sent, {'otp': '123456'});
      expect(auth.needsEmailVerification, isFalse);
      expect(auth.authSession.needsEmailVerification, isFalse);
      expect(auth.user?.email, 'budi@gmail.com');
    });

    test('registration request sends username and password', () async {
      Map<String, dynamic>? sent;
      final auth = _build(
        ScriptedAdapter((options) {
          sent = Map<String, dynamic>.from(options.data as Map);
          return jsonBody({'masked_email': 'bu***@gmail.com'});
        }),
      );
      final data = await auth.requestEmailOtp(
        email: ' budi@gmail.com ',
        username: 'budi',
        password: 'rahasia1',
      );

      expect(data['masked_email'], 'bu***@gmail.com');
      expect(sent, {
        'email': 'budi@gmail.com',
        'username': 'budi',
        'password': 'rahasia1',
      });
    });
  });
}
