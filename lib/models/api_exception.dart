import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.fieldErrors,
  });

  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? fieldErrors;

  @override
  String toString() => message;
}

/// Prefer server envelope `message`; fall back to known auth codes / network copy.
ApiException apiExceptionFromDio(DioException error) {
  final underlying = error.error;
  if (underlying is ApiException) {
    return ApiException(
      _localizeAuthMessage(underlying),
      statusCode: underlying.statusCode,
      code: underlying.code,
      fieldErrors: underlying.fieldErrors,
    );
  }

  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    final code = data['code'] as String?;
    final errors = data['errors'] != null
        ? Map<String, dynamic>.from(data['errors'] as Map)
        : null;
    if (message is String && message.isNotEmpty) {
      final mapped = ApiException(
        message,
        statusCode: error.response?.statusCode ?? data['status_code'] as int?,
        code: code,
        fieldErrors: errors,
      );
      return ApiException(
        _localizeAuthMessage(mapped),
        statusCode: mapped.statusCode,
        code: mapped.code,
        fieldErrors: mapped.fieldErrors,
      );
    }
  }

  return ApiException(
    parseDioError(error),
    statusCode: error.response?.statusCode,
  );
}

String parseDioError(DioException error) {
  final underlying = error.error;
  if (underlying is ApiException) {
    return _localizeAuthMessage(underlying);
  }

  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return _localizeAuthMessage(
        ApiException(
          message,
          statusCode: error.response?.statusCode ?? data['status_code'] as int?,
          code: data['code'] as String?,
          fieldErrors: data['errors'] != null
              ? Map<String, dynamic>.from(data['errors'] as Map)
              : null,
        ),
      );
    }
  }

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Koneksi timeout. Periksa jaringan Anda.';
    case DioExceptionType.connectionError:
      return 'Tidak dapat terhubung ke server. Pastikan backend berjalan.';
    case DioExceptionType.cancel:
      return 'Permintaan dibatalkan.';
    default:
      return error.message ?? 'Terjadi kesalahan. Silakan coba lagi.';
  }
}

String _localizeAuthMessage(ApiException exception) {
  final message = exception.message.trim();
  if (message.isNotEmpty) {
    return message;
  }

  final fieldErrors = exception.fieldErrors;
  if (fieldErrors != null) {
    for (final key in ['username', 'password', 'non_field_errors']) {
      final value = fieldErrors[key];
      if (value is List && value.isNotEmpty) {
        final first = value.first;
        if (first is String && first.trim().isNotEmpty) {
          return first.trim();
        }
      } else if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
  }

  switch (exception.code) {
    case 'AUTHENTICATION_FAILED':
      return 'Username atau password tidak sesuai.';
    case 'VALIDATION_ERROR':
      return 'Username dan password wajib diisi.';
    case 'PERMISSION_DENIED':
      return 'Anda tidak memiliki akses untuk masuk.';
    default:
      return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
