import 'deposit_detail.dart';
import 'json_parsing.dart';

class Deposit {
  const Deposit({
    required this.id,
    required this.nasabah,
    required this.tanggal,
    required this.totalNilai,
    required this.status,
    required this.details,
    this.nasabahNama = '',
    this.petugas,
    this.petugasNama,
    this.poinDidapat,
    this.saldoNasabahBaru,
    this.buktiDigital,
  });

  final int id;
  final int nasabah;
  final String nasabahNama;
  final int? petugas;
  final String? petugasNama;
  final DateTime tanggal;
  final String totalNilai;
  final String status;
  final List<DepositDetail> details;
  final int? poinDidapat;
  final String? saldoNasabahBaru;
  final DepositDigitalProof? buktiDigital;

  double get totalNilaiAsDouble => parseDecimal(totalNilai);

  double? get saldoNasabahBaruAsDouble =>
      saldoNasabahBaru != null ? parseDecimal(saldoNasabahBaru) : null;

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      id: json['id'] as int,
      nasabah: json['nasabah'] as int,
      nasabahNama: json['nasabah_nama'] as String? ?? '',
      petugas: json['petugas'] as int?,
      petugasNama: json['petugas_nama'] as String?,
      tanggal: parseDateTime(json['tanggal']),
      totalNilai: json['total_nilai']?.toString() ?? '0.00',
      status: json['status'] as String? ?? 'selesai',
      details: DepositDetail.listFromJson(json['details']),
      poinDidapat: json['poin_didapat'] as int?,
      saldoNasabahBaru: json['saldo_nasabah_baru']?.toString(),
      buktiDigital: json['bukti_digital'] != null
          ? DepositDigitalProof.fromJson(
              Map<String, dynamic>.from(json['bukti_digital'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nasabah': nasabah,
        'nasabah_nama': nasabahNama,
        if (petugas != null) 'petugas': petugas,
        if (petugasNama != null) 'petugas_nama': petugasNama,
        'tanggal': tanggal.toIso8601String(),
        'total_nilai': totalNilai,
        'status': status,
        'details': details.map((detail) => detail.toJson()).toList(),
        if (poinDidapat != null) 'poin_didapat': poinDidapat,
        if (saldoNasabahBaru != null) 'saldo_nasabah_baru': saldoNasabahBaru,
        if (buktiDigital != null) 'bukti_digital': buktiDigital!.toJson(),
      };

  static List<Deposit> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map((item) => Deposit.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}

class DepositDigitalProof {
  const DepositDigitalProof({
    required this.id,
    required this.tanggal,
    required this.totalNilai,
    required this.details,
  });

  final int id;
  final DateTime tanggal;
  final String totalNilai;
  final List<DepositDetail> details;

  double get totalNilaiAsDouble => parseDecimal(totalNilai);

  factory DepositDigitalProof.fromJson(Map<String, dynamic> json) {
    return DepositDigitalProof(
      id: json['id'] as int,
      tanggal: parseDateTime(json['tanggal']),
      totalNilai: json['total_nilai']?.toString() ?? '0.00',
      details: DepositDetail.listFromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tanggal': tanggal.toIso8601String(),
        'total_nilai': totalNilai,
        'details': details.map((detail) => detail.toJson()).toList(),
      };
}
