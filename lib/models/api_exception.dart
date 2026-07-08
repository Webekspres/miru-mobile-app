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

String parseDioError(DioException error) {
  final underlying = error.error;
  if (underlying is ApiException) {
    return underlying.message;
  }

  final data = error.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return message;
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
