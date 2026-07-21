import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/api_exception.dart';
import '../models/notification.dart';
import '../services/api_client.dart';

/// Provider for Notifications (Fitur notifikasi in-app).
///
/// Fetches `GET /api/notifications/` — list notifikasi untuk user yang login.
/// Supports marking as read, and unread count.
class NotificationProvider extends ChangeNotifier {
  NotificationProvider({required this._apiClient});

  final ApiClient _apiClient;

  // ──────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollTimer;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Count of unread notifications.
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  /// Latest 5 notifications for the popup preview.
  List<AppNotification> get latestNotifications {
    final sorted = List<AppNotification>.from(_notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  // ──────────────────────────────────────────────
  // Load Notifications
  // ──────────────────────────────────────────────

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/notifications/',
        fromJson: (json) => json as List<dynamic>,
      );
      _notifications = AppNotification.listFromJson(data);
    } on DioException catch (e) {
      // Only set error if we have no data to show
      if (_notifications.isEmpty) {
        _error = parseDioError(e);
      }
    } catch (e) {
      if (_notifications.isEmpty) {
        _error = 'Terjadi kesalahan. Silakan coba lagi.';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Pull-to-refresh — shows skeleton via [isLoading].
  Future<void> refresh() => loadNotifications();

  // ──────────────────────────────────────────────
  // Mark as Read
  // ──────────────────────────────────────────────

  Future<void> markAsRead(int id) async {
    // Optimistic update
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();

    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/notifications/$id/read/',
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (_) {
      // Revert on failure
      _notifications[index] = _notifications[index].copyWith(isRead: false);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final hadUnread = unreadCount > 0;
    _notifications = _notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    notifyListeners();

    if (!hadUnread) return;

    try {
      await _apiClient.post<Map<String, dynamic>>(
        '/notifications/mark-all-read/',
        data: {},
        fromJson: (json) => Map<String, dynamic>.from(json as Map),
      );
    } catch (_) {
      // Revert on failure
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: false))
          .toList();
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // Polling
  // ──────────────────────────────────────────────

  /// Start polling every [interval] seconds for new notifications.
  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    stopPolling();
    _pollTimer = Timer.periodic(interval, (_) => refresh());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ──────────────────────────────────────────────
  // Clear
  // ──────────────────────────────────────────────

  void clearCache() {
    stopPolling();
    _notifications = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
