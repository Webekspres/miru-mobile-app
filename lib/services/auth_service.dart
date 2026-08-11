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
    String rt = '',
    String rw = '',
    bool setujuKebijakanData = true,
  }) async {
    final data = <String, dynamic>{
      'username': username,
      'password': password,
      'nama_lengkap': namaLengkap,
      'no_hp': noHp,
      'alamat': alamat,
      'setuju_kebijakan_data': setujuKebijakanData,
    };
    if (rt.isNotEmpty) data['rt'] = rt;
    if (rw.isNotEmpty) data['rw'] = rw;

    return apiClient.post<JsonMap>(
      '/users/',
      data: data,
      fromJson: _asJsonMap,
    );
  }

  Future<JsonMap> getMe() {
    return apiClient.get<JsonMap>(
      '/auth/me/',
      fromJson: _asJsonMap,
    );
  }

  /// Request a password reset token.
  /// POST /auth/forgot-password/
  Future<JsonMap> forgotPassword({
    required String username,
  }) async {
    return apiClient.post<JsonMap>(
      '/auth/forgot-password/',
      data: {
        'username': username,
      },
      fromJson: _asJsonMap,
    );
  }

  /// Reset password using a reset token.
  /// POST /auth/reset-password/
  Future<JsonMap> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return apiClient.post<JsonMap>(
      '/auth/reset-password/',
      data: {
        'token': token,
        'new_password': newPassword,
      },
      fromJson: _asJsonMap,
    );
  }

  /// Request OTP WhatsApp for phone verification.
  /// POST /auth/phone/request-otp/
  Future<JsonMap> requestPhoneOtp({
    required String noHp,
    String? username,
  }) async {
    final data = <String, dynamic>{'no_hp': noHp};
    if (username != null && username.isNotEmpty) {
      data['username'] = username;
    }
    return apiClient.post<JsonMap>(
      '/auth/phone/request-otp/',
      data: data,
      fromJson: _asJsonMap,
    );
  }

  /// Verify phone OTP.
  /// POST /auth/phone/verify-otp/
  Future<JsonMap> verifyPhoneOtp({
    required String otp,
    String? username,
    String? noHp,
  }) async {
    final data = <String, dynamic>{'otp': otp};
    if (username != null && username.isNotEmpty) {
      data['username'] = username;
    }
    if (noHp != null && noHp.isNotEmpty) {
      data['no_hp'] = noHp;
    }
    return apiClient.post<JsonMap>(
      '/auth/phone/verify-otp/',
      data: data,
      fromJson: _asJsonMap,
    );
  }

  Future<void> logout() async {
    await storageService.clearTokens();
    // Always notify so MiruApp clears provider caches even if flag was already false.
    authSession.clearSession();
  }

  static JsonMap _asJsonMap(dynamic json) {
    return Map<String, dynamic>.from(json as Map);
  }
}
