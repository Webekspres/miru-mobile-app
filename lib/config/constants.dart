class AppConstants {
  static const String appName = 'MIRU';

  /// Base URL API (termasuk prefix `/api`).
  ///
  /// Default: Android emulator → `10.0.2.2` (alias localhost host machine).
  /// Device fisik: ganti via `--dart-define` saat run/build:
  /// `flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000/api`
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const Duration tokenExpiry = Duration(hours: 24);
}
