import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'auth_session.dart';

/// Main auth state for the mobile app.
/// Handles login, register, logout, and session restoration.
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this.authService,
    required this.storageService,
    required this.authSession,
  });

  final AuthService authService;
  final StorageService storageService;
  final AuthSession authSession;



  User? _user;
  bool _isLoading = false;
  String? _error;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isNasabah => _user?.isNasabah ?? false;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Akun belum verifikasi nomor HP (OTP WhatsApp).
  bool get needsPhoneVerification =>
      _user != null && !_user!.phoneVerified;

  double get saldo => _user?.saldoAsDouble ?? 0.0;
  int get poin => _user?.poin ?? 0;

  // ──────────────────────────────────────────────
  // Login
  // ──────────────────────────────────────────────

  /// Login with username + password.
  /// Throws [ApiException] if role is not nasabah.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await authService.login(
        username: username,
        password: password,
      );

      final userData = data['user'];
      if (userData is! Map<String, dynamic>) {
        throw const ApiException('Format data user tidak valid.');
      }

      final user = User.fromJson(userData);

      if (!user.isNasabah) {
        // Reject non-nasabah immediately
        await authService.logout();
        throw const ApiException(
          'Akun petugas/admin hanya dapat login melalui Web Admin MIRU.',
        );
      }

      _user = user;
      authSession.setLoggedIn(true);
      authSession.setNeedsPhoneVerification(!user.phoneVerified);
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } on DioException catch (e) {
      final apiError = apiExceptionFromDio(e);
      _error = apiError.message;
      throw apiError;
    } catch (e) {
      _error = kGenericErrorMessage;
      throw ApiException(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Register
  // ──────────────────────────────────────────────

  /// Daftar nasabah singkat. Akun belum aktif sampai OTP WhatsApp (langkah 2).
  /// Jangan auto-login — user inactive sampai verifikasi nomor.
  Future<void> register({
    required String username,
    required String password,
    required String namaLengkap,
    bool setujuKebijakanData = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authService.register(
        username: username,
        password: password,
        namaLengkap: namaLengkap,
        setujuKebijakanData: setujuKebijakanData,
      );
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } on DioException catch (e) {
      final apiError = apiExceptionFromDio(e);
      _error = apiError.message;
      throw apiError;
    } catch (e) {
      _error = kGenericErrorMessage;
      throw ApiException(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Check Auth Status (for SplashScreen)
  // ──────────────────────────────────────────────

  /// Check stored token and restore session.
  /// Returns `true` if session restored, `false` otherwise.
  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasToken = await storageService.hasAccessToken();
      if (!hasToken) {
        await _clearSession();
        return false;
      }

      final userData = await authService.getMe();
      final user = User.fromJson(userData);

      if (!user.isNasabah) {
        await authService.logout();
        await _clearSession();
        return false;
      }

      _user = user;
      authSession.setLoggedIn(true);
      authSession.setNeedsPhoneVerification(!user.phoneVerified);
      return true;
    } on DioException catch (e) {
      if (isTransientNetworkError(e) &&
          await storageService.hasAccessToken()) {
        authSession.setLoggedIn(true);
        return false;
      }
      await _clearSession();
      return false;
    } catch (_) {
      await _clearSession();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Phone OTP verification
  // ──────────────────────────────────────────────

  /// Request OTP WhatsApp untuk verifikasi nomor HP.
  /// Login (gate `/verify-phone`): username dari sesi.
  /// Registrasi langkah 2: kirim [username] + [noHp] tanpa login.
  Future<Map<String, dynamic>> requestPhoneOtp({
    String? noHp,
    String? username,
  }) async {
    final resolvedUsername = (username ?? _user?.username ?? '').trim();
    final phone = (noHp ?? _user?.noHp ?? '').trim();
    if (resolvedUsername.isEmpty) {
      throw const ApiException('Username wajib diisi.');
    }
    if (phone.isEmpty) {
      throw const ApiException('Nomor HP belum diisi.');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await authService.requestPhoneOtp(
        noHp: phone,
        username: resolvedUsername,
      );

      // Staging/testing: backend SKIP_PHONE_VERIFICATION auto-verifies on request.
      if (data['phone_verified'] == true && _user != null) {
        final userData = await authService.getMe();
        _user = User.fromJson(userData);
        authSession.setNeedsPhoneVerification(!_user!.phoneVerified);
      }

      return data;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } on DioException catch (e) {
      final apiError = apiExceptionFromDio(e);
      _error = apiError.message;
      throw apiError;
    } catch (e) {
      _error = kGenericErrorMessage;
      throw ApiException(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifikasi OTP HP. Setelah login: refresh profil. Saat daftar: tanpa sesi.
  Future<void> verifyPhoneOtp({
    required String otp,
    String? noHp,
    String? username,
  }) async {
    final resolvedUsername = (username ?? _user?.username ?? '').trim();
    if (resolvedUsername.isEmpty) {
      throw const ApiException('Username wajib diisi.');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authService.verifyPhoneOtp(
        otp: otp.trim(),
        username: resolvedUsername,
        noHp: noHp,
      );

      if (_user != null) {
        final userData = await authService.getMe();
        _user = User.fromJson(userData);
        authSession.setNeedsPhoneVerification(!_user!.phoneVerified);
      }
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } on DioException catch (e) {
      final apiError = apiExceptionFromDio(e);
      _error = apiError.message;
      throw apiError;
    } catch (e) {
      _error = kGenericErrorMessage;
      throw ApiException(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Forgot Password
  // ──────────────────────────────────────────────

  /// Langkah 1: username → data.masked_phone.
  Future<Map<String, dynamic>> forgotPassword({
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await authService.forgotPassword(username: username);
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } on DioException catch (e) {
      final apiError = apiExceptionFromDio(e);
      _error = apiError.message;
      throw apiError;
    } catch (e) {
      _error = kGenericErrorMessage;
      throw ApiException(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Langkah 2: no_hp harus cocok → kirim kode ke WhatsApp.
  Future<Map<String, dynamic>> requestResetPasswordOtp({
    required String username,
    required String noHp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await authService.requestResetPasswordOtp(
        username: username,
        noHp: noHp,
      );
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } on DioException catch (e) {
      final apiError = apiExceptionFromDio(e);
      _error = apiError.message;
      throw apiError;
    } catch (e) {
      _error = kGenericErrorMessage;
      throw ApiException(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Langkah 3: verifikasi kode → reset_token untuk `/reset-password`.
  Future<String> verifyResetPasswordOtp({
    required String username,
    required String otp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await authService.verifyResetPasswordOtp(
        username: username,
        otp: otp,
      );
      final token = data['reset_token'] as String?;
      if (token == null || token.isEmpty) {
        throw const ApiException('Kode tidak valid. Silakan coba lagi.');
      }
      return token;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } on DioException catch (e) {
      final apiError = apiExceptionFromDio(e);
      _error = apiError.message;
      throw apiError;
    } catch (e) {
      _error = kGenericErrorMessage;
      throw ApiException(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Reset Password
  // ──────────────────────────────────────────────

  /// Langkah 4: password + password_confirm (min 6).
  Future<void> resetPassword({
    required String token,
    required String password,
    required String passwordConfirm,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authService.resetPassword(
        token: token,
        password: password,
        passwordConfirm: passwordConfirm,
      );
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } on DioException catch (e) {
      final apiError = apiExceptionFromDio(e);
      _error = apiError.message;
      throw apiError;
    } catch (e) {
      _error = kGenericErrorMessage;
      throw ApiException(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Logout
  // ──────────────────────────────────────────────

  Future<void> logout() async {
    // Clears tokens + AuthSession → MiruApp clears all session-scoped provider caches.
    await authService.logout();
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // Clear error
  // ──────────────────────────────────────────────

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Internal helpers
  // ──────────────────────────────────────────────

  Future<void> _clearSession() async {
    _user = null;
    _error = null;
    await authService.logout();
  }
}
