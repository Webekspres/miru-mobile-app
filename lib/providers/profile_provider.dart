import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/user.dart';
import '../services/api_client.dart';

/// Provider for Profile screen (Fase 3.2).
///
/// Handles:
/// - Fetching user profile from `/api/auth/me/`
/// - Updating profile via `PATCH /api/users/{id}/`
class ProfileProvider extends ChangeNotifier {
  ProfileProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────

  User? _user;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  bool _isEditMode = false;
  int _generation = 0;
  Future<void>? _inFlight;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEditMode => _isEditMode;
  bool get isLoggedIn => _user != null;

  // ──────────────────────────────────────────────
  // Edit mode
  // ──────────────────────────────────────────────

  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    _error = null;
    notifyListeners();
  }

  void enableEditMode() {
    if (!_isEditMode) {
      _isEditMode = true;
      _error = null;
      notifyListeners();
    }
  }

  void disableEditMode() {
    if (_isEditMode) {
      _isEditMode = false;
      _error = null;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Fetch Profile
  // ──────────────────────────────────────────────

  /// Seed from login / home cache so the profile tab is never empty after
  /// re-login. Does not hit the network.
  void hydrateFrom(User user) {
    if (_user != null) return;
    _user = user;
    _error = null;
    notifyListeners();
  }

  /// Fetch only when this session has no profile yet. In-flight calls share
  /// one Future so IndexedStack / pull-to-refresh cannot double-hit `/auth/me/`.
  Future<void> ensureLoaded() {
    if (_user != null) return Future.value();
    return loadProfile();
  }

  Future<void> loadProfile() {
    return _inFlight ??= _fetch();
  }

  Future<void> _fetch() async {
    final gen = _generation;
    final showLoading = _user == null;
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else if (_error != null) {
      _error = null;
      notifyListeners();
    }

    try {
      final userData = await _apiClient.get<Map<String, dynamic>>(
        '/auth/me/',
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      if (gen != _generation) return;
      _user = User.fromJson(userData);
      _error = null;
    } on DioException catch (e) {
      if (gen != _generation) return;
      if (_user == null) {
        _error = parseDioError(e);
      }
    } catch (_) {
      if (gen != _generation) return;
      if (_user == null) {
        _error = kGenericErrorMessage;
      }
    } finally {
      if (gen == _generation) {
        if (_isLoading) _isLoading = false;
        _inFlight = null;
        notifyListeners();
      }
    }
  }

  // ──────────────────────────────────────────────
  // Update Profile
  // ──────────────────────────────────────────────

  /// Updates profile fields: nama_lengkap, no_hp, alamat, rt, rw.
  ///
  /// Other fields like saldo, poin, role are NOT sent to the API.
  /// Returns `true` on success, `false` on error.
  Future<bool> updateProfile({
    required String namaLengkap,
    required String noHp,
    required String alamat,
    String rt = '',
    String rw = '',
    int? kelurahanId,
    double? latitude,
    double? longitude,
  }) async {
    if (_user == null) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{
        'nama_lengkap': namaLengkap,
        'no_hp': noHp,
        'alamat': alamat,
      };
      if (rt.isNotEmpty) body['rt'] = rt;
      if (rw.isNotEmpty) body['rw'] = rw;
      if (kelurahanId != null) body['kelurahan'] = kelurahanId;
      // Kolom koordinat backend: maks 6 desimal.
      if (latitude != null) body['latitude'] = latitude.toStringAsFixed(6);
      if (longitude != null) body['longitude'] = longitude.toStringAsFixed(6);

      final updatedData = await _apiClient.patch<Map<String, dynamic>>(
        '/users/${_user!.id}/',
        data: body,
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );

      _user = User.fromJson(updatedData);
      _isEditMode = false;
      _isSaving = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = parseDioError(e);
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAvatar(File file) async {
    if (_user == null) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: 'avatar.jpg',
        ),
        'purpose': 'avatar',
      });
      final uploaded = await _apiClient.upload<Map<String, dynamic>>(
        '/media/uploads/',
        data: form,
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      final updatedData = await _apiClient.patch<Map<String, dynamic>>(
        '/auth/me/',
        data: {'avatar_url': uploaded['url']},
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      _user = User.fromJson(updatedData);
      _isSaving = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _error = parseDioError(e);
      _isSaving = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
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
  // Clear cache (panggil saat logout)
  // ──────────────────────────────────────────────

  void clearCache() {
    _generation++;
    _inFlight = null;
    _user = null;
    _error = null;
    _isEditMode = false;
    _isLoading = false;
    _isSaving = false;
    notifyListeners();
  }
}
