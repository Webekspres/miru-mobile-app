import 'json_parsing.dart';

class KontenEdukasi {
  const KontenEdukasi({
    required this.id,
    required this.judul,
    required this.isi,
    this.gambarUrl,
    this.kategoriTerkaitNama,
    required this.createdAt,
  });

  final int id;
  final String judul;
  final String isi;
  final String? gambarUrl;
  final String? kategoriTerkaitNama;
  final DateTime createdAt;

  factory KontenEdukasi.fromJson(Map<String, dynamic> json) {
    final rawGambar = json['gambar_url'] ?? json['featured_image'];
    final gambar = rawGambar is String && rawGambar.trim().isNotEmpty
        ? rawGambar.trim()
        : null;
    return KontenEdukasi(
      id: json['id'] as int,
      judul: json['judul'] as String? ?? '',
      isi: json['isi'] as String? ?? '',
      gambarUrl: gambar,
      kategoriTerkaitNama: json['kategori_terkait_nama'] as String?,
      createdAt: parseDateTime(json['created_at']),
    );
  }

  static List<KontenEdukasi> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => KontenEdukasi.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cuplikan singkat untuk kartu artikel.
  String get excerpt {
    final plain = isi
        .replaceAll(RegExp(r'[#*_`>~\[\]]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (plain.length <= 120) return plain;
    return '${plain.substring(0, 120).trimRight()}…';
  }
}
