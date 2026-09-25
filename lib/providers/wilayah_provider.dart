import 'package:flutter/foundation.dart';

import '../models/wilayah_cakupan.dart';
import '../services/api_client.dart';

/// Cakupan wilayah layanan (dimuat sekali, dipakai profil & penjemputan).
class WilayahProvider extends ChangeNotifier {
  WilayahProvider({required this._apiClient});

  final ApiClient _apiClient;

  WilayahCakupan? _cakupan;
  bool _isLoading = false;
  String? _error;

  /// Selalu berisi nilai: data API bila sudah dimuat, fallback bila belum.
  WilayahCakupan get cakupan => _cakupan ?? WilayahCakupan.fallback;
  bool get isLoaded => _cakupan != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load({bool force = false}) async {
    if (_isLoading || (_cakupan != null && !force)) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _cakupan = await _apiClient.get<WilayahCakupan>(
        '/wilayah/cakupan/',
        fromJson: (json) =>
            WilayahCakupan.fromJson(Map<String, dynamic>.from(json as Map)),
      );
    } catch (_) {
      _error = 'Daftar kelurahan gagal dimuat. Coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
