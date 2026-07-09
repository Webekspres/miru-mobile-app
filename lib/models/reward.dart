class Reward {
  const Reward({
    required this.id,
    required this.nama,
    required this.poinDibutuhkan,
    required this.stok,
  });

  final int id;
  final String nama;
  final int poinDibutuhkan;
  final int stok;

  bool isAffordable(int userPoin) => userPoin >= poinDibutuhkan && stok > 0;

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] as int,
      nama: json['nama'] as String,
      poinDibutuhkan: json['poin_dibutuhkan'] as int,
      stok: json['stok'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        'poin_dibutuhkan': poinDibutuhkan,
        'stok': stok,
      };

  static List<Reward> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map((item) => Reward.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
