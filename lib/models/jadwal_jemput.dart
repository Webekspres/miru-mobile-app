import 'package:intl/intl.dart';

import 'json_parsing.dart';

/// Hari jemput yang ditetapkan admin untuk wilayah nasabah
/// (`GET /api/jadwal-jemput/`). Maks 2 per minggu per wilayah.
class JadwalJemput {
  const JadwalJemput({
    required this.id,
    required this.wilayahNama,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    this.catatan = '',
    this.jumlahPesanan = 0,
    this.bisaDipesan = true,
  });

  final int id;
  final String wilayahNama;

  /// Tanggal kalender WIT (tanpa jam).
  final DateTime tanggal;

  /// "HH:MM" WIT.
  final String jamMulai;
  final String jamSelesai;
  final String catatan;
  final int jumlahPesanan;
  final bool bisaDipesan;

  /// "Selasa, 29 September 2026"
  String get tanggalLabel =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tanggal);

  /// "08.00–12.00 WIT"
  String get jamLabel =>
      '${jamMulai.replaceAll(':', '.')}–${jamSelesai.replaceAll(':', '.')} WIT';

  static String _hm(dynamic value) {
    final s = value?.toString() ?? '';
    return s.length >= 5 ? s.substring(0, 5) : s;
  }

  factory JadwalJemput.fromJson(Map<String, dynamic> json) {
    final ymd = DateTime.parse(json['tanggal'] as String);
    return JadwalJemput(
      id: parseInt(json['id']),
      wilayahNama: json['wilayah_nama'] as String? ?? '',
      tanggal: DateTime(ymd.year, ymd.month, ymd.day),
      jamMulai: _hm(json['jam_mulai']),
      jamSelesai: _hm(json['jam_selesai']),
      catatan: json['catatan'] as String? ?? '',
      jumlahPesanan: parseInt(json['jumlah_pesanan']),
      bisaDipesan: json['bisa_dipesan'] as bool? ?? true,
    );
  }

  static List<JadwalJemput> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map((e) => JadwalJemput.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
