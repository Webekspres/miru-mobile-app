import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/jadwal_jemput.dart';
import '../models/pickup.dart';
import '../services/api_client.dart';

/// Provider for Penjemputan (Fase 3.4).
///
/// Handles:
/// - Fetching pickups from `/api/pickups/?nasabah={id}`
/// - Creating new pickups via `POST /api/pickups/`
/// - Jadwal jemput wilayah nasabah via `GET /api/jadwal-jemput/`
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

  /// Pengajuan ditolak aturan jadwal (H-1 lewat / wilayah nonaktif / sudah pesan).
  bool _submitRejectedByRule = false;
  int _currentUserId = 0;

  List<JadwalJemput> _jadwal = [];
  bool _isLoadingJadwal = false;
  bool _jadwalLoaded = false;
  String? _jadwalError;

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
  bool get submitRejectedByRule => _submitRejectedByRule;
  bool get hasError => _error != null;

  /// Jadwal jemput wilayah nasabah yang masih bisa dipesan (urut tanggal).
  List<JadwalJemput> get jadwal => _jadwal;
  bool get isLoadingJadwal => _isLoadingJadwal;
  bool get jadwalLoaded => _jadwalLoaded;
  String? get jadwalError => _jadwalError;

  // ──────────────────────────────────────────────
  // Jadwal jemput wilayah
  // ──────────────────────────────────────────────

  Future<void> loadJadwal() async {
    _isLoadingJadwal = true;
    _jadwalError = null;
    notifyListeners();
    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/jadwal-jemput/',
        fromJson: (json) => json as List<dynamic>,
      );
      _jadwal = JadwalJemput.listFromJson(
        data,
      ).where((j) => j.bisaDipesan).toList();
      _jadwalLoaded = true;
    } on DioException catch (e) {
      _jadwalError = parseDioError(e);
    } catch (_) {
      _jadwalError = kGenericErrorMessage;
    } finally {
      _isLoadingJadwal = false;
      notifyListeners();
    }
  }

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
        queryParameters: {'nasabah': userId.toString(), 'ordering': '-jadwal'},
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
    required int jadwalWilayahId,
    double? latitude,
    double? longitude,
  }) async {
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _error = null;
    _submitRejectedByRule = false;
    notifyListeners();

    try {
      final payload = <String, dynamic>{
        'estimasi_berat': estimasiBerat.toStringAsFixed(2),
        'alamat_jemput': alamatJemput,
        'jadwal_wilayah': jadwalWilayahId,
        if (latitude != null) 'latitude': latitude.toStringAsFixed(6),
        if (longitude != null) 'longitude': longitude.toStringAsFixed(6),
      };

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
      final fields = apiExceptionFromDio(e).fieldErrors?.keys ?? const [];
      _submitRejectedByRule = fields.contains('jadwal_wilayah');
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
    _jadwal = [];
    _jadwalLoaded = false;
    _jadwalError = null;
    _error = null;
    _currentUserId = 0;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }
}
