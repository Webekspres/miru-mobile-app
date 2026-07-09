import 'json_parsing.dart';

enum RewardRedemptionStatus {
  menunggu,
  selesai;

  static RewardRedemptionStatus fromApiValue(String value) {
    return RewardRedemptionStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => RewardRedemptionStatus.menunggu,
    );
  }

  String get apiValue => name;

  String get displayLabel => switch (this) {
        RewardRedemptionStatus.menunggu => 'Menunggu',
        RewardRedemptionStatus.selesai => 'Selesai',
      };
}

class RewardRedemption {
  const RewardRedemption({
    required this.id,
    required this.nasabah,
    required this.reward,
    required this.status,
    required this.tanggal,
    this.nasabahNama = '',
    this.rewardNama = '',
    this.poinDibutuhkan = 0,
    this.poinNasabahBaru,
    this.stokRewardBaru,
  });

  final int id;
  final int nasabah;
  final String nasabahNama;
  final int reward;
  final String rewardNama;
  final int poinDibutuhkan;
  final RewardRedemptionStatus status;
  final DateTime tanggal;
  final int? poinNasabahBaru;
  final int? stokRewardBaru;

  factory RewardRedemption.fromJson(Map<String, dynamic> json) {
    return RewardRedemption(
      id: json['id'] as int,
      nasabah: json['nasabah'] as int,
      nasabahNama: json['nasabah_nama'] as String? ?? '',
      reward: json['reward'] as int,
      rewardNama: json['reward_nama'] as String? ?? '',
      poinDibutuhkan: json['poin_dibutuhkan'] as int? ?? 0,
      status: RewardRedemptionStatus.fromApiValue(
        json['status'] as String? ?? 'menunggu',
      ),
      tanggal: parseDateTime(json['tanggal']),
      poinNasabahBaru: json['poin_nasabah_baru'] as int?,
      stokRewardBaru: json['stok_reward_baru'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nasabah': nasabah,
        'nasabah_nama': nasabahNama,
        'reward': reward,
        'reward_nama': rewardNama,
        'poin_dibutuhkan': poinDibutuhkan,
        'status': status.apiValue,
        'tanggal': tanggal.toIso8601String(),
        if (poinNasabahBaru != null) 'poin_nasabah_baru': poinNasabahBaru,
        if (stokRewardBaru != null) 'stok_reward_baru': stokRewardBaru,
      };

  static Map<String, dynamic> createPayload(int rewardId) => {
        'reward': rewardId,
      };

  static List<RewardRedemption> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map(
          (item) => RewardRedemption.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
