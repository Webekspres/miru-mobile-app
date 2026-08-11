import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/complaint.dart';
import '../services/api_client.dart';

/// Provider for Pengaduan (Fase 3.8).
///
/// Handles:
/// - Fetching complaints from `/api/complaints/?nasabah={id}`
/// - Creating new complaints via `POST /api/complaints/`
class PengaduanProvider extends ChangeNotifier {
  PengaduanProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State — Complaints
  // ──────────────────────────────────────────────

  List<Complaint> _complaints = [];
  bool _isLoading = false;
  String? _error;

  // ──────────────────────────────────────────────
  // State — Submission
  // ──────────────────────────────────────────────

  bool _isSubmitting = false;
  String? _submitError;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  List<Complaint> get complaints => _complaints;

  List<Complaint> get openComplaints =>
      _complaints.where((c) => c.status == ComplaintStatus.terbuka).toList();

  List<Complaint> get closedComplaints =>
      _complaints.where((c) => c.status == ComplaintStatus.ditutup).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;
  bool get hasSubmitError => _submitError != null;

  // ──────────────────────────────────────────────
  // Load Complaints
  // ──────────────────────────────────────────────

  Future<void> loadComplaints({required int userId}) async {
    final showLoading = _complaints.isEmpty;
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
        '/complaints/',
        queryParameters: {
          'nasabah': userId.toString(),
          'ordering': '-tanggal',
        },
        fromJson: (json) => json as List<dynamic>,
      );

      _complaints = Complaint.listFromJson(data);
      _error = null;
    } on DioException catch (e) {
      if (_complaints.isEmpty) {
        _error = parseDioError(e);
      }
    } catch (_) {
      if (_complaints.isEmpty) {
        _error = 'Terjadi kesalahan. Silakan coba lagi.';
      }
    } finally {
      if (_isLoading) _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh.
  Future<void> refreshForUser({required int userId}) async {
    await loadComplaints(userId: userId);
  }

  // ──────────────────────────────────────────────
  // Create Complaint
  // ──────────────────────────────────────────────

  /// Creates a new complaint.
  ///
  /// Returns the created [Complaint] on success, `null` on error.
  Future<Complaint?> createComplaint({
    required String jenisPengaduan,
    required String keluhan,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      final data = await _apiClient.post<Map<String, dynamic>>(
        '/complaints/',
        data: {
          'jenis_pengaduan': jenisPengaduan,
          'keluhan': keluhan,
        },
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );

      final complaint = Complaint.fromJson(data);

      // Insert at top of list
      _complaints.insert(0, complaint);

      _isSubmitting = false;
      notifyListeners();
      return complaint;
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

  // ──────────────────────────────────────────────
  // Clear cache (panggil saat logout)
  // ──────────────────────────────────────────────

  void clearCache() {
    _complaints = [];
    _error = null;
    _submitError = null;
    _isLoading = false;
    _isSubmitting = false;
    notifyListeners();
  }
}
