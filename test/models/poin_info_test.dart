import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/poin_info.dart';

void main() {
  group('PoinInfo.fromJson', () {
    test('parses nearest expiry', () {
      final info = PoinInfo.fromJson({
        'poin_saat_ini': 55,
        'total_akan_hangus': '55',
        'poin_hangus_terdekat': 15,
        'tanggal_kedaluwarsa_terdekat': '2027-01-10T10:00:00+09:00',
        'catatan': 'Poin berlaku 1 tahun.',
      });

      expect(info.poinSaatIni, 55);
      expect(info.totalAkanHangus, 55);
      expect(info.poinHangusTerdekat, 15);
      expect(info.tanggalKedaluwarsaTerdekat, DateTime.utc(2027, 1, 10, 1));
      expect(info.hasExpiringPoin, isTrue);
      expect(info.catatan, 'Poin berlaku 1 tahun.');
    });

    test('no active poin and missing fields fall back safely', () {
      final info = PoinInfo.fromJson({
        'poin_saat_ini': 0,
        'total_akan_hangus': 0,
        'tanggal_kedaluwarsa_terdekat': null,
      });

      expect(info.poinHangusTerdekat, 0);
      expect(info.tanggalKedaluwarsaTerdekat, isNull);
      expect(info.hasExpiringPoin, isFalse);
      expect(info.catatan, PoinInfo.defaultCatatan);
    });
  });
}
