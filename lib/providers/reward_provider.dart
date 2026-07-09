import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/reward.dart';
import '../models/reward_redemption.dart';
import '../services/api_client.dart';

/// Provider for Reward & Tukar Poin (Fase 3.7).
///
/// Handles:
/// - Fetching reward catalog from `/api/rewards/`
/// - Creating reward redemptions via `POST /api/reward-redemptions/`
class RewardProvider extends ChangeNotifier {
  RewardProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State — Rewards
  // ──────────────────────────────────────────────

  List<Reward> _rewards = [];
  bool _isLoading = false;
  String? _error;

  // ──────────────────────────────────────────────
  // State — Redemption
  // ──────────────────────────────────────────────

  bool _isSubmitting = false;
  String? _submitError;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  List<Reward> get rewards => _rewards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  bool get hasSubmitError => _submitError != null;

  // ──────────────────────────────────────────────
  // Load Rewards
  // ──────────────────────────────────────────────

  Future<void> loadRewards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/rewards/',
        fromJson: (json) => json as List<dynamic>,
      );

      _rewards = Reward.listFromJson(data);
    } on DioException catch (e) {
      _error = parseDioError(e);
    } catch (_) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh.
  Future<void> refresh() async {
    await loadRewards();
  }

  // ──────────────────────────────────────────────
  // Create Redemption (Tukar Poin)
  // ──────────────────────────────────────────────

  /// Creates a new reward redemption.
  ///
  /// Returns the created [RewardRedemption] on success, `null` on error.
  Future<RewardRedemption?> createRedemption({
    required int rewardId,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final data = await _apiClient.post<Map<String, dynamic>>(
        '/reward-redemptions/',
        data: RewardRedemption.createPayload(rewardId),
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );

      final redemption = RewardRedemption.fromJson(data);

      // Decrease local stock count
      final index = _rewards.indexWhere((r) => r.id == rewardId);
      if (index != -1) {
        final old = _rewards[index];
        _rewards[index] = Reward(
          id: old.id,
          nama: old.nama,
          poinDibutuhkan: old.poinDibutuhkan,
          stok: (old.stok - 1).clamp(0, old.stok),
        );
      }

      _isSubmitting = false;
      notifyListeners();
      return redemption;
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
  // Clear errors
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
