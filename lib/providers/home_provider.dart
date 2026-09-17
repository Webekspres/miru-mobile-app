import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/activity_item.dart';
import '../models/json_parsing.dart';
import '../models/user.dart';
import '../models/waste_category.dart';
import '../services/api_client.dart';

/// Provider for the HomeScreen / Dashboard (Fase 3.1).
///
/// Fetches:
/// - User profile (saldo, poin) from `/api/auth/me/`
/// - Waste categories from `/api/waste-categories/`
/// - Recent mixed activity from `/api/activity/?nasabah={id}&page_size=3`
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
  List<ActivityItem> _recentActivity = [];
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
  List<ActivityItem> get recentActivity => _recentActivity;

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

      // Fetch recent mixed activity (setoran, penarikan, penukaran poin)
      if (_user != null) {
        await _fetchRecentActivity(gen);
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
        _error = kGenericErrorMessage;
      }
    } finally {
      if (gen == _fetchGeneration) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _fetchRecentActivity(int gen) async {
    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/activity/',
        queryParameters: {
          'nasabah': _user!.id.toString(),
          'page_size': '3',
          'ordering': '-tanggal',
        },
        fromJson: (json) => json as List<dynamic>,
      );

      if (gen != _fetchGeneration) return;
      _recentActivity = ActivityItem.listFromJson(data);
    } catch (_) {
      // Activity fetch is non-critical; keep previous data
    }
  }

  // ──────────────────────────────────────────────
  // Upcoming scheduled price (H-3 banner)
  // ──────────────────────────────────────────────

  /// Earliest future `tanggal_berlaku` across categories (list payload +
  /// `GET /waste-categories/{id}/price-history/`).
  ///
  /// Throws [DioException] with 403 if history is forbidden and no date was
  /// found on the list payload — caller should fall back to pengumuman.
  Future<DateTime?> fetchEarliestUpcomingTanggalBerlaku() async {
    final now = DateTime.now();
    DateTime? earliest;

    void consider(DateTime? value) {
      if (value == null || !value.isAfter(now)) return;
      if (earliest == null || value.isBefore(earliest!)) {
        earliest = value;
      }
    }

    for (final cat in _categories) {
      consider(cat.tanggalBerlaku);
    }

    if (_categories.isEmpty) return earliest;

    try {
      final pages = await Future.wait(
        _categories.map((cat) async {
          try {
            return await _apiClient.get<List<dynamic>>(
              '/waste-categories/${cat.id}/price-history/',
              queryParameters: const {'page_size': '20'},
              fromJson: (json) => json as List<dynamic>,
            );
          } on DioException catch (e) {
            if (_isForbidden(e)) rethrow;
            return const <dynamic>[];
          }
        }),
      );
      for (final page in pages) {
        for (final item in page) {
          if (item is! Map) continue;
          consider(
            parseOptionalDateTime(
              Map<String, dynamic>.from(item)['tanggal_berlaku'],
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (_isForbidden(e) && earliest == null) rethrow;
    }

    return earliest;
  }

  bool _isForbidden(DioException e) {
    if (e.response?.statusCode == 403) return true;
    final err = e.error;
    return err is ApiException && err.statusCode == 403;
  }

  // ──────────────────────────────────────────────
  // Load Categories Only (public, no auth required)
  // ──────────────────────────────────────────────

  /// Seed from login / splash so screens can render without waiting on /me/.
  void hydrateFrom(User user) {
    if (_user != null) return;
    _user = user;
    _error = null;
    notifyListeners();
  }

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
        _error = kGenericErrorMessage;
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
    _recentActivity = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
