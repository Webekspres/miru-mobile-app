import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/user.dart';
import 'package:mirumobileapp/providers/auth_session.dart';
import 'package:mirumobileapp/providers/profile_provider.dart';
import 'package:mirumobileapp/services/api_client.dart';
import 'package:mirumobileapp/services/storage_service.dart';

class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this._body, {this.delay});

  final String _body;
  final Duration? delay;
  int gets = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    gets++;
    if (delay != null) await Future<void>.delayed(delay!);
    return ResponseBody.fromString(
      _body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _userJson({int id = 1, String name = 'Budi'}) => {
      'id': id,
      'username': 'budi',
      'role': 'nasabah',
      'nama_lengkap': name,
      'saldo': '1000.00',
      'poin': 5,
    };

ProfileProvider _provider(_CountingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api'));
  dio.httpClientAdapter = adapter;
  final storage = StorageService();
  return ProfileProvider(
    apiClient: ApiClient(
      storageService: storage,
      authSession: AuthSession(storage),
      dio: dio,
    ),
  );
}

void main() {
  final userJson = jsonEncode(_userJson());

  test('ensureLoaded hydrates without a network call', () {
    final adapter = _CountingAdapter(userJson);
    final profile = _provider(adapter);
    profile.hydrateFrom(User.fromJson(_userJson(name: 'Sesi')));
    expect(profile.user?.namaLengkap, 'Sesi');
    profile.ensureLoaded();
    expect(adapter.gets, 0);
  });

  test('concurrent loadProfile shares one in-flight request', () async {
    final adapter = _CountingAdapter(
      userJson,
      delay: const Duration(milliseconds: 40),
    );
    final profile = _provider(adapter);

    await Future.wait([
      profile.loadProfile(),
      profile.loadProfile(),
      profile.ensureLoaded(),
    ]);

    expect(adapter.gets, 1);
    expect(profile.user?.namaLengkap, 'Budi');
  });

  test('clearCache drops in-flight result from the previous session', () async {
    final adapter = _CountingAdapter(
      userJson,
      delay: const Duration(milliseconds: 40),
    );
    final profile = _provider(adapter);

    final pending = profile.loadProfile();
    profile.clearCache();
    await pending;

    expect(profile.user, isNull);
    expect(profile.isLoading, isFalse);
  });
}
