import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/activity_item.dart';
import 'package:mirumobileapp/providers/home_provider.dart';
import 'package:mirumobileapp/providers/saldo_provider.dart';
import 'package:mirumobileapp/models/user.dart';

import '../helpers/test_http.dart';

void main() {
  test('overlapping tarik saldo only sends one request', () async {
    final adapter = ScriptedAdapter(
      (_) => jsonBody({
        'id': 9,
        'nasabah': 1,
        'nominal': '50000.00',
        'metode': 'tunai',
        'status': 'menunggu',
        'tanggal': '2026-09-02T00:00:00Z',
      }),
      delay: const Duration(milliseconds: 40),
    );
    final provider = SaldoProvider(apiClient: apiClientWith(adapter));

    final results = await Future.wait([
      provider.createWithdrawal(nominal: 50000, metode: 'tunai'),
      provider.createWithdrawal(nominal: 50000, metode: 'tunai'),
    ]);

    expect(adapter.posts, 1);
    expect(results.where((r) => r != null).length, 1);
  });

  test('tarik saldo does not change local home saldo before confirm', () async {
    final adapter = ScriptedAdapter(
      (_) => jsonBody({
        'id': 9,
        'nasabah': 1,
        'nominal': '50000.00',
        'metode': 'tunai',
        'status': 'menunggu',
        'tanggal': '2026-09-02T00:00:00Z',
      }),
    );
    final api = apiClientWith(adapter);
    final home = HomeProvider(apiClient: api)
      ..hydrateFrom(User.fromJson(userJson(saldo: '200000.00')));
    final saldo = SaldoProvider(apiClient: api);

    await saldo.createWithdrawal(nominal: 50000, metode: 'tunai');

    expect(home.saldo, 200000);
  });

  test('downloadReceipt fetches the PDF bytes for setoran and penarikan', () async {
    final paths = <String>[];
    final adapter = ScriptedAdapter((options) {
      paths.add(options.path);
      return ResponseBody.fromBytes(
        [0x25, 0x50, 0x44, 0x46], // %PDF
        200,
        headers: {
          Headers.contentTypeHeader: ['application/pdf'],
        },
      );
    });
    final provider = SaldoProvider(apiClient: apiClientWith(adapter));
    ActivityItem item(ActivityType type) => ActivityItem(
          id: 7,
          type: type,
          status: 'selesai',
          keterangan: '',
          tanggal: DateTime(2026, 9, 29),
        );

    final setoran = await provider.downloadReceipt(item(ActivityType.setoran));
    await provider.downloadReceipt(item(ActivityType.penarikan));

    expect(setoran, [0x25, 0x50, 0x44, 0x46]);
    expect(paths, ['/deposits/7/receipt/', '/withdrawals/7/receipt/']);
  });
}
