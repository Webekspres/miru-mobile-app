import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/announcement.dart';
import '../models/api_exception.dart';
import '../services/api_client.dart';

/// Provider for announcements/pengumuman (Fase 5.2).
///
/// Fetches `GET /api/pengumuman/` — list pengumuman aktif.
class PengumumanProvider extends ChangeNotifier {
  PengumumanProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────

  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _error;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // ──────────────────────────────────────────────
  // Load Pengumuman
  // ──────────────────────────────────────────────

  Future<void> loadPengumuman() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/pengumuman/',
        fromJson: (json) => json as List<dynamic>,
      );
      _announcements = Announcement.listFromJson(data);
    } on DioException catch (e) {
      _error = parseDioError(e);
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    _error = null;
    notifyListeners();

    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/pengumuman/',
        fromJson: (json) => json as List<dynamic>,
      );
      _announcements = Announcement.listFromJson(data);
    } on DioException catch (e) {
      _error = parseDioError(e);
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
    }

    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // Clear cache (panggil saat logout)
  // ──────────────────────────────────────────────

  void clearCache() {
    _announcements = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
