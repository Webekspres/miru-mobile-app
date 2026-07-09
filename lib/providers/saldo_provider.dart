import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/activity_item.dart';
import '../models/api_exception.dart';
import '../models/withdrawal.dart';
import '../services/api_client.dart';

/// Provider for Riwayat Transaksi (Fase 3.5).
///
/// Fetches unified activity feed from `/api/activity/` with optional type filter.
/// Falls back to individual endpoints if activity endpoint fails.
class SaldoProvider extends ChangeNotifier {
  SaldoProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────

  List<ActivityItem> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _activeFilter; // null = Semua, 'setoran', 'penarikan', 'poin'
  int _currentUserId = 0;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  List<ActivityItem> get items => _items;

  /// Filtered items based on active filter tab.
  List<ActivityItem> get filteredItems {
    if (_activeFilter == null) return _items;
    return _items.where((item) => item.type.jenisFilter == _activeFilter).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  String? get activeFilter => _activeFilter;

  // ──────────────────────────────────────────────
  // Filter
  // ──────────────────────────────────────────────

  void setFilter(String? filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // Load Activity
  // ──────────────────────────────────────────────

  Future<void> loadActivity({required int userId}) async {
    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try unified activity endpoint first
      await _fetchFromActivity();
    } on DioException {
      // Fallback: fetch from individual endpoints
      await _fetchFromIndividualEndpoints();
    } catch (_) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchFromActivity() async {
    final data = await _apiClient.get<Map<String, dynamic>>(
      '/activity/',
      queryParameters: {
        'nasabah': _currentUserId.toString(),
        'page_size': '50',
      },
      fromJson: (json) => Map<String, dynamic>.from(json as Map),
    );

    final results = data['results'];
    if (results is List) {
      _items = ActivityItem.listFromJson(results);
    } else {
      _items = [];
    }
  }

  Future<void> _fetchFromIndividualEndpoints() async {
    _items = [];

    try {
      // Fetch deposits
      final depositData = await _apiClient.get<Map<String, dynamic>>(
        '/deposits/',
        queryParameters: {
          'nasabah': _currentUserId.toString(),
          'page_size': '20',
          'ordering': '-tanggal',
        },
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      final depositResults = depositData['results'];
      if (depositResults is List) {
        for (final d in depositResults) {
          _items.add(ActivityItem(
            id: d['id'] as int,
            type: ActivityType.setoran,
            status: d['status'] as String? ?? 'selesai',
            keterangan: 'Setoran sampah',
            tanggal: DateTime.parse(d['tanggal'] as String),
            nominal: d['total_nilai']?.toString(),
            poin: d['poin_didapat'] as int?,
          ));
        }
      }
    } catch (_) {
      // Non-critical
    }

    try {
      // Fetch withdrawals
      final wdData = await _apiClient.get<Map<String, dynamic>>(
        '/withdrawals/',
        queryParameters: {
          'nasabah': _currentUserId.toString(),
          'page_size': '20',
          'ordering': '-tanggal',
        },
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      final wdResults = wdData['results'];
      if (wdResults is List) {
        for (final w in wdResults) {
          _items.add(ActivityItem(
            id: w['id'] as int,
            type: ActivityType.penarikan,
            status: w['status'] as String? ?? 'menunggu',
            keterangan: 'Penarikan saldo',
            tanggal: DateTime.parse(w['tanggal'] as String),
            nominal: w['nominal']?.toString(),
          ));
        }
      }
    } catch (_) {
      // Non-critical
    }

    try {
      // Fetch reward redemptions
      final rrData = await _apiClient.get<Map<String, dynamic>>(
        '/reward-redemptions/',
        queryParameters: {
          'nasabah': _currentUserId.toString(),
          'page_size': '20',
          'ordering': '-tanggal',
        },
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
      final rrResults = rrData['results'];
      if (rrResults is List) {
        for (final r in rrResults) {
          _items.add(ActivityItem(
            id: r['id'] as int,
            type: ActivityType.penukaranPoin,
            status: r['status'] as String? ?? 'menunggu',
            keterangan: 'Tukar ${r['reward_nama'] ?? 'poin'}',
            tanggal: DateTime.parse(r['tanggal'] as String),
            poin: r['poin_dibutuhkan'] as int?,
          ));
        }
      }
    } catch (_) {
      // Non-critical
    }

    // Sort by date descending
    _items.sort((a, b) => b.tanggal.compareTo(a.tanggal));
  }

  /// Pull-to-refresh.
  Future<void> refresh() async {
    if (_currentUserId == 0) return;
    await loadActivity(userId: _currentUserId);
  }

  // ──────────────────────────────────────────────
  // Create Withdrawal (Tarik Saldo — Fase 3.6)
  // ──────────────────────────────────────────────

  /// Status and error for withdrawal submission.
  bool _isSubmitting = false;
  String? _submitError;

  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  bool get hasSubmitError => _submitError != null;

  /// Creates a new withdrawal request.
  ///
  /// Returns the created [Withdrawal] on success, `null` on error.
  Future<Withdrawal?> createWithdrawal({
    required double nominal,
    required String metode,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final data = await _apiClient.post<Map<String, dynamic>>(
        '/withdrawals/',
        data: {
          'nominal': nominal,
          'metode': metode,
        },
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );

      final withdrawal = Withdrawal.fromJson(data);

      // Add to local items list so it shows in riwayat immediately
      _items.insert(
        0,
        ActivityItem(
          id: withdrawal.id,
          type: ActivityType.penarikan,
          status: withdrawal.status.apiValue,
          keterangan: 'Penarikan saldo',
          tanggal: withdrawal.tanggal,
          nominal: withdrawal.nominal,
        ),
      );

      _isSubmitting = false;
      notifyListeners();
      return withdrawal;
    } on DioException catch (e) {
      _submitError = parseDioError(e);
      _isSubmitting = false;
      notifyListeners();
      return null;
    } catch (_) {
      _submitError = 'Terjadi kesalahan. Silakan coba lagi.';
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

  void clearSubmitError() {
    if (_submitError != null) {
      _submitError = null;
      notifyListeners();
    }
  }
}
