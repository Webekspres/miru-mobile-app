import 'deposit_detail.dart';
import 'json_parsing.dart';

enum ActivityType {
  setoran,
  penarikan,
  penukaranPoin;

  static ActivityType fromApiValue(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => ActivityType.setoran,
    );
  }

  String get apiValue => switch (this) {
        ActivityType.setoran => 'setoran',
        ActivityType.penarikan => 'penarikan',
        ActivityType.penukaranPoin => 'penukaran_poin',
      };

  String get displayLabel => switch (this) {
        ActivityType.setoran => 'Setoran',
        ActivityType.penarikan => 'Penarikan',
        ActivityType.penukaranPoin => 'Penukaran Poin',
      };

  /// Filter value for `GET /api/activity/?jenis=`.
  String? get jenisFilter => switch (this) {
        ActivityType.setoran => 'setoran',
        ActivityType.penarikan => 'penarikan',
        ActivityType.penukaranPoin => 'poin',
      };
}

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.status,
    required this.keterangan,
    required this.tanggal,
    this.nominal,
    this.poin,
    this.petugasNama,
    this.tanggalJemput,
    this.details = const [],
  });

  final int id;
  final ActivityType type;
  final String status;
  final String keterangan;
  final DateTime tanggal;
  final String? nominal;
  final int? poin;
  final String? petugasNama;
  /// Pickup date if the API includes it (`tanggal_jemput` / `jadwal_jemput`).
  final DateTime? tanggalJemput;
  final List<DepositDetail> details;

  double? get nominalAsDouble =>
      nominal != null ? parseDecimal(nominal) : null;

  bool get isCredit => type == ActivityType.setoran;

  bool get isDebit => type == ActivityType.penarikan;

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as int,
      type: ActivityType.fromApiValue(json['type'] as String? ?? 'setoran'),
      status: json['status'] as String? ?? '',
      keterangan: json['keterangan'] as String? ?? '',
      tanggal: parseDateTime(json['tanggal']),
      nominal: json['nominal']?.toString(),
      poin: json['poin'] as int?,
      petugasNama: json['petugas_nama'] as String?,
      tanggalJemput: parseOptionalDateTime(
        json['tanggal_jemput'] ?? json['jadwal_jemput'],
      ),
      details: DepositDetail.listFromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.apiValue,
        'status': status,
        'keterangan': keterangan,
        'tanggal': tanggal.toIso8601String(),
        if (nominal != null) 'nominal': nominal,
        if (poin != null) 'poin': poin,
        if (petugasNama != null) 'petugas_nama': petugasNama,
        if (tanggalJemput != null)
          'tanggal_jemput': tanggalJemput!.toIso8601String(),
        if (details.isNotEmpty)
          'details': details.map((d) => d.toJson()).toList(),
      };

  static List<ActivityItem> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map(
          (item) =>
              ActivityItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
