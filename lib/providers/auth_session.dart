import 'package:flutter/foundation.dart';

import '../config/constants.dart';
import '../services/storage_service.dart';

/// Minimal auth state for go_router redirects.
/// AuthProvider (Fase 2) akan menggantikan/meng-extend ini.
class AuthSession extends ChangeNotifier {
  AuthSession(this._storage);

  final StorageService _storage;

  bool _isLoggedIn = false;
  bool _needsEmailVerification = false;
  String? _sessionMessage;

  bool get isLoggedIn => _isLoggedIn;

  /// One-shot copy after forced logout (expired refresh). Null if none.
  String? consumeSessionMessage() {
    final message = _sessionMessage;
    _sessionMessage = null;
    return message;
  }

  /// True jika user login tapi `email_required=true` (harus ke layar verifikasi email).
  bool get needsEmailVerification => _needsEmailVerification;

  Future<void> refresh() async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    final loggedIn = token != null && token.isNotEmpty;
    if (loggedIn != _isLoggedIn) {
      _isLoggedIn = loggedIn;
      if (!loggedIn) _needsEmailVerification = false;
      notifyListeners();
    }
  }

  void setLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      if (!value) _needsEmailVerification = false;
      notifyListeners();
    }
  }

  /// Force logged-out + notify so session-scoped caches always clear on logout.
  void clearSession() {
    _isLoggedIn = false;
    _needsEmailVerification = false;
    notifyListeners();
  }

  /// Refresh failed: drop the session and queue a Bahasa Indonesia snackbar.
  void markSessionExpired() {
    _sessionMessage =
        'Sesi Anda telah berakhir. Silakan masuk kembali.';
    clearSession();
  }

  void setNeedsEmailVerification(bool value) {
    if (_needsEmailVerification != value) {
      _needsEmailVerification = value;
      notifyListeners();
    }
  }
}
