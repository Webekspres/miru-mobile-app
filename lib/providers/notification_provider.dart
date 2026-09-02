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
  bool _isFetching = false;
  bool _hasLoaded = false;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isPolling => _pollTimer != null;

  /// Count of unread notifications.
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  /// Latest 5 unread notifications for the popup preview.
  List<AppNotification> get latestNotifications {
    final sorted = _notifications.where((n) => !n.isRead).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(5).toList();
  }

  // ──────────────────────────────────────────────
  // Load Notifications
  // ──────────────────────────────────────────────

  /// Fetch once per session. Polling / pull-to-refresh still use [loadNotifications].
  Future<void> ensureLoaded() {
    if (_hasLoaded || _isFetching) return Future.value();
    return loadNotifications();
  }

  /// [silent] = true: update list tanpa skeleton/loading (untuk polling).
  Future<void> loadNotifications({bool silent = false}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (!silent && _notifications.isEmpty) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final data = await _apiClient.get<List<dynamic>>(
        '/notifications/',
        fromJson: (json) => json as List<dynamic>,
      );
      final next = AppNotification.listFromJson(data);
      _hasLoaded = true;
      if (!_sameNotifications(_notifications, next)) {
        _notifications = next;
        notifyListeners();
      } else if (!silent) {
        notifyListeners();
      }
    } on DioException catch (e) {
      if (_notifications.isEmpty) {
        _error = parseDioError(e);
        if (!silent) notifyListeners();
      }
    } catch (_) {
      if (_notifications.isEmpty) {
        _error = 'Terjadi kesalahan. Silakan coba lagi.';
        if (!silent) notifyListeners();
      }
    } finally {
      _isFetching = false;
      if (!silent && _isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Pull-to-refresh — keep previous list visible when cached data exists.
  Future<void> refresh() =>
      loadNotifications(silent: _notifications.isNotEmpty);

  /// Silent refresh untuk polling / resume app.
  Future<void> refreshSilent() => loadNotifications(silent: true);

  static bool _sameNotifications(
    List<AppNotification> a,
    List<AppNotification> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].isRead != b[i].isRead) return false;
    }
    return true;
  }

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

  /// Start silent polling for new notifications.
  void startPolling({Duration interval = const Duration(seconds: 8)}) {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(interval, (_) => refreshSilent());
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
    _isFetching = false;
    _hasLoaded = false;
    notifyListeners();
  }
}
