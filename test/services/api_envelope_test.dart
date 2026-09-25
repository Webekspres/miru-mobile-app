import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/api_envelope.dart';
import 'package:mirumobileapp/models/api_exception.dart';
import 'package:mirumobileapp/services/interceptors/envelope_interceptor.dart';

import '../helpers/test_http.dart';

void main() {
  test('parses a success envelope', () {
    final parsed = ApiEnvelope<Map<String, dynamic>>.fromJson(
      envelope(success: true, data: {'id': 1}, message: 'Berhasil'),
      fromJsonT: (json) => Map<String, dynamic>.from(json as Map),
    );
    expect(parsed.success, isTrue);
    expect(parsed.data?['id'], 1);
    expect(parsed.unwrap()['id'], 1);
  });

  test('parses an error envelope and unwrap throws', () {
    final parsed = ApiEnvelope<dynamic>.fromJson(
      envelope(
        success: false,
        statusCode: 400,
        message: 'Username atau password tidak sesuai.',
        code: 'AUTHENTICATION_FAILED',
        data: null,
      ),
    );
    expect(parsed.success, isFalse);
    expect(parsed.code, 'AUTHENTICATION_FAILED');
    expect(
      () => parsed.unwrap(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Username atau password tidak sesuai.',
        ),
      ),
    );
  });

  test('interceptor unwraps success data', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test/api'));
    dio.interceptors.add(EnvelopeInterceptor());
    dio.httpClientAdapter = ScriptedAdapter(
      (_) => jsonBody(envelope(success: true, data: {'ok': true})),
    );

    final response = await dio.get<dynamic>('/ping/');
    expect(response.data, {'ok': true});
  });

  test('interceptor rejects error envelope as ApiException', () async {
    final dio = Dio(BaseOptions(
      baseUrl: 'http://test/api',
      validateStatus: (status) => status != null && status < 500,
    ));
    dio.interceptors.add(EnvelopeInterceptor());
    dio.httpClientAdapter = ScriptedAdapter(
      (_) => jsonBody(
        envelope(
          success: false,
          statusCode: 400,
          message: 'Data tidak valid.',
          code: 'VALIDATION_ERROR',
        ),
        status: 400,
      ),
    );

    try {
      await dio.get<dynamic>('/fail/');
      fail('expected DioException');
    } on DioException catch (e) {
      expect(e.error, isA<ApiException>());
      expect((e.error as ApiException).message, 'Data tidak valid.');
    }
  });
}
