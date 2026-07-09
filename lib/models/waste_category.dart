import 'json_parsing.dart';

class WasteCategory {
  const WasteCategory({
    required this.id,
    required this.nama,
    required this.hargaBeliPerKg,
    required this.stokTerkiniKg,
  });

  final int id;
  final String nama;
  final String hargaBeliPerKg;
  final String stokTerkiniKg;

  double get hargaBeliPerKgAsDouble => parseDecimal(hargaBeliPerKg);

  double get stokTerkiniKgAsDouble => parseDecimal(stokTerkiniKg);

  factory WasteCategory.fromJson(Map<String, dynamic> json) {
    return WasteCategory(
      id: json['id'] as int,
      nama: json['nama'] as String,
      hargaBeliPerKg: json['harga_beli_per_kg']?.toString() ?? '0.00',
      stokTerkiniKg: json['stok_terkini_kg']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'harga_beli_per_kg': hargaBeliPerKg,
        'stok_terkini_kg': stokTerkiniKg,
      };

  static List<WasteCategory> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map(
          (item) =>
              WasteCategory.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
