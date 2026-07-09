import 'json_parsing.dart';

enum WithdrawalStatus {
  menunggu,
  selesai,
  ditolak;

  static WithdrawalStatus fromApiValue(String value) {
    return WithdrawalStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => WithdrawalStatus.menunggu,
    );
  }

  String get apiValue => name;

  String get displayLabel => switch (this) {
        WithdrawalStatus.menunggu => 'Menunggu',
        WithdrawalStatus.selesai => 'Selesai',
        WithdrawalStatus.ditolak => 'Ditolak',
      };
}

class Withdrawal {
  const Withdrawal({
    required this.id,
    required this.nasabah,
    required this.nominal,
    required this.metode,
    required this.status,
    required this.tanggal,
    this.nasabahNama = '',
    this.saldoNasabahBaru,
  });

  final int id;
  final int nasabah;
  final String nasabahNama;
  final String nominal;
  final String metode;
  final WithdrawalStatus status;
  final DateTime tanggal;
  final String? saldoNasabahBaru;

  double get nominalAsDouble => parseDecimal(nominal);

  double? get saldoNasabahBaruAsDouble =>
      saldoNasabahBaru != null ? parseDecimal(saldoNasabahBaru) : null;

  factory Withdrawal.fromJson(Map<String, dynamic> json) {
    return Withdrawal(
      id: json['id'] as int,
      nasabah: json['nasabah'] as int,
      nasabahNama: json['nasabah_nama'] as String? ?? '',
      nominal: json['nominal']?.toString() ?? '0.00',
      metode: json['metode'] as String? ?? 'tunai',
      status: WithdrawalStatus.fromApiValue(
        json['status'] as String? ?? 'menunggu',
      ),
      tanggal: parseDateTime(json['tanggal']),
      saldoNasabahBaru: json['saldo_nasabah_baru']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nasabah': nasabah,
        'nasabah_nama': nasabahNama,
        'nominal': nominal,
        'metode': metode,
        'status': status.apiValue,
        'tanggal': tanggal.toIso8601String(),
        if (saldoNasabahBaru != null) 'saldo_nasabah_baru': saldoNasabahBaru,
      };

  Map<String, dynamic> toCreateJson() => {
        'nominal': nominalAsDouble,
        'metode': metode,
      };

  static List<Withdrawal> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map(
          (item) =>
              Withdrawal.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
