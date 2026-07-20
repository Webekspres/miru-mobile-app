import 'json_parsing.dart';

class KontenEdukasi {
  const KontenEdukasi({
    required this.id,
    required this.judul,
    required this.isi,
    this.kategoriTerkaitNama,
    this.urutan = 0,
    required this.createdAt,
  });

  final int id;
  final String judul;
  final String isi;
  final String? kategoriTerkaitNama;
  final int urutan;
  final DateTime createdAt;

  factory KontenEdukasi.fromJson(Map<String, dynamic> json) {
    return KontenEdukasi(
      id: json['id'] as int,
      judul: json['judul'] as String? ?? '',
      isi: json['isi'] as String? ?? '',
      kategoriTerkaitNama: json['kategori_terkait_nama'] as String?,
      urutan: json['urutan'] as int? ?? 0,
      createdAt: parseDateTime(json['created_at']),
    );
  }

  static List<KontenEdukasi> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => KontenEdukasi.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cuplikan singkat untuk kartu di beranda.
  String get excerpt {
    final plain = isi.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (plain.length <= 100) return plain;
    return '${plain.substring(0, 100).trimRight()}…';
  }
}
