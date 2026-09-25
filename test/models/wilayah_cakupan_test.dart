import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mirumobileapp/models/user.dart';
import 'package:mirumobileapp/models/wilayah_cakupan.dart';
import 'package:mirumobileapp/widgets/alamat_bertingkat.dart';

import '../helpers/test_http.dart';

final _json = {
  'provinsi': {'kode': '94', 'nama': 'Papua Tengah'},
  'kabupaten': {'kode': '94.04', 'nama': 'Kabupaten Mimika'},
  'distrik': {'kode': '94.04.01', 'nama': 'Mimika Baru'},
  'kelurahan': [
    {'id': 2, 'kode': '94.04.01.1002', 'nama': 'Kwamki', 'jenis': 'kelurahan'},
    {'id': 12, 'kode': '94.04.01.2004', 'nama': 'Nayaro', 'jenis': 'kampung'},
  ],
  'pesan': 'MIRU Bank Sampah hanya melayani warga Distrik Mimika Baru.',
  'peta': {
    'pusat': {'lat': -4.5467, 'lng': 136.8833},
    'batas': {'selatan': -4.7, 'barat': 136.65, 'utara': -4.25, 'timur': 137.05},
    'zoom': 13,
  },
};

void main() {
  test('parses cascade, labels and map bounds', () {
    final c = WilayahCakupan.fromJson(_json);

    expect(c.provinsi, 'Papua Tengah');
    expect(c.kabupaten, 'Kabupaten Mimika');
    expect(c.distrik, 'Mimika Baru');
    expect(c.kelurahan.map((k) => k.label),
        ['Kelurahan Kwamki', 'Kampung Nayaro']);
    expect(c.kelurahanById(12)?.nama, 'Nayaro');
    expect(c.kelurahanById(99), isNull);
    expect(c.dalamArea(const LatLng(-4.55, 136.88)), isTrue);
    expect(c.dalamArea(const LatLng(-4.05, 136.88)), isFalse);
  });

  test('complete address requires kelurahan', () {
    expect(User.fromJson(userJson()).hasCompleteAddress, isTrue);
    expect(User.fromJson(userJson(kelurahan: null)).hasCompleteAddress, isFalse);
  });

  testWidgets('shows locked cascade and lets the user pick a kelurahan',
      (tester) async {
    int? picked;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AlamatBertingkat(
          cakupan: WilayahCakupan.fromJson(_json),
          kelurahanId: null,
          onKelurahanChanged: (id) => picked = id,
        ),
      ),
    ));

    expect(find.text('MIRU Bank Sampah hanya melayani warga Distrik Mimika Baru.'),
        findsOneWidget);
    expect(find.text('Papua Tengah'), findsOneWidget);
    expect(find.text('Kabupaten Mimika'), findsOneWidget);
    expect(find.text('Mimika Baru'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kampung Nayaro').last);
    await tester.pumpAndSettle();
    expect(picked, 12);
  });

  testWidgets('asks to re-pick when the saved kelurahan is no longer served',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AlamatBertingkat(
          cakupan: WilayahCakupan.fromJson(_json),
          kelurahanId: 7,
          onKelurahanChanged: (_) {},
        ),
      ),
    ));

    expect(find.text('Kelurahan lama tidak dilayani. Pilih ulang.'), findsOneWidget);
  });
}
