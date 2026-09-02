import 'package:flutter/foundation.dart';

import '../config/constants.dart';
import '../services/storage_service.dart';

/// Minimal auth state for go_router redirects.
/// AuthProvider (Fase 2) akan menggantikan/meng-extend ini.
class AuthSession extends ChangeNotifier {
  AuthSession(this._storage);

  final StorageService _storage;

  bool _isLoggedIn = false;
  bool _needsPhoneVerification = false;
  String? _sessionMessage;

  bool get isLoggedIn => _isLoggedIn;

  /// One-shot copy after forced logout (expired refresh). Null if none.
  String? consumeSessionMessage() {
    final message = _sessionMessage;
    _sessionMessage = null;
    return message;
  }

  /// True jika user login tapi `phone_verified=false` (harus ke layar OTP).
  bool get needsPhoneVerification => _needsPhoneVerification;

  Future<void> refresh() async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    final loggedIn = token != null && token.isNotEmpty;
    if (loggedIn != _isLoggedIn) {
      _isLoggedIn = loggedIn;
      if (!loggedIn) _needsPhoneVerification = false;
      notifyListeners();
    }
  }

  void setLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      if (!value) _needsPhoneVerification = false;
      notifyListeners();
    }
  }

  /// Force logged-out + notify so session-scoped caches always clear on logout.
  void clearSession() {
    _isLoggedIn = false;
    _needsPhoneVerification = false;
    notifyListeners();
  }

  /// Refresh failed: drop the session and queue a Bahasa Indonesia snackbar.
  void markSessionExpired() {
    _sessionMessage =
        'Sesi Anda telah berakhir. Silakan masuk kembali.';
    clearSession();
  }

  void setNeedsPhoneVerification(bool value) {
    if (_needsPhoneVerification != value) {
      _needsPhoneVerification = value;
      notifyListeners();
    }
  }
}
