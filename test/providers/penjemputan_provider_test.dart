import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/providers/penjemputan_provider.dart';

import '../helpers/test_http.dart';

const _kuotaMessage =
    'Pemesanan untuk jadwal ini sudah ditutup (minimal H-1). '
    'Silakan pilih jadwal berikutnya.';

Future<PenjemputanProvider> _submitWith(
  Map<String, dynamic> body, {
  int status = 400,
}) async {
  final adapter = ScriptedAdapter((_) => jsonBody(body, status: status));
  final provider = PenjemputanProvider(apiClient: apiClientWith(adapter));
  await provider.createPickup(
    estimasiBerat: 6,
    alamatJemput: 'Jl. Papua 1',
    jadwalWilayahId: 12,
  );
  return provider;
}

void main() {
  test(
    'jadwal ditutup (H-1): server message kept, flagged as rule rejection',
    () async {
      final provider = await _submitWith(
        envelope(
          success: false,
          statusCode: 400,
          message: _kuotaMessage,
          code: 'VALIDATION_ERROR',
          errors: {
            'jadwal_wilayah': [_kuotaMessage],
          },
        ),
      );

      expect(provider.error, _kuotaMessage);
      expect(provider.submitRejectedByRule, isTrue);
    },
  );

  test('wilayah nonaktif flagged as rule rejection', () async {
    const msg = 'Maaf, wilayah Anda saat ini belum masuk dalam layanan.';
    final provider = await _submitWith(
      envelope(
        success: false,
        statusCode: 400,
        message: msg,
        errors: {
          'jadwal_wilayah': [msg],
        },
      ),
    );

    expect(provider.error, msg);
    expect(provider.submitRejectedByRule, isTrue);
  });

  test('other validation errors stay as normal error', () async {
    final provider = await _submitWith(
      envelope(
        success: false,
        statusCode: 400,
        message: 'Minimal estimasi berat penjemputan 5 kg.',
        errors: {
          'estimasi_berat': ['Minimal estimasi berat penjemputan 5 kg.'],
        },
      ),
    );

    expect(provider.hasError, isTrue);
    expect(provider.submitRejectedByRule, isFalse);
  });

  test('createPickup sends jadwal_wilayah, not a free jadwal', () async {
    Map<String, dynamic>? sent;
    final adapter = ScriptedAdapter((options) {
      sent = Map<String, dynamic>.from(options.data as Map);
      return jsonBody({
        'id': 1,
        'nasabah': 1,
        'estimasi_berat': '6.00',
        'alamat_jemput': 'Jl. Papua 1',
        'jadwal': '2026-10-06T08:00:00+09:00',
        'jadwal_wilayah': 12,
        'status': 'menunggu',
      }, status: 201);
    });
    final provider = PenjemputanProvider(apiClient: apiClientWith(adapter));
    final pickup = await provider.createPickup(
      estimasiBerat: 6,
      alamatJemput: 'Jl. Papua 1',
      jadwalWilayahId: 12,
    );

    expect(pickup, isNotNull);
    expect(sent?['jadwal_wilayah'], 12);
    expect(sent?.containsKey('jadwal'), isFalse);
  });

  test('loadJadwal keeps only bookable jadwal', () async {
    final adapter = ScriptedAdapter(
      (_) => jsonBody([
        {
          'id': 1,
          'wilayah_nama': 'Kwamki',
          'tanggal': '2026-10-06',
          'jam_mulai': '08:00:00',
          'jam_selesai': '12:00:00',
          'bisa_dipesan': true,
        },
        {
          'id': 2,
          'wilayah_nama': 'Kwamki',
          'tanggal': '2026-10-02',
          'jam_mulai': '08:00:00',
          'jam_selesai': '12:00:00',
          'bisa_dipesan': false,
        },
      ]),
    );
    final provider = PenjemputanProvider(apiClient: apiClientWith(adapter));
    await provider.loadJadwal();

    expect(provider.jadwal.map((j) => j.id), [1]);
    expect(provider.jadwal.first.jamLabel, '08.00–12.00 WIT');
    expect(provider.jadwal.first.tanggal, DateTime(2026, 10, 6));
  });
}
