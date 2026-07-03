# 04 — API Integration (Mobile)

## API Client Configuration

```dart
// services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    
    _dio.interceptors.add(AuthInterceptor(_storage));
    _dio.interceptors.add(ErrorInterceptor());
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
    _dio.get(path, queryParameters: params);
    
  Future<Response> post(String path, {dynamic data}) =>
    _dio.post(path, data: data);
    
  Future<Response> patch(String path, {dynamic data}) =>
    _dio.patch(path, data: data);
    
  Future<Response> delete(String path) =>
    _dio.delete(path);
}
```

## Auth Interceptor
```dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try refresh token
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          final response = await Dio().post(
            '${AppConstants.baseUrl.replaceAll('/api', '')}/api/token/refresh/',
            data: {'refresh': refreshToken},
          );
          final newToken = response.data['access'];
          await _storage.write(key: 'access_token', newToken);
          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await Dio().fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } catch (_) {
          // Refresh failed → logout
          await _storage.deleteAll();
          // Navigate to login
        }
      }
    }
    handler.next(err);
  }
}
```

## API Endpoints untuk Mobile

| Fitur | Method | Endpoint | Provider |
|-------|--------|----------|----------|
| Login | POST | `/api/token/` | AuthProvider |
| Register | POST | `/api/users/` | AuthProvider |
| Refresh Token | POST | `/api/token/refresh/` | AuthProvider |
| Profil | GET | `/api/users/{id}/` | AuthProvider |
| Update Profil | PATCH | `/api/users/{id}/` | AuthProvider |
| Kategori Sampah | GET | `/api/sampah/kategori/` | HomeProvider |
| Ajukan Jemput | POST | `/api/penjemputan/` | PenjemputanProvider |
| Status Jemput | GET | `/api/penjemputan/?nasabah={id}` | PenjemputanProvider |
| Riwayat Setoran | GET | `/api/transaksi/?nasabah={id}` | SaldoProvider |
| Riwayat Penarikan | GET | `/api/saldo/?nasabah={id}` | SaldoProvider |
| Ajukan Tarik Saldo | POST | `/api/saldo/` | SaldoProvider |
| Katalog Reward | GET | `/api/reward/katalog/` | RewardProvider |
| Ajukan Tukar Poin | POST | `/api/reward/tukar/` | RewardProvider |
| Riwayat Tukar Poin | GET | `/api/reward/tukar/?nasabah={id}` | RewardProvider |
| Ajukan Pengaduan | POST | `/api/pengaduan/` | PengaduanProvider |
| Status Pengaduan | GET | `/api/pengaduan/?nasabah={id}` | PengaduanProvider |

## Error Handling untuk Mobile

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
}
```

Setiap provider melakukan error handling dan menampilkan pesan di UI:
```dart
try {
  await api.post('/penjemputan/', data: pengajuanData);
  // Success → show success message
} on DioException catch (e) {
  final message = e.response?.data['detail'] ?? 'Terjadi kesalahan. Silakan coba lagi.';
  // Show error snackbar
  throw ApiException(message);
}
```
