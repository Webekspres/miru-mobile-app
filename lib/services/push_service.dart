import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'storage_service.dart';

/// Notifikasi push (FCM): izin, daftar/lepas device token ke backend
/// (`/api/device-tokens/`), dan meneruskan pesan ke aplikasi.
///
/// Semua langkah aman-gagal: tanpa `google-services.json` atau tanpa izin,
/// aplikasi tetap jalan dan notifikasi in-app (polling) tetap bekerja.
class PushService {
  PushService({
    required this._apiClient,
    required this._storage,
    FirebaseMessaging? messaging,
  }) : _messagingOverride = messaging;

  static const prefKey = 'push_enabled';

  final ApiClient _apiClient;
  final StorageService _storage;
  final FirebaseMessaging? _messagingOverride;

  bool _ready = false;
  String? _registeredToken;
  final List<StreamSubscription<dynamic>> _subs = [];

  /// Pesan masuk saat aplikasi terbuka (OS tidak menampilkan banner).
  void Function(RemoteMessage message)? onForegroundMessage;

  /// Pengguna mengetuk notifikasi (aplikasi di latar atau baru dibuka).
  void Function(RemoteMessage message)? onMessageOpened;

  bool get isAvailable => _ready;

  FirebaseMessaging get _messaging =>
      _messagingOverride ?? FirebaseMessaging.instance;

  Future<void> init() async {
    try {
      if (_messagingOverride == null) await Firebase.initializeApp();
      _ready = true;
    } catch (e) {
      debugPrint('Push nonaktif (Firebase belum dikonfigurasi): $e');
      return;
    }
    _subs
      ..add(FirebaseMessaging.onMessage.listen((m) => onForegroundMessage?.call(m)))
      ..add(FirebaseMessaging.onMessageOpenedApp.listen((m) => onMessageOpened?.call(m)))
      ..add(_messaging.onTokenRefresh.listen((token) {
        if (_registeredToken != null) _send(token);
      }));
    final initial = await _messaging.getInitialMessage();
    if (initial != null) onMessageOpened?.call(initial);
  }

  /// Preferensi per perangkat (default aktif).
  Future<bool> isEnabled() async => (await _storage.read(prefKey)) != 'false';

  /// Simpan preferensi; saat diaktifkan, kembalikan `false` bila izin ditolak.
  Future<bool> setEnabled(bool enabled) async {
    await _storage.write(prefKey, enabled ? 'true' : 'false');
    if (!enabled) {
      await unregister();
      return true;
    }
    return register();
  }

  /// Minta izin (Android 13+) lalu daftarkan token untuk user yang login.
  /// Mengembalikan `false` bila push tidak tersedia / izin ditolak.
  Future<bool> register() async {
    if (!_ready || !await isEnabled()) return false;
    try {
      final settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return false;
      }
      final token = await _messaging.getToken();
      if (token == null) return false;
      await _send(token);
      return true;
    } catch (e) {
      debugPrint('Gagal mendaftarkan token push: $e');
      return false;
    }
  }

  Future<void> _send(String token) async {
    await _apiClient.post<dynamic>(
      '/device-tokens/',
      data: {'token': token, 'platform': 'android'},
      fromJson: (json) => json,
    );
    _registeredToken = token;
  }

  /// Lepas token dari akun (panggil sebelum sesi dihapus saat logout).
  Future<void> unregister() async {
    if (!_ready) return;
    try {
      final token = _registeredToken ?? await _messaging.getToken();
      if (token == null) return;
      await _apiClient.delete<dynamic>(
        '/device-tokens/unregister/',
        data: {'token': token},
        fromJson: (json) => json,
      );
    } catch (e) {
      debugPrint('Gagal melepas token push: $e');
    } finally {
      _registeredToken = null;
    }
  }

  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    _subs.clear();
  }
}

/// Layar tujuan saat notifikasi diketuk (berdasarkan data payload backend:
/// `kategori`, `event`, `pengumuman_id`, `notification_id`).
String pushTargetRoute(Map<String, dynamic> data) {
  final kategori = '${data['kategori'] ?? data['event'] ?? ''}';
  if (kategori == 'jadwal_jemput') return '/home/penjemputan/ajukan';
  if (kategori == 'penjemputan') return '/home/penjemputan';
  if (kategori == 'penarikan' || kategori == 'setoran') return '/riwayat';
  if (kategori == 'harga') return '/home/info-sampah';
  return '/notifikasi';
}
