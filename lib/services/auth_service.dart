import '../providers/auth_session.dart';
import 'api_client.dart';
import 'storage_service.dart';

typedef JsonMap = Map<String, dynamic>;

class AuthService {
  AuthService({
    required this.apiClient,
    required this.storageService,
    required this.authSession,
  });

  final ApiClient apiClient;
  final StorageService storageService;
  final AuthSession authSession;

  Future<bool> hasToken() => storageService.hasAccessToken();

  Future<String?> getAccessToken() => storageService.readAccessToken();

  Future<String?> getRefreshToken() => storageService.readRefreshToken();

  Future<void> saveTokens(String access, String refresh) async {
    await storageService.writeTokens(access, refresh);
    authSession.setLoggedIn(true);
  }

  Future<JsonMap> login({
    required String username,
    required String password,
  }) async {
    final data = await apiClient.post<JsonMap>(
      '/auth/login/',
      data: {
        'username': username,
        'password': password,
      },
      fromJson: _asJsonMap,
    );

    await saveTokens(
      data['access'] as String,
      data['refresh'] as String,
    );

    return data;
  }

  Future<JsonMap> register({
    required String username,
    required String password,
    required String namaLengkap,
    required String noHp,
    required String alamat,
    bool setujuKebijakanData = true,
  }) async {
    return apiClient.post<JsonMap>(
      '/users/',
      data: {
        'username': username,
        'password': password,
        'nama_lengkap': namaLengkap,
        'no_hp': noHp,
        'alamat': alamat,
        'setuju_kebijakan_data': setujuKebijakanData,
      },
      fromJson: _asJsonMap,
    );
  }

  Future<JsonMap> getMe() {
    return apiClient.get<JsonMap>(
      '/auth/me/',
      fromJson: _asJsonMap,
    );
  }

  Future<void> logout() async {
    await storageService.clearTokens();
    authSession.setLoggedIn(false);
  }

  static JsonMap _asJsonMap(dynamic json) {
    return Map<String, dynamic>.from(json as Map);
  }
}
