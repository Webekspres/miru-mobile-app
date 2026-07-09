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
class HomeProvider extends ChangeNotifier {
  HomeProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────

  User? _user;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;
  List<WasteCategory> _categories = [];
  List<Deposit> _recentDeposits = [];

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  User? get user => _user;
  double get saldo => _user?.saldoAsDouble ?? 0.0;
  int get poin => _user?.poin ?? 0;
  String get namaLengkap => _user?.namaLengkap ?? '';
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;
  bool get hasError => _error != null;
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

  /// Initial load (shows LoadingIndicator).
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _fetchAll();

    _isLoading = false;
    notifyListeners();
  }

  /// Pull-to-refresh (only shows refresh indicator).
  Future<void> refresh() async {
    _isRefreshing = true;
    _error = null;
    notifyListeners();

    await _fetchAll();

    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> _fetchAll() async {
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

      // Parse user
      final userData = results[0] as Map<String, dynamic>;
      _user = User.fromJson(userData);

      // Parse waste categories (top 4)
      final catData = results[1] as List<dynamic>;
      _categories = WasteCategory.listFromJson(catData);

      // Fetch recent deposits (only if user is loaded)
      if (_user != null) {
        await _fetchRecentDeposits();
      }
    } on DioException catch (e) {
      _error = parseDioError(e);
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<void> _fetchRecentDeposits() async {
    try {
      final depositData = await _apiClient.get<Map<String, dynamic>>(
        '/deposits/',
        queryParameters: {
          'nasabah': _user!.id.toString(),
          'page_size': '3',
          'ordering': '-tanggal',
        },
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );

      final results = depositData['results'];
      if (results is List) {
        _recentDeposits = Deposit.listFromJson(results);
      } else {
        _recentDeposits = [];
      }
    } catch (_) {
      // Deposits fetch is non-critical; keep previous data or empty
      if (_recentDeposits.isEmpty) {
        _recentDeposits = [];
      }
    }
  }
}
