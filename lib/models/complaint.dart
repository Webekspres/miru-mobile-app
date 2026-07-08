import 'json_parsing.dart';

enum ComplaintJenis {
  saldoBelumMasuk,
  penjemputanTerlambat,
  beratTidakSesuai,
  hargaTidakSesuai,
  petugasTidakDatang,
  kesalahanData,
  buktiTidakMuncul;

  static ComplaintJenis fromApiValue(String value) {
    return ComplaintJenis.values.firstWhere(
      (jenis) => jenis.apiValue == value,
      orElse: () => ComplaintJenis.saldoBelumMasuk,
    );
  }

  String get apiValue => switch (this) {
        ComplaintJenis.saldoBelumMasuk => 'saldo_belum_masuk',
        ComplaintJenis.penjemputanTerlambat => 'penjemputan_terlambat',
        ComplaintJenis.beratTidakSesuai => 'berat_tidak_sesuai',
        ComplaintJenis.hargaTidakSesuai => 'harga_tidak_sesuai',
        ComplaintJenis.petugasTidakDatang => 'petugas_tidak_datang',
        ComplaintJenis.kesalahanData => 'kesalahan_data',
        ComplaintJenis.buktiTidakMuncul => 'bukti_tidak_muncul',
      };

  String get displayLabel => switch (this) {
        ComplaintJenis.saldoBelumMasuk => 'Saldo belum masuk',
        ComplaintJenis.penjemputanTerlambat => 'Jadwal penjemputan terlambat',
        ComplaintJenis.beratTidakSesuai => 'Berat sampah tidak sesuai',
        ComplaintJenis.hargaTidakSesuai => 'Harga sampah tidak sesuai',
        ComplaintJenis.petugasTidakDatang => 'Petugas tidak datang',
        ComplaintJenis.kesalahanData => 'Kesalahan data nasabah',
        ComplaintJenis.buktiTidakMuncul => 'Bukti transaksi tidak muncul',
      };
}

enum ComplaintStatus {
  terbuka,
  ditutup;

  static ComplaintStatus fromApiValue(String value) {
    return ComplaintStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => ComplaintStatus.terbuka,
    );
  }

  String get apiValue => name;

  String get displayLabel => switch (this) {
        ComplaintStatus.terbuka => 'Diproses',
        ComplaintStatus.ditutup => 'Selesai',
      };
}

class Complaint {
  const Complaint({
    required this.id,
    required this.nasabah,
    required this.jenisPengaduan,
    required this.keluhan,
    required this.status,
    required this.tanggal,
    this.nasabahNama = '',
    this.tindakLanjut = '',
  });

  final int id;
  final int nasabah;
  final String nasabahNama;
  final ComplaintJenis jenisPengaduan;
  final String keluhan;
  final String tindakLanjut;
  final ComplaintStatus status;
  final DateTime tanggal;

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as int,
      nasabah: json['nasabah'] as int,
      nasabahNama: json['nasabah_nama'] as String? ?? '',
      jenisPengaduan: ComplaintJenis.fromApiValue(
        json['jenis_pengaduan'] as String? ?? 'saldo_belum_masuk',
      ),
      keluhan: json['keluhan'] as String? ?? '',
      tindakLanjut: json['tindak_lanjut'] as String? ?? '',
      status: ComplaintStatus.fromApiValue(
        json['status'] as String? ?? 'terbuka',
      ),
      tanggal: parseDateTime(json['tanggal']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nasabah': nasabah,
        'nasabah_nama': nasabahNama,
        'jenis_pengaduan': jenisPengaduan.apiValue,
        'keluhan': keluhan,
        'tindak_lanjut': tindakLanjut,
        'status': status.apiValue,
        'tanggal': tanggal.toIso8601String(),
      };

  Map<String, dynamic> toCreateJson() => {
        'jenis_pengaduan': jenisPengaduan.apiValue,
        'keluhan': keluhan,
      };

  static List<Complaint> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map(
          (item) => Complaint.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
