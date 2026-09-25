import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/constants.dart';

class StorageService {
  StorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();

  Future<String?> readAccessToken() => read(AppConstants.accessTokenKey);

  Future<String?> readRefreshToken() => read(AppConstants.refreshTokenKey);

  Future<bool> hasAccessToken() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> writeAccessToken(String access) =>
      write(AppConstants.accessTokenKey, access);

  Future<void> writeTokens(String access, String refresh) async {
    await write(AppConstants.accessTokenKey, access);
    await write(AppConstants.refreshTokenKey, refresh);
  }

  Future<void> clearTokens() async {
    await delete(AppConstants.accessTokenKey);
    await delete(AppConstants.refreshTokenKey);
  }
}
