import 'package:flutter/foundation.dart';

import '../config/constants.dart';
import '../services/storage_service.dart';

/// Minimal auth state for go_router redirects.
/// AuthProvider (Fase 2) akan menggantikan/meng-extend ini.
class AuthSession extends ChangeNotifier {
  AuthSession(this._storage);

  final StorageService _storage;

  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> refresh() async {
    final token = await _storage.read(AppConstants.accessTokenKey);
    final loggedIn = token != null && token.isNotEmpty;
    if (loggedIn != _isLoggedIn) {
      _isLoggedIn = loggedIn;
      notifyListeners();
    }
  }

  void setLoggedIn(bool value) {
    if (_isLoggedIn != value) {
      _isLoggedIn = value;
      notifyListeners();
    }
  }
}
