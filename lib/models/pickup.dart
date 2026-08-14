import 'package:flutter/material.dart';

import '../utils/wit_datetime.dart';
import 'json_parsing.dart';

enum PickupStatus {
  menunggu,
  disetujui,
  dijadwalkan,
  dalamPerjalanan,
  dijemput,
  selesai,
  ditolak;

  static PickupStatus fromApiValue(String value) {
    return PickupStatus.values.firstWhere(
      (status) => status.apiValue == value,
      orElse: () => PickupStatus.menunggu,
    );
  }

  String get apiValue => switch (this) {
        PickupStatus.menunggu => 'menunggu',
        PickupStatus.disetujui => 'disetujui',
        PickupStatus.dijadwalkan => 'dijadwalkan',
        PickupStatus.dalamPerjalanan => 'dalam_perjalanan',
        PickupStatus.dijemput => 'dijemput',
        PickupStatus.selesai => 'selesai',
        PickupStatus.ditolak => 'ditolak',
      };

  String get displayLabel => switch (this) {
        PickupStatus.menunggu => 'Menunggu Persetujuan',
        PickupStatus.disetujui => 'Disetujui',
        PickupStatus.dijadwalkan => 'Terjadwal',
        PickupStatus.dalamPerjalanan => 'Dalam Perjalanan',
        PickupStatus.dijemput => 'Sampah Diambil',
        PickupStatus.selesai => 'Selesai',
        PickupStatus.ditolak => 'Ditolak',
      };

  Color get badgeColor => switch (this) {
        PickupStatus.menunggu => const Color(0xFFEAB308),
        PickupStatus.disetujui => const Color(0xFF22C55E),
        PickupStatus.dijadwalkan => const Color(0xFF3B82F6),
        PickupStatus.dalamPerjalanan => const Color(0xFFF97316),
        PickupStatus.dijemput => const Color(0xFFA855F7),
        PickupStatus.selesai => const Color(0xFF6B7280),
        PickupStatus.ditolak => const Color(0xFFEF4444),
      };

  bool get isActive => switch (this) {
        PickupStatus.menunggu ||
        PickupStatus.disetujui ||
        PickupStatus.dijadwalkan ||
        PickupStatus.dalamPerjalanan ||
        PickupStatus.dijemput =>
          true,
        PickupStatus.selesai || PickupStatus.ditolak => false,
      };
}

class Pickup {
  const Pickup({
    required this.id,
    required this.nasabah,
    required this.estimasiBerat,
    required this.alamatJemput,
    required this.jadwal,
    required this.status,
    this.nasabahNama = '',
    this.petugas,
    this.petugasNama,
    this.latitude,
    this.longitude,
  });

  final int id;
  final int nasabah;
  final String nasabahNama;
  final int? petugas;
  final String? petugasNama;
  final String estimasiBerat;
  final String alamatJemput;
  final DateTime jadwal;
  final PickupStatus status;
  final double? latitude;
  final double? longitude;

  double get estimasiBeratAsDouble => parseDecimal(estimasiBerat);

  factory Pickup.fromJson(Map<String, dynamic> json) {
    return Pickup(
      id: json['id'] as int,
      nasabah: json['nasabah'] as int,
      nasabahNama: json['nasabah_nama'] as String? ?? '',
      petugas: json['petugas'] as int?,
      petugasNama: json['petugas_nama'] as String?,
      estimasiBerat: json['estimasi_berat']?.toString() ?? '0.00',
      alamatJemput: json['alamat_jemput'] as String? ?? '',
      jadwal: parseDateTime(json['jadwal']),
      status: PickupStatus.fromApiValue(json['status'] as String? ?? 'menunggu'),
      latitude: parseOptionalDecimal(json['latitude']),
      longitude: parseOptionalDecimal(json['longitude']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nasabah': nasabah,
        'nasabah_nama': nasabahNama,
        if (petugas != null) 'petugas': petugas,
        if (petugasNama != null) 'petugas_nama': petugasNama,
        'estimasi_berat': estimasiBerat,
        'alamat_jemput': alamatJemput,
        'jadwal': jadwal.toIso8601String(),
        'status': status.apiValue,
        if (latitude != null) 'latitude': latitude!.toStringAsFixed(6),
        if (longitude != null) 'longitude': longitude!.toStringAsFixed(6),
      };

  Map<String, dynamic> toCreateJson() => {
        'estimasi_berat': estimasiBeratAsDouble,
        'alamat_jemput': alamatJemput,
        'jadwal': WitDateTime.toIsoOffset(jadwal),
        if (latitude != null) 'latitude': latitude!.toStringAsFixed(6),
        if (longitude != null) 'longitude': longitude!.toStringAsFixed(6),
      };

  static List<Pickup> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map((item) => Pickup.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
