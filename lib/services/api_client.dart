import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/constants.dart';
import '../providers/auth_session.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/envelope_interceptor.dart';
import 'interceptors/safe_log_interceptor.dart';
import 'storage_service.dart';

class ApiClient {
  ApiClient({
    required StorageService storageService,
    required AuthSession authSession,
    Dio? dio,
  }) : dio = dio ?? _createDio(storageService, authSession);

  final Dio dio;

  static Dio _createDio(
    StorageService storageService,
    AuthSession authSession,
  ) {
    final options = BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'id',
      },
    );

    final refreshDio = Dio(options)..interceptors.add(EnvelopeInterceptor());

    final dio = Dio(options);
    dio.interceptors.addAll(
      buildInterceptors(
        storage: storageService,
        refreshDio: refreshDio,
        authSession: authSession,
      ),
    );

    return dio;
  }

  /// [enableDebugLog] follows [kDebugMode] so release never logs bodies.
  static List<Interceptor> buildInterceptors({
    required StorageService storage,
    required Dio refreshDio,
    required AuthSession authSession,
    bool enableDebugLog = kDebugMode,
  }) {
    return [
      AuthInterceptor(
        storage: storage,
        refreshDio: refreshDio,
        authSession: authSession,
      ),
      EnvelopeInterceptor(),
      if (enableDebugLog) SafeLogInterceptor(),
    ];
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
    );
    return fromJson(response.data);
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return fromJson(response.data);
  }

  Future<T> upload<T>(
    String path, {
    required FormData data,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await dio.post<dynamic>(
      path,
      data: data,
      options: Options(
        contentType: null,
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    return fromJson(response.data);
  }

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await dio.patch<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return fromJson(response.data);
  }

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await dio.delete<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
    return fromJson(response.data);
  }
}
