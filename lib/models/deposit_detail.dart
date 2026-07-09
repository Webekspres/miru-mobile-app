import 'json_parsing.dart';

class DepositDetail {
  const DepositDetail({
    required this.id,
    required this.kategori,
    required this.kategoriNama,
    required this.beratKg,
    required this.hargaSaatItu,
    required this.subtotal,
  });

  final int id;
  final int kategori;
  final String kategoriNama;
  final String beratKg;
  final String hargaSaatItu;
  final String subtotal;

  double get beratKgAsDouble => parseDecimal(beratKg);

  double get hargaSaatItuAsDouble => parseDecimal(hargaSaatItu);

  double get subtotalAsDouble => parseDecimal(subtotal);

  factory DepositDetail.fromJson(Map<String, dynamic> json) {
    return DepositDetail(
      id: json['id'] as int,
      kategori: json['kategori'] as int,
      kategoriNama: json['kategori_nama'] as String? ?? '',
      beratKg: json['berat_kg']?.toString() ?? '0.00',
      hargaSaatItu: json['harga_saat_itu']?.toString() ?? '0.00',
      subtotal: json['subtotal']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kategori': kategori,
        'kategori_nama': kategoriNama,
        'berat_kg': beratKg,
        'harga_saat_itu': hargaSaatItu,
        'subtotal': subtotal,
      };

  static List<DepositDetail> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map(
          (item) =>
              DepositDetail.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
