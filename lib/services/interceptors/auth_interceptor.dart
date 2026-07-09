import 'package:dio/dio.dart';

import '../../providers/auth_session.dart';
import '../storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.storage,
    required this.refreshDio,
    required this.authSession,
  });

  final StorageService storage;
  final Dio refreshDio;
  final AuthSession authSession;

  Future<bool>? _refreshFuture;

  static const _skipRefreshPaths = [
    '/auth/login/',
    '/auth/refresh/',
    '/users/',
  ];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublicPath(options.path)) {
      final token = await storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        _isPublicPath(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    try {
      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        await _clearSession();
        handler.next(err);
        return;
      }

      final accessToken = await storage.readAccessToken();
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';

      final response = await refreshDio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } catch (_) {
      await _clearSession();
      handler.next(err);
    }
  }

  bool _isPublicPath(String path) {
    return _skipRefreshPaths.any((publicPath) => path.contains(publicPath));
  }

  Future<bool> _refreshAccessToken() async {
    _refreshFuture ??= _doRefresh();
    try {
      return await _refreshFuture!;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    final response = await refreshDio.post<dynamic>(
      '/auth/refresh/',
      data: {'refresh': refreshToken},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return false;
    }

    final access = data['access'] as String?;
    if (access == null || access.isEmpty) {
      return false;
    }

    await storage.writeAccessToken(access);
    return true;
  }

  Future<void> _clearSession() async {
    await storage.clearTokens();
    authSession.setLoggedIn(false);
  }
}
