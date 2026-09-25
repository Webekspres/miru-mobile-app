import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/providers/penjemputan_provider.dart';

import '../helpers/test_http.dart';

const _kuotaMessage =
    'Maksimal 2x penjemputan per minggu per wilayah. '
    'Minggu ini sudah ada 2 penjemputan untuk wilayah ini.';

Future<PenjemputanProvider> _submitWith(
  Map<String, dynamic> body, {
  int status = 400,
}) async {
  final adapter = ScriptedAdapter((_) => jsonBody(body, status: status));
  final provider = PenjemputanProvider(apiClient: apiClientWith(adapter));
  await provider.createPickup(
    estimasiBerat: 6,
    alamatJemput: 'Jl. Papua 1',
    jadwal: DateTime(2026, 10, 1, 10),
  );
  return provider;
}

void main() {
  test('kuota 2x/minggu: server message kept, flagged as rule rejection',
      () async {
    final provider = await _submitWith(envelope(
      success: false,
      statusCode: 400,
      message: _kuotaMessage,
      code: 'VALIDATION_ERROR',
      errors: {
        'jadwal': [_kuotaMessage],
      },
    ));

    expect(provider.error, _kuotaMessage);
    expect(provider.submitRejectedByRule, isTrue);
  });

  test('wilayah nonaktif flagged as rule rejection', () async {
    const msg = 'Maaf, wilayah Anda saat ini belum masuk dalam layanan.';
    final provider = await _submitWith(envelope(
      success: false,
      statusCode: 400,
      message: msg,
      errors: {
        'alamat_jemput': [msg],
      },
    ));

    expect(provider.error, msg);
    expect(provider.submitRejectedByRule, isTrue);
  });

  test('other validation errors stay as normal error', () async {
    final provider = await _submitWith(envelope(
      success: false,
      statusCode: 400,
      message: 'Minimal estimasi berat penjemputan 5 kg.',
      errors: {
        'estimasi_berat': ['Minimal estimasi berat penjemputan 5 kg.'],
      },
    ));

    expect(provider.hasError, isTrue);
    expect(provider.submitRejectedByRule, isFalse);
  });
}
