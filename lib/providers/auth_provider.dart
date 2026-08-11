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
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      throw ApiException(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Register
  // ──────────────────────────────────────────────

  /// Register a new nasabah account, then auto-login.
  Future<void> register({
    required String username,
    required String password,
    required String namaLengkap,
    required String noHp,
    required String alamat,
    String? nik,
    String rt = '',
    String rw = '',
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
        noHp: noHp,
        alamat: alamat,
        rt: rt,
        rw: rw,
        setujuKebijakanData: setujuKebijakanData,
      );

      // Auto-login after successful registration
      await login(username: username, password: password);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      _error = parseDioError(e);
      rethrow;
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      rethrow;
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
  Future<Map<String, dynamic>> requestPhoneOtp({String? noHp}) async {
    final user = _user;
    if (user == null) {
      throw const ApiException('Anda harus masuk terlebih dahulu.');
    }
    final phone = (noHp ?? user.noHp).trim();
    if (phone.isEmpty) {
      throw const ApiException('Nomor HP belum diisi. Hubungi admin MIRU.');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      return await authService.requestPhoneOtp(
        noHp: phone,
        username: user.username,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      _error = parseDioError(e);
      rethrow;
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verifikasi OTP; set `phone_verified=true` dan lepas gate OTP.
  Future<void> verifyPhoneOtp({
    required String otp,
    String? noHp,
  }) async {
    final user = _user;
    if (user == null) {
      throw const ApiException('Anda harus masuk terlebih dahulu.');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authService.verifyPhoneOtp(
        otp: otp.trim(),
        username: user.username,
        noHp: noHp ?? user.noHp,
      );

      // Refresh profil agar state lokal sinkron dengan server
      final userData = await authService.getMe();
      _user = User.fromJson(userData);
      authSession.setNeedsPhoneVerification(!_user!.phoneVerified);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      _error = parseDioError(e);
      rethrow;
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Forgot Password
  // ──────────────────────────────────────────────

  /// Request a password reset token.
  /// Returns the reset token on success, or null if username not found
  /// (server returns a safe generic message either way).
  Future<String?> forgotPassword({
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await authService.forgotPassword(
        username: username,
      );

      final resetToken = data['reset_token'] as String?;
      return resetToken;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      _error = parseDioError(e);
      rethrow;
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Reset Password
  // ──────────────────────────────────────────────

  /// Reset password using a reset token.
  /// Throws [ApiException] if token is invalid, expired, or password too short.
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      _error = parseDioError(e);
      rethrow;
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      rethrow;
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
