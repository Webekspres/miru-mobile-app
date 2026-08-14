import 'package:flutter/material.dart';

/// Waktu Papua (WIT, UTC+9 / Asia/Jayapura) tanpa paket timezone.
///
/// Angka jam di [DateTime] hasil helper ini adalah jam dinding WIT (naive).
class WitDateTime {
  WitDateTime._();

  static const Duration offset = Duration(hours: 9);

  /// Waktu dinding WIT saat ini (komponen jam = WIT, bukan zona perangkat).
  static DateTime now() {
    final utc = DateTime.now().toUtc();
    final shifted = utc.add(offset);
    return DateTime(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
      shifted.millisecond,
    );
  }

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime combine(DateTime date, TimeOfDay time) => DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

  /// ISO 8601 dengan offset WIT, contoh: `2026-08-15T10:00:00+09:00`.
  static String toIsoOffset(DateTime witWall) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${witWall.year.toString().padLeft(4, '0')}-'
        '${two(witWall.month)}-${two(witWall.day)}T'
        '${two(witWall.hour)}:${two(witWall.minute)}:${two(witWall.second)}+09:00';
  }
}
