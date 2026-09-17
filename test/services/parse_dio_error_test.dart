import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/api_exception.dart';
import 'package:mirumobileapp/providers/auth_session.dart';
import 'package:mirumobileapp/services/api_client.dart';
import 'package:mirumobileapp/services/interceptors/safe_log_interceptor.dart';
import 'package:mirumobileapp/services/storage_service.dart';

DioException _dio({
  DioExceptionType type = DioExceptionType.badResponse,
  int? status,
  Object? error,
  String? message,
}) {
  return DioException(
    requestOptions: RequestOptions(path: '/x/'),
    type: type,
    error: error,
    message: message,
    response: status == null
        ? null
        : Response(
            requestOptions: RequestOptions(path: '/x/'),
            statusCode: status,
          ),
  );
}

void main() {
  test('HTTP 500 becomes a Bahasa Indonesia message', () {
    expect(
      parseDioError(_dio(status: 500, message: 'Http status error [500]')),
      kServerUnavailableMessage,
    );
  });

  test('offline connectionError is Bahasa Indonesia and does not crash', () {
    expect(
      parseDioError(_dio(type: DioExceptionType.connectionError)),
      'Tidak ada koneksi internet. Periksa jaringan Anda, lalu coba lagi.',
    );
  });

  test('SocketException unknown type is treated as offline', () {
    expect(
      parseDioError(
        _dio(
          type: DioExceptionType.unknown,
          error: const SocketException('Failed host lookup'),
        ),
      ),
      'Tidak ada koneksi internet. Periksa jaringan Anda, lalu coba lagi.',
    );
  });

  test('isTransientNetworkError is true for offline and 5xx', () {
    expect(isTransientNetworkError(_dio(type: DioExceptionType.connectionError)), isTrue);
    expect(isTransientNetworkError(_dio(status: 503)), isTrue);
    expect(isTransientNetworkError(_dio(status: 401)), isFalse);
  });

  test('release interceptor list has no HTTP body logger', () {
    final storage = StorageService();
    final interceptors = ApiClient.buildInterceptors(
      storage: storage,
      refreshDio: Dio(),
      authSession: AuthSession(storage),
      enableDebugLog: false,
    );
    expect(interceptors.whereType<SafeLogInterceptor>(), isEmpty);
  });

  test('redactSensitiveLog strips token, password, and KTP path', () {
    const raw = '''
Authorization: Bearer eyJhbGciOi.secret
{password: rahasia123, access: aaa, refresh: bbb, lampiran_ktp: /tmp/ktp.jpg}
"password":"nasabah123"
''';
    final redacted = redactSensitiveLog(raw);
    expect(redacted, contains('Bearer [REDACTED]'));
    expect(redacted, isNot(contains('rahasia123')));
    expect(redacted, isNot(contains('nasabah123')));
    expect(redacted, isNot(contains('eyJhbGciOi.secret')));
    expect(redacted, isNot(contains('/tmp/ktp.jpg')));
  });
}
