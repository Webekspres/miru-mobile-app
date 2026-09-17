import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/pickup.dart';
import '../services/api_client.dart';

/// Provider for Penjemputan (Fase 3.4).
///
/// Handles:
/// - Fetching pickups from `/api/pickups/?nasabah={id}`
/// - Creating new pickups via `POST /api/pickups/`
class PenjemputanProvider extends ChangeNotifier {
  PenjemputanProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────

  List<Pickup> _pickups = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  int _currentUserId = 0;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  List<Pickup> get pickups => _pickups;

  /// Active pickups (menunggu, disetujui, dijadwalkan, dalam_perjalanan, dijemput).
  List<Pickup> get activePickups =>
      _pickups.where((p) => p.status.isActive).toList();

  /// Historical pickups (selesai, ditolak).
  List<Pickup> get historyPickups =>
      _pickups.where((p) => !p.status.isActive).toList();

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  bool get hasError => _error != null;

  // ──────────────────────────────────────────────
  // Load Pickups
  // ──────────────────────────────────────────────

  Future<void> loadPickups({required int userId}) async {
    _currentUserId = userId;
    final showLoading = _pickups.isEmpty;
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else if (_error != null) {
      _error = null;
      notifyListeners();
    }

    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/pickups/',
        queryParameters: {
          'nasabah': userId.toString(),
          'ordering': '-jadwal',
        },
        fromJson: (json) => json as List<dynamic>,
      );

      _pickups = Pickup.listFromJson(data);
      _error = null;
    } on DioException catch (e) {
      if (_pickups.isEmpty) {
        _error = parseDioError(e);
      }
    } catch (_) {
      if (_pickups.isEmpty) {
        _error = kGenericErrorMessage;
      }
    } finally {
      if (_isLoading) _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh.
  Future<void> refresh() async {
    if (_currentUserId == 0) return;
    await loadPickups(userId: _currentUserId);
  }

  // ──────────────────────────────────────────────
  // Create Pickup
  // ──────────────────────────────────────────────

  /// Creates a new pickup request.
  ///
  /// Returns the created [Pickup] on success, `null` on error.
  Future<Pickup?> createPickup({
    required double estimasiBerat,
    required String alamatJemput,
    required DateTime jadwal,
    double? latitude,
    double? longitude,
  }) async {
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final payload = Pickup(
        id: 0,
        nasabah: 0,
        estimasiBerat: estimasiBerat.toStringAsFixed(2),
        alamatJemput: alamatJemput,
        jadwal: jadwal,
        status: PickupStatus.menunggu,
        latitude: latitude,
        longitude: longitude,
      ).toCreateJson();

      final data = await _apiClient.post<Map<String, dynamic>>(
        '/pickups/',
        data: payload,
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );

      final pickup = Pickup.fromJson(data);
      _pickups.insert(0, pickup);
      _isSubmitting = false;
      notifyListeners();
      return pickup;
    } on DioException catch (e) {
      _error = parseDioError(e);
      _isSubmitting = false;
      notifyListeners();
      return null;
    } catch (_) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      _isSubmitting = false;
      notifyListeners();
      return null;
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
    _pickups = [];
    _error = null;
    _currentUserId = 0;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }
}
