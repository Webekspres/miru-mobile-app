import 'api_exception.dart';

class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.meta,
    this.data,
    this.code,
    this.errors,
  });

  final bool success;
  final int statusCode;
  final String message;
  final T? data;
  final String? code;
  final Map<String, dynamic>? errors;
  final ApiMeta meta;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic json)? fromJsonT,
  }) {
    return ApiEnvelope(
      success: json['success'] as bool? ?? false,
      statusCode: json['status_code'] as int? ?? 0,
      message: json['message'] as String? ?? 'Terjadi kesalahan',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      code: json['code'] as String?,
      errors: json['errors'] != null
          ? Map<String, dynamic>.from(json['errors'] as Map)
          : null,
      meta: ApiMeta.fromJson(
        Map<String, dynamic>.from(json['meta'] as Map? ?? {}),
      ),
    );
  }

  /// Fallback parser bila response belum di-unwrap interceptor.
  T unwrap() {
    if (!success) {
      throw ApiException(
        message,
        statusCode: statusCode,
        code: code,
        fieldErrors: errors,
      );
    }
    return data as T;
  }
}

class ApiMeta {
  const ApiMeta({
    required this.timestamp,
    required this.requestId,
    this.pagination,
  });

  final String timestamp;
  final String requestId;
  final PaginationMeta? pagination;

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      timestamp: json['timestamp'] as String? ?? '',
      requestId: json['request_id'] as String? ?? '',
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(
              Map<String, dynamic>.from(json['pagination'] as Map),
            )
          : null,
    );
  }
}

class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
  });

  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
      totalItems: json['total_items'] as int? ?? 0,
    );
  }
}
