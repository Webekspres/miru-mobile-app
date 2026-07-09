# 04 — API Integration (Mobile)

> **Sumber kebenaran API:** repositori GitHub **miru-backend-api** — `.ai-steering/04-api-contracts-and-standards.md`
>
> Dokumen ini fokus pada **implementasi client** Flutter/Dio. Jangan duplikasi spesifikasi endpoint — selalu rujuk backend §04.

---

## 1. Base Configuration

```dart
// lib/config/constants.dart
class AppConstants {
  static const String appName = 'MIRU Bank Sampah';

  // Android Emulator → 10.0.2.2 maps to host localhost
  static const String apiBaseUrl = 'http://10.0.2.2:8000';
  static const String apiPrefix = '$apiBaseUrl/api';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
```

| Environment | Base URL |
|-------------|----------|
| Android Emulator | `http://10.0.2.2:8000` |
| iOS Simulator | `http://localhost:8000` |
| Device fisik (LAN) | `http://<IP-komputer>:8000` |
| Production | `https://api.mirubanksampah.id` (usulan) |

Backend harus dijalankan dengan `runserver 0.0.0.0:8000` saat tes di device fisik.

---

## 2. JSON Envelope — WAJIB Dipahami

```dart
class ApiEnvelope<T> {
  final bool success;
  final int statusCode;
  final String message;
  final T? data;
  final String? code;
  final Map<String, dynamic>? errors;
  final ApiMeta meta;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiEnvelope(
      success: json['success'] as bool,
      statusCode: json['status_code'] as int,
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      code: json['code'] as String?,
      errors: json['errors'] as Map<String, dynamic>?,
      meta: ApiMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class ApiMeta {
  final String timestamp;
  final String requestId;
  final PaginationMeta? pagination;
  // ...
}
```

**Aturan client:**
- Model bisnis parse dari `envelope.data`, bukan root JSON
- Error message user-friendly dari `envelope.message`
- Validasi field dari `envelope.errors`
- Pagination dari `envelope.meta.pagination`

---

## 3. Autentikasi

### 3.1 Endpoints

| Aksi | Method | Endpoint |
|------|--------|----------|
| Login | POST | `/api/auth/login/` |
| Refresh | POST | `/api/auth/refresh/` |
| Profil | GET | `/api/auth/me/` |
| Registrasi | POST | `/api/users/` (public) |

### 3.2 Login Flow

1. User input username + password
2. `POST /api/auth/login/` → parse `data.access`, `data.refresh`, `data.user`
3. Simpan token di `flutter_secure_storage`
4. Validasi `data.user.role == 'nasabah'` — jika bukan, tolak & logout
5. Navigate ke `/home`

### 3.3 Registrasi Flow

```json
POST /api/users/
{
  "username": "budi_santoso",
  "password": "rahasia123",
  "nama_lengkap": "Budi Santoso",
  "no_hp": "08123456789",
  "alamat": "Jl. Cendrawasih No. 1, Timika",
  "setuju_kebijakan_data": true
}
```

Role default backend: `nasabah`. Setelah sukses → auto login.

### 3.4 Token Refresh (Interceptor)

- On `401`: coba `POST /api/auth/refresh/` dengan refresh token
- Update access token, retry request
- Jika gagal: clear storage → navigate `/login`

---

## 4. API Client (Dio)

```dart
// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiPrefix,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'id',
      },
    ));
    _dio.interceptors.addAll([
      AuthInterceptor(_storage),
      EnvelopeInterceptor(),
      LogInterceptor(requestBody: true, responseBody: true), // dev only
    ]);
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    return fromJson(response.data);
  }

  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    final response = await _dio.post(path, data: data);
    return fromJson(response.data);
  }

  // patch, delete ...
}
```

### Envelope Interceptor

```dart
class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('success')) {
      if (body['success'] != true) {
        handler.reject(DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: body['message'] as String? ?? 'Terjadi kesalahan',
        ));
        return;
      }
      // Unwrap: downstream code receives `data` payload only
      response.data = body['data'];
    }
    handler.next(response);
  }
}
```

### Auth Interceptor

```dart
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // refresh token logic — lihat AuthService
    }
    handler.next(err);
  }
}
```

---

## 5. Endpoint Mobile (Nasabah)

| Fitur | Method | Endpoint | Auth |
|-------|--------|----------|------|
| Login | POST | `/auth/login/` | Public |
| Refresh | POST | `/auth/refresh/` | Public |
| Profil | GET | `/auth/me/` | JWT |
| Registrasi | POST | `/users/` | Public |
| Update profil | PATCH | `/users/{id}/` | JWT (owner) |
| Kategori sampah | GET | `/waste-categories/` | Public |
| Ajukan penjemputan | POST | `/pickups/` | JWT |
| Status penjemputan | GET | `/pickups/?nasabah={id}` | JWT |
| Riwayat setoran | GET | `/deposits/?nasabah={id}` | JWT |
| Riwayat penarikan | GET | `/withdrawals/?nasabah={id}` | JWT |
| Ajukan penarikan | POST | `/withdrawals/` | JWT |
| Katalog reward | GET | `/rewards/` | JWT |
| Tukar poin | POST | `/reward-redemptions/` | JWT |
| Riwayat penukaran | GET | `/reward-redemptions/?nasabah={id}` | JWT |
| Ajukan pengaduan | POST | `/complaints/` | JWT |
| Status pengaduan | GET | `/complaints/?nasabah={id}` | JWT |

> Path relatif terhadap `apiPrefix` (`/api`). Contoh penuh: `http://10.0.2.2:8000/api/auth/login/`

### Filter & Pagination

```
?page=1&page_size=20
?nasabah=5
?status=menunggu
?ordering=-tanggal
```

---

## 6. Error Handling

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final Map<String, dynamic>? fieldErrors;

  ApiException(this.message, {this.statusCode, this.code, this.fieldErrors});
}

String parseDioError(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['message'] != null) {
    return data['message'] as String;
  }
  if (e.type == DioExceptionType.connectionTimeout) {
    return 'Koneksi timeout. Periksa jaringan Anda.';
  }
  if (e.type == DioExceptionType.connectionError) {
    return 'Tidak dapat terhubung ke server. Pastikan backend berjalan.';
  }
  return 'Terjadi kesalahan. Silakan coba lagi.';
}
```

Tampilkan error via `SnackBar` — jangan expose stack trace ke user.

---

## 7. Models — Konvensi

- Field API `snake_case` → Dart property `camelCase` via `@JsonKey(name: 'nama_lengkap')`
- Decimal/uang dari API sebagai **String** → parse ke `double`/`Decimal` di model
- Timestamp ISO 8601 → `DateTime.parse()` (timezone WIT)

```dart
class User {
  final int id;
  final String username;
  final String role;
  final String namaLengkap;
  final String saldo;  // "125000.00" from API
  final int poin;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    username: json['username'] as String,
    role: json['role'] as String,
    namaLengkap: json['nama_lengkap'] as String,
    saldo: json['saldo']?.toString() ?? '0.00',
    poin: json['poin'] as int? ?? 0,
  );
}
```

---

## 8. Provider → Service Mapping

| Provider | Service Methods | Endpoint |
|----------|-----------------|----------|
| `AuthProvider` | login, register, logout, me | `/auth/*`, `/users/` |
| `HomeProvider` | loadDashboard | `/auth/me/`, `/waste-categories/` |
| `PenjemputanProvider` | list, create | `/pickups/` |
| `SaldoProvider` | riwayat, tarik | `/deposits/`, `/withdrawals/` |
| `RewardProvider` | katalog, tukar | `/rewards/`, `/reward-redemptions/` |
| `PengaduanProvider` | list, create | `/complaints/` |

---

## 9. Testing Integrasi

1. Backend: `python manage.py runserver 0.0.0.0:8000`
2. Seed: `python manage.py seed_data --flush`
3. Login demo: `nasabah001` / `nasabah123`
4. Swagger: http://localhost:8000/api/docs/
5. Panduan alur nasabah: http://localhost:8000/api/guide/

---

## 10. Batasan Mobile

- **Hanya role `nasabah`** boleh login
- **Tidak ada** write access ke deposits (setoran dilakukan petugas)
- **Tidak ada** endpoint admin/dashboard/reports
- **Online-first** — tidak perlu offline cache di MVP
