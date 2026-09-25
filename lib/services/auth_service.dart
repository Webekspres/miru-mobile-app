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
    bool setujuKebijakanData = true,
  }) {
    return apiClient.post<JsonMap>(
      '/users/',
      data: {
        'username': username,
        'password': password,
        'nama_lengkap': namaLengkap,
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

  /// Langkah 1 lupa password: username → masked_phone.
  /// POST /auth/forgot-password/
  Future<JsonMap> forgotPassword({
    required String username,
  }) {
    return apiClient.post<JsonMap>(
      '/auth/forgot-password/',
      data: {
        'username': username,
      },
      fromJson: _asJsonMap,
    );
  }

  /// Langkah 2 lupa password: konfirmasi email → kirim OTP ke email.
  /// POST /auth/reset-password/request-otp/
  Future<JsonMap> requestResetPasswordOtp({
    required String username,
    required String email,
  }) {
    return apiClient.post<JsonMap>(
      '/auth/reset-password/request-otp/',
      data: {
        'username': username,
        'email': email,
      },
      fromJson: _asJsonMap,
    );
  }

  /// Langkah 3 lupa password: verifikasi OTP → reset_token.
  /// POST /auth/reset-password/verify-otp/
  Future<JsonMap> verifyResetPasswordOtp({
    required String username,
    required String otp,
  }) {
    return apiClient.post<JsonMap>(
      '/auth/reset-password/verify-otp/',
      data: {
        'username': username,
        'otp': otp,
      },
      fromJson: _asJsonMap,
    );
  }

  /// Langkah 4 lupa password: password baru.
  /// POST /auth/reset-password/  {token, password, password_confirm}
  Future<JsonMap> resetPassword({
    required String token,
    required String password,
    required String passwordConfirm,
  }) {
    return apiClient.post<JsonMap>(
      '/auth/reset-password/',
      data: {
        'token': token,
        'password': password,
        'password_confirm': passwordConfirm,
      },
      fromJson: _asJsonMap,
    );
  }

  /// Kirim OTP verifikasi ke email.
  /// Login: cukup [email]. Registrasi (akun belum aktif): + [username] & [password].
  /// POST /auth/email/request-otp/
  Future<JsonMap> requestEmailOtp({
    required String email,
    String? username,
    String? password,
  }) {
    return apiClient.post<JsonMap>(
      '/auth/email/request-otp/',
      data: {
        'email': email,
        if (username != null && username.isNotEmpty) 'username': username,
        if (password != null && password.isNotEmpty) 'password': password,
      },
      fromJson: _asJsonMap,
    );
  }

  /// Verifikasi OTP email. Login: `data.user` berisi payload user terbaru.
  /// POST /auth/email/verify-otp/
  Future<JsonMap> verifyEmailOtp({
    required String otp,
    String? username,
  }) {
    return apiClient.post<JsonMap>(
      '/auth/email/verify-otp/',
      data: {
        'otp': otp,
        if (username != null && username.isNotEmpty) 'username': username,
      },
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
