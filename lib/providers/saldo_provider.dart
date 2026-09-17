import 'dart:io';

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
  bool _hasLoaded = false;
  int _generation = 0;
  Future<void>? _inFlight;

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

  Future<void> ensureLoaded({required int userId}) {
    if (_hasLoaded && _currentUserId == userId) return Future.value();
    return loadActivity(userId: userId);
  }

  Future<void> loadActivity({required int userId}) {
    _currentUserId = userId;
    return _inFlight ??= _fetchActivity();
  }

  Future<void> _fetchActivity() async {
    final gen = _generation;
    final showLoading = _items.isEmpty;
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else if (_error != null) {
      _error = null;
      notifyListeners();
    }

    try {
      await _fetchFromActivity();
      if (gen != _generation) return;
      _error = null;
      _hasLoaded = true;
    } on DioException {
      if (gen != _generation) return;
      await _fetchFromIndividualEndpoints();
      if (gen != _generation) return;
      _hasLoaded = true;
    } catch (_) {
      if (gen != _generation) return;
      if (_items.isEmpty) {
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

  Future<void> _fetchFromActivity() async {
    final data = await _apiClient.get<List<dynamic>>(
      '/activity/',
      queryParameters: {
        'nasabah': _currentUserId.toString(),
        'page_size': '50',
      },
      fromJson: (json) => json as List<dynamic>,
    );

    _items = ActivityItem.listFromJson(data);
  }

  Future<void> _fetchFromIndividualEndpoints() async {
    // Build into a temp list so soft-refresh does not blank the UI mid-fetch.
    final next = <ActivityItem>[];

    try {
      // Fetch deposits
      final depositData = await _apiClient.get<List<dynamic>>(
        '/deposits/',
        queryParameters: {
          'nasabah': _currentUserId.toString(),
          'page_size': '20',
          'ordering': '-tanggal',
        },
        fromJson: (json) => json as List<dynamic>,
      );
      for (final d in depositData) {
        final map = Map<String, dynamic>.from(d as Map);
        map['type'] = 'setoran';
        map['keterangan'] ??= 'Setoran sampah';
        map['nominal'] ??= map['total_nilai']?.toString();
        map['poin'] ??= map['poin_didapat'];
        next.add(ActivityItem.fromJson(map));
      }
    } catch (_) {
      // Non-critical
    }

    try {
      // Fetch withdrawals
      final wdData = await _apiClient.get<List<dynamic>>(
        '/withdrawals/',
        queryParameters: {
          'nasabah': _currentUserId.toString(),
          'page_size': '20',
          'ordering': '-tanggal',
        },
        fromJson: (json) => json as List<dynamic>,
      );
      for (final w in wdData) {
        next.add(ActivityItem(
          id: w['id'] as int,
          type: ActivityType.penarikan,
          status: w['status'] as String? ?? 'menunggu',
          keterangan: 'Penarikan saldo',
          tanggal: DateTime.parse(w['tanggal'] as String),
          nominal: w['nominal']?.toString(),
        ));
      }
    } catch (_) {
      // Non-critical
    }

    try {
      // Fetch reward redemptions
      final rrData = await _apiClient.get<List<dynamic>>(
        '/reward-redemptions/',
        queryParameters: {
          'nasabah': _currentUserId.toString(),
          'page_size': '20',
          'ordering': '-tanggal',
        },
        fromJson: (json) => json as List<dynamic>,
      );
      for (final r in rrData) {
        next.add(ActivityItem(
          id: r['id'] as int,
          type: ActivityType.penukaranPoin,
          status: r['status'] as String? ?? 'menunggu',
          keterangan: 'Tukar ${r['reward_nama'] ?? 'poin'}',
          tanggal: DateTime.parse(r['tanggal'] as String),
          poin: r['poin_dibutuhkan'] as int?,
        ));
      }
    } catch (_) {
      // Non-critical
    }

    // Sort by date descending; only replace if we got something, else keep cache.
    next.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    if (next.isNotEmpty || _items.isEmpty) {
      _items = next;
    }
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
  Map<String, dynamic>? _submitFieldErrors;

  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  bool get hasSubmitError => _submitError != null;
  Map<String, dynamic>? get submitFieldErrors => _submitFieldErrors;

  /// Creates a new withdrawal request.
  ///
  /// Returns the created [Withdrawal] on success, `null` on error.
  Future<Withdrawal?> createWithdrawal({
    required double nominal,
    required String metode,
    File? lampiranKtp,
  }) async {
    if (_isSubmitting) return null;
    _isSubmitting = true;
    _submitError = null;
    _submitFieldErrors = null;
    notifyListeners();

    try {
      final Map<String, dynamic> posted;
      if (lampiranKtp != null) {
        posted = await _apiClient.upload<Map<String, dynamic>>(
          '/withdrawals/',
          data: FormData.fromMap({
            'nominal': nominal,
            'metode': metode,
            'lampiran_ktp': await MultipartFile.fromFile(
              lampiranKtp.path,
              filename: 'lampiran_ktp.jpg',
            ),
          }),
          fromJson: (json) => Map<String, dynamic>.from(json as Map),
        );
      } else {
        posted = await _apiClient.post<Map<String, dynamic>>(
          '/withdrawals/',
          data: {
            'nominal': nominal,
            'metode': metode,
          },
          fromJson: (json) => Map<String, dynamic>.from(json as Map),
        );
      }

      final withdrawal = Withdrawal.fromJson(posted);

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
      final apiError =
          e.error is ApiException ? e.error as ApiException : apiExceptionFromDio(e);
      _submitError = apiError.message;
      _submitFieldErrors = apiError.fieldErrors;
      _isSubmitting = false;
      notifyListeners();
      return null;
    } catch (_) {
      _submitError = kGenericErrorMessage;
      _submitFieldErrors = null;
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
    if (_submitError != null || _submitFieldErrors != null) {
      _submitError = null;
      _submitFieldErrors = null;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Clear cache (panggil saat logout)
  // ──────────────────────────────────────────────

  void clearCache() {
    _generation++;
    _inFlight = null;
    _hasLoaded = false;
    _items = [];
    _error = null;
    _submitError = null;
    _submitFieldErrors = null;
    _activeFilter = null;
    _currentUserId = 0;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }
}
