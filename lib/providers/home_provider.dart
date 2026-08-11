import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/deposit.dart';
import '../models/user.dart';
import '../models/waste_category.dart';
import '../services/api_client.dart';

/// Provider for the HomeScreen / Dashboard (Fase 3.1).
///
/// Fetches:
/// - User profile (saldo, poin) from `/api/auth/me/`
/// - Waste categories from `/api/waste-categories/`
/// - Recent deposits from `/api/deposits/?nasabah={id}&page_size=3`
///
/// Uses SWR-like caching: previous data stays visible while refreshing;
/// skeleton/`isLoading` only on cold load (no cached user yet).
class HomeProvider extends ChangeNotifier {
  HomeProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────

  User? _user;
  bool _isLoading = false;
  String? _error;
  List<WasteCategory> _categories = [];
  List<Deposit> _recentDeposits = [];
  int _fetchGeneration = 0;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  User? get user => _user;
  double get saldo => _user?.saldoAsDouble ?? 0.0;
  int get poin => _user?.poin ?? 0;
  String get namaLengkap => _user?.namaLengkap ?? '';
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get hasData => _user != null;
  List<WasteCategory> get categories => _categories;
  List<Deposit> get recentDeposits => _recentDeposits;

  /// Top 3–4 categories to show on the dashboard.
  List<WasteCategory> get topCategories {
    // Show top 4 categories by price (highest first)
    final sorted = List<WasteCategory>.from(_categories)
      ..sort((a, b) => b.hargaBeliPerKgAsDouble.compareTo(a.hargaBeliPerKgAsDouble));
    return sorted.take(4).toList();
  }

  // ──────────────────────────────────────────────
  // Load Dashboard Data
  // ──────────────────────────────────────────────

  /// Initial load — shows skeleton only when there is no cached user yet.
  Future<void> loadData() => _fetchDashboard(showLoading: !_hasCachedUser);

  /// Pull-to-refresh / post-mutate — keeps previous data visible.
  Future<void> refresh() => _fetchDashboard(showLoading: false);

  bool get _hasCachedUser => _user != null;

  Future<void> _fetchDashboard({required bool showLoading}) async {
    final gen = ++_fetchGeneration;

    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else if (_error != null) {
      _error = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _apiClient.get<Map<String, dynamic>>(
          '/auth/me/',
          fromJson: (json) => Map<String, dynamic>.from(json as Map),
        ),
        _apiClient.get<List<dynamic>>(
          '/waste-categories/',
          fromJson: (json) => json as List<dynamic>,
        ),
      ]);

      if (gen != _fetchGeneration) return;

      // Parse user
      final userData = results[0] as Map<String, dynamic>;
      _user = User.fromJson(userData);

      // Parse waste categories
      final catData = results[1] as List<dynamic>;
      _categories = WasteCategory.listFromJson(catData);

      // Fetch recent deposits (only if user is loaded)
      if (_user != null) {
        await _fetchRecentDeposits(gen);
      }
      _error = null;
    } on DioException catch (e) {
      if (gen != _fetchGeneration) return;
      // Keep previous data on refresh failure; only surface error on cold load.
      if (!_hasCachedUser) {
        _error = parseDioError(e);
      }
    } catch (_) {
      if (gen != _fetchGeneration) return;
      if (!_hasCachedUser) {
        _error = 'Terjadi kesalahan. Silakan coba lagi.';
      }
    } finally {
      if (gen == _fetchGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _fetchRecentDeposits(int gen) async {
    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/deposits/',
        queryParameters: {
          'nasabah': _user!.id.toString(),
          'page_size': '3',
          'ordering': '-tanggal',
        },
        fromJson: (json) => json as List<dynamic>,
      );

      if (gen != _fetchGeneration) return;
      _recentDeposits = Deposit.listFromJson(data);
    } catch (_) {
      // Deposits fetch is non-critical; keep previous data
    }
  }

  // ──────────────────────────────────────────────
  // Load Categories Only (public, no auth required)
  // ──────────────────────────────────────────────

  /// Fetches ONLY waste categories (public endpoint).
  /// No auth required — used by InfoSampahScreen for unauthenticated users.
  Future<void> loadCategoriesOnly() async {
    final gen = ++_fetchGeneration;
    final showLoading = _categories.isEmpty;

    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final catData = await _apiClient.get<List<dynamic>>(
        '/waste-categories/',
        fromJson: (json) => json as List<dynamic>,
      );
      if (gen != _fetchGeneration) return;
      _categories = WasteCategory.listFromJson(catData);
      _error = null;
    } on DioException catch (e) {
      if (gen != _fetchGeneration) return;
      if (_categories.isEmpty) {
        _error = parseDioError(e);
      }
    } catch (_) {
      if (gen != _fetchGeneration) return;
      if (_categories.isEmpty) {
        _error = 'Terjadi kesalahan. Silakan coba lagi.';
      }
    } finally {
      if (gen == _fetchGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // ──────────────────────────────────────────────
  // Clear cache (panggil saat logout)
  // ──────────────────────────────────────────────

  void clearCache() {
    _fetchGeneration++;
    _user = null;
    _categories = [];
    _recentDeposits = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
