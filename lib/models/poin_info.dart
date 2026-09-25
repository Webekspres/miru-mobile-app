import 'json_parsing.dart';

/// Ringkasan masa berlaku poin dari `GET /api/auth/poin-info/`.
class PoinInfo {
  const PoinInfo({
    required this.poinSaatIni,
    required this.totalAkanHangus,
    required this.poinHangusTerdekat,
    required this.tanggalKedaluwarsaTerdekat,
    required this.catatan,
  });

  final int poinSaatIni;
  final int totalAkanHangus;
  final int poinHangusTerdekat;

  /// Waktu kedaluwarsa terdekat (UTC), `null` jika tidak ada poin aktif.
  final DateTime? tanggalKedaluwarsaTerdekat;
  final String catatan;

  static const String defaultCatatan =
      'Poin berlaku 1 tahun sejak diperoleh. '
      'Poin yang tidak digunakan akan hangus otomatis.';

  bool get hasExpiringPoin =>
      poinHangusTerdekat > 0 && tanggalKedaluwarsaTerdekat != null;

  factory PoinInfo.fromJson(Map<String, dynamic> json) {
    final catatan = (json['catatan'] as String?)?.trim() ?? '';
    return PoinInfo(
      poinSaatIni: parseInt(json['poin_saat_ini']),
      totalAkanHangus: parseInt(json['total_akan_hangus']),
      // Backend lama belum mengirim field ini — anggap tidak diketahui.
      poinHangusTerdekat: parseInt(json['poin_hangus_terdekat']),
      tanggalKedaluwarsaTerdekat: parseOptionalDateTime(
        json['tanggal_kedaluwarsa_terdekat'],
      )?.toUtc(),
      catatan: catatan.isEmpty ? defaultCatatan : catatan,
    );
  }
}
