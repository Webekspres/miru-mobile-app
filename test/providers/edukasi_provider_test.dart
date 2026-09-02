import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/konten_edukasi.dart';
import 'package:mirumobileapp/providers/edukasi_provider.dart';

import '../helpers/test_http.dart';

Map<String, dynamic> _artikel({int id = 1}) => {
      'id': id,
      'judul': 'Pilah sampah dari rumah',
      'isi': 'Pisahkan organik dan anorganik.',
      'created_at': '2026-09-01T00:00:00Z',
    };

void main() {
  test('KontenEdukasi.fromJson keeps judul and isi', () {
    final item = KontenEdukasi.fromJson(_artikel());
    expect(item.judul, 'Pilah sampah dari rumah');
    expect(item.isi, contains('organik'));
  });

  test('loads list then detail by id', () async {
    final provider = EdukasiProvider(
      apiClient: apiClientWith(
        ScriptedAdapter((options) {
          if (options.path.contains('/edukasi/1/')) {
            return jsonBody(_artikel());
          }
          return jsonBody([_artikel(), _artikel(id: 2)]);
        }),
      ),
    );

    await provider.loadEdukasi();
    expect(provider.items.length, 2);

    final detail = await provider.loadDetail(1);
    expect(detail?.judul, 'Pilah sampah dari rumah');
    expect(provider.findById(1)?.id, 1);
  });
}
