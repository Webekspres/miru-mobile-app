import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/institution_settings.dart';
import '../services/api_client.dart';

/// Provider for institution settings (Fase 5.1).
///
/// Fetches `GET /api/settings/` — nama institusi, kontak, jam operasional.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────

  InstitutionSettings? _settings;
  bool _isLoading = false;
  String? _error;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  InstitutionSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // ──────────────────────────────────────────────
  // Load Settings — selalu fetch fresh dari server
  // ──────────────────────────────────────────────

  Future<void> loadSettings({bool silent = false}) async {
    final showLoading = !silent && _settings == null;
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final data = await _apiClient.get<Map<String, dynamic>>(
        '/settings/',
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      _settings = InstitutionSettings.fromJson(data);
      _error = null;
    } on DioException catch (e) {
      if (_settings == null) {
        _error = parseDioError(e);
      }
    } catch (e) {
      if (_settings == null) {
        _error = 'Terjadi kesalahan. Silakan coba lagi.';
      }
    }

    if (_isLoading) _isLoading = false;
    notifyListeners();
  }

  /// Force-refresh without blanking previous settings.
  Future<void> refresh() => loadSettings(silent: _settings != null);

  // ──────────────────────────────────────────────
  // Clear cache (panggil saat logout)
  // ──────────────────────────────────────────────

  void clearCache() {
    _settings = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
