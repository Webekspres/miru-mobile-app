import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/providers/auth_session.dart';
import 'package:mirumobileapp/services/api_client.dart';
import 'package:mirumobileapp/services/interceptors/auth_interceptor.dart';
import 'package:mirumobileapp/services/storage_service.dart';

import '../helpers/test_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('only register, login and refresh are public (exact match)', () {
    expect(AuthInterceptor.isPublicPath('/users/'), isTrue);
    expect(AuthInterceptor.isPublicPath('/auth/login/'), isTrue);
    expect(AuthInterceptor.isPublicPath('/auth/refresh/'), isTrue);
    expect(AuthInterceptor.isPublicPath('/users/7/'), isFalse);
    expect(AuthInterceptor.isPublicPath('/auth/me/'), isFalse);
  });

  group('with a stored session', () {
    late Map<String, String?> authHeaders;
    late AuthSession session;
    late Dio dio;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({
        'access_token': 'lama',
        'refresh_token': 'r',
      });
      authHeaders = {};
      final storage = StorageService();
      session = AuthSession(storage)..setLoggedIn(true);
      final refreshDio = Dio(BaseOptions(baseUrl: 'http://test/api'))
        ..httpClientAdapter = ScriptedAdapter((options) {
          if (options.path.endsWith('/auth/refresh/')) {
            return jsonBody({'access': 'baru'});
          }
          // Ulang request setelah refresh.
          authHeaders['retry ${options.path}'] =
              options.headers['Authorization'] as String?;
          return jsonBody({'id': 7});
        });
      dio = Dio(BaseOptions(baseUrl: 'http://test/api'))
        ..httpClientAdapter = ScriptedAdapter((options) {
          final auth = options.headers['Authorization'] as String?;
          authHeaders['${options.method} ${options.path}'] = auth;
          if (auth == 'Bearer lama' && options.path == '/users/7/') {
            return jsonBody({'detail': 'expired'}, status: 401);
          }
          return jsonBody({'ok': true});
        })
        ..interceptors.addAll(ApiClient.buildInterceptors(
          storage: storage,
          refreshDio: refreshDio,
          authSession: session,
          enableDebugLog: false,
        ));
    });

    test('profile PATCH carries the token; expiry refreshes and retries', () async {
      await dio.patch<dynamic>('/users/7/', data: {'nama_lengkap': 'Budi'});

      expect(authHeaders['PATCH /users/7/'], 'Bearer lama');
      expect(authHeaders['retry /users/7/'], 'Bearer baru');
      expect(session.isLoggedIn, isTrue);
    });

    test('registration POST /users/ is sent without a token', () async {
      await dio.post<dynamic>('/users/', data: {'username': 'baru'});

      expect(authHeaders['POST /users/'], isNull);
    });
  });
}
