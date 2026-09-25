import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/user.dart';

import '../helpers/test_http.dart';

void main() {
  test('fromJson accepts saldo and poin as strings', () {
    final user = User.fromJson(userJson(saldo: '125000.50', poin: '42'));
    expect(user.saldo, '125000.50');
    expect(user.saldoAsDouble, 125000.50);
    expect(user.poin, 42);
    expect(user.isNasabah, isTrue);
  });

  test('fromJson accepts saldo and poin as numbers', () {
    final user = User.fromJson(userJson(saldo: 99000, poin: 7));
    expect(user.saldo, '99000');
    expect(user.saldoAsDouble, 99000);
    expect(user.poin, 7);
  });

  test('fromJson treats missing saldo/poin as zero', () {
    final json = userJson();
    json.remove('saldo');
    json.remove('poin');
    final user = User.fromJson(json);
    expect(user.saldoAsDouble, 0);
    expect(user.poin, 0);
  });
}
