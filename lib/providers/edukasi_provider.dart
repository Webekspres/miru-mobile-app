import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/konten_edukasi.dart';
import '../services/api_client.dart';

/// Provider konten edukasi sampah — `GET /api/edukasi/` (public).
class EdukasiProvider extends ChangeNotifier {
  EdukasiProvider({required this._apiClient});

  final ApiClient _apiClient;

  List<KontenEdukasi> _items = [];
  bool _isLoading = false;
  String? _error;

  List<KontenEdukasi> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  Future<void> loadEdukasi({bool silent = false}) async {
    final showLoading = !silent && _items.isEmpty;
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
        '/edukasi/',
        fromJson: (json) => json as List<dynamic>,
      );
      _items = KontenEdukasi.listFromJson(data);
      _error = null;
    } on DioException catch (e) {
      if (_items.isEmpty) {
        _error = parseDioError(e);
      }
    } catch (_) {
      if (_items.isEmpty) {
        _error = kGenericErrorMessage;
      }
    }

    if (_isLoading) {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> refresh() => loadEdukasi(silent: _items.isNotEmpty);

  KontenEdukasi? findById(int id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<KontenEdukasi?> loadDetail(int id) async {
    final cached = findById(id);
    if (cached != null) return cached;

    try {
      final data = await _apiClient.get<Map<String, dynamic>>(
        '/edukasi/$id/',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      final item = KontenEdukasi.fromJson(data);
      final index = _items.indexWhere((e) => e.id == item.id);
      if (index >= 0) {
        _items[index] = item;
      } else {
        _items = [..._items, item];
      }
      notifyListeners();
      return item;
    } on DioException catch (e) {
      _error = parseDioError(e);
      notifyListeners();
      return null;
    } catch (_) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      notifyListeners();
      return null;
    }
  }

  void clearCache() {
    _items = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
