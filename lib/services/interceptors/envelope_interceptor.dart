import 'package:dio/dio.dart';

import '../../models/api_envelope.dart';
import '../../models/api_exception.dart';

class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('success')) {
      final envelope = ApiEnvelope<dynamic>.fromJson(body);
      if (!envelope.success) {
        handler.reject(
          _envelopeException(response.requestOptions, response, envelope),
        );
        return;
      }
      response.data = envelope.data;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final data = err.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('success')) {
      final envelope = ApiEnvelope<dynamic>.fromJson(data);
      if (!envelope.success) {
        handler.reject(
          _envelopeException(err.requestOptions, err.response, envelope),
        );
        return;
      }
      if (err.response != null) {
        handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            data: envelope.data,
            statusCode: err.response!.statusCode,
            statusMessage: err.response!.statusMessage,
            headers: err.response!.headers,
          ),
        );
        return;
      }
    }
    handler.next(err);
  }

  DioException _envelopeException(
    RequestOptions requestOptions,
    Response<dynamic>? response,
    ApiEnvelope<dynamic> envelope,
  ) {
    final exception = ApiException(
      envelope.message,
      statusCode: envelope.statusCode,
      code: envelope.code,
      fieldErrors: envelope.errors,
    );
    return DioException(
      requestOptions: requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: exception,
      message: envelope.message,
    );
  }
}
