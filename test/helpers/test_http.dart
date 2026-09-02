import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:mirumobileapp/providers/auth_session.dart';
import 'package:mirumobileapp/services/api_client.dart';
import 'package:mirumobileapp/services/storage_service.dart';

class ScriptedAdapter implements HttpClientAdapter {
  ScriptedAdapter(this._handler, {this.delay});

  final FutureOr<ResponseBody> Function(RequestOptions options) _handler;
  final Duration? delay;
  int calls = 0;
  int posts = 0;
  int gets = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    if (options.method == 'POST') posts++;
    if (options.method == 'GET') gets++;
    if (delay != null) await Future<void>.delayed(delay!);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonBody(Object data, {int status = 200}) {
  return ResponseBody.fromString(
    jsonEncode(data),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Map<String, dynamic> envelope({
  required bool success,
  dynamic data,
  int statusCode = 200,
  String message = 'OK',
  String? code,
  Map<String, dynamic>? errors,
}) {
  return {
    'success': success,
    'status_code': statusCode,
    'message': message,
    'code': ?code,
    'errors': ?errors,
    'data': data,
    'meta': {'timestamp': '', 'request_id': 'test'},
  };
}

Map<String, dynamic> userJson({
  int id = 1,
  String username = 'nasabah001',
  String role = 'nasabah',
  String nama = 'Budi',
  Object saldo = '125000.00',
  Object poin = 10,
  String alamat = 'Jl. Papua 1',
}) {
  return {
    'id': id,
    'username': username,
    'role': role,
    'nama_lengkap': nama,
    'saldo': saldo,
    'poin': poin,
    'alamat': alamat,
    'is_active': true,
    'phone_verified': true,
  };
}

ApiClient apiClientWith(ScriptedAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api'));
  dio.httpClientAdapter = adapter;
  final storage = StorageService();
  return ApiClient(
    storageService: storage,
    authSession: AuthSession(storage),
    dio: dio,
  );
}
