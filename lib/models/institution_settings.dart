import 'package:flutter/material.dart';

class InstitutionSettings {
  final String namaInstitusi;
  final String alamat;
  final String kontak;
  final String email;
  final String? logoUrl;
  final String jamOperasional;
  final String? jamBuka;
  final String? jamTutup;
  final String pengumuman;
  final String tentang;
  final String kebijakan;

  const InstitutionSettings({
    required this.namaInstitusi,
    this.alamat = '',
    this.kontak = '',
    this.email = '',
    this.logoUrl,
    this.jamOperasional = '',
    this.jamBuka,
    this.jamTutup,
    this.pengumuman = '',
    this.tentang = '',
    this.kebijakan = '',
  });

  TimeOfDay? get jamBukaTime => parseJam(jamBuka);
  TimeOfDay? get jamTutupTime => parseJam(jamTutup);

  /// Teks jam kerja untuk nasabah, contoh: `08.00–17.00`.
  String get jamKerjaLabel {
    final buka = jamBukaTime;
    final tutup = jamTutupTime;
    if (buka == null || tutup == null) return '';
    return '${_labelJam(buka)}–${_labelJam(tutup)}';
  }

  bool isDiLuarJamKerja(TimeOfDay waktu) {
    final buka = jamBukaTime;
    final tutup = jamTutupTime;
    if (buka == null || tutup == null) return false;
    final menit = waktu.hour * 60 + waktu.minute;
    final menitBuka = buka.hour * 60 + buka.minute;
    final menitTutup = tutup.hour * 60 + tutup.minute;
    return menit < menitBuka || menit > menitTutup;
  }

  factory InstitutionSettings.fromJson(Map<String, dynamic> json) {
    return InstitutionSettings(
      namaInstitusi: json['nama_institusi'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      kontak: json['kontak'] as String? ?? '',
      email: json['email'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      jamOperasional: json['jam_operasional'] as String? ?? '',
      jamBuka: json['jam_buka'] as String?,
      jamTutup: json['jam_tutup'] as String?,
      pengumuman: json['pengumuman'] as String? ?? '',
      tentang: json['tentang'] as String? ?? '',
      kebijakan: json['kebijakan'] as String? ?? '',
    );
  }

  static TimeOfDay? parseJam(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _labelJam(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }
}
