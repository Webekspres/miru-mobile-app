import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/announcement.dart';
import '../models/api_exception.dart';
import '../providers/home_provider.dart';
import '../providers/pengumuman_provider.dart';

/// Banner H-3: “Harga akan berubah pada tanggal …”
///
/// Sembunyi saat `now >= tanggalBerlaku`. Sumber utama: price-history;
/// jika 403, jatuh ke pengumuman berjudul “Perubahan Harga”.
class HargaBerlakuBanner extends StatefulWidget {
  const HargaBerlakuBanner({super.key});

  @override
  State<HargaBerlakuBanner> createState() => _HargaBerlakuBannerState();
}

class _HargaBerlakuBannerState extends State<HargaBerlakuBanner> {
  DateTime? _tanggalBerlaku;
  bool _showWithoutDate = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final home = context.read<HomeProvider>();
    if (home.categories.isEmpty) {
      await home.loadCategoriesOnly();
    }
    if (!mounted) return;

    try {
      final tanggal = await home.fetchEarliestUpcomingTanggalBerlaku();
      if (!mounted) return;
      setState(() {
        _tanggalBerlaku = _upcomingOrNull(tanggal);
        _showWithoutDate = false;
        _loaded = true;
      });
    } on DioException catch (e) {
      if (_isForbidden(e)) {
        await _fallbackPengumuman();
        return;
      }
      if (mounted) setState(() => _loaded = true);
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  Future<void> _fallbackPengumuman() async {
    final pengumuman = context.read<PengumumanProvider>();
    if (pengumuman.announcements.isEmpty) {
      await pengumuman.loadPengumuman(silent: true);
    }
    if (!mounted) return;

    DateTime? earliest;
    var hasAktifTanpaTanggal = false;
    for (final item in pengumuman.announcements) {
      if (!_isPerubahanHargaAktif(item)) continue;
      final parsed = parseTanggalDariIsiPengumuman(item.isi);
      if (parsed == null) {
        hasAktifTanpaTanggal = true;
        continue;
      }
      if (_upcomingOrNull(parsed) != null) {
        if (earliest == null || parsed.isBefore(earliest)) {
          earliest = parsed;
        }
      }
    }

    setState(() {
      _tanggalBerlaku = earliest;
      _showWithoutDate = earliest == null && hasAktifTanpaTanggal;
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();

    final tanggal = _upcomingOrNull(_tanggalBerlaku);
    if (tanggal == null && !_showWithoutDate) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final text = tanggal != null
        ? 'Harga akan berubah pada tanggal '
            '${DateFormat('d MMMM yyyy', 'id_ID').format(tanggal)}.'
        : 'Harga akan berubah. Cek menu Pengumuman untuk tanggal berlakunya.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 18,
              color: Color(0xFF92400E),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF78350F),
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime? _upcomingOrNull(DateTime? value) {
  if (value == null) return null;
  return value.isAfter(DateTime.now()) ? value : null;
}

bool _isForbidden(DioException e) {
  if (e.response?.statusCode == 403) return true;
  final err = e.error;
  return err is ApiException && err.statusCode == 403;
}

bool _isPerubahanHargaAktif(Announcement item) {
  if (!item.judul.contains('Perubahan Harga')) return false;
  return item.status.toLowerCase() == 'aktif';
}

/// Parses tanggal berlaku from auto-pengumuman isi, e.g.
/// “mulai berlaku pada 14 Agustus 2026 15:00 WIT”.
@visibleForTesting
DateTime? parseTanggalDariIsiPengumuman(String isi) {
  final iso = RegExp(
    r'(\d{4}-\d{2}-\d{2}(?:[T ]\d{2}:\d{2}(?::\d{2})?)?)',
  ).firstMatch(isi);
  if (iso != null) {
    return DateTime.tryParse(iso.group(1)!);
  }

  final long = RegExp(
    r'(\d{1,2})\s+'
    r'(januari|februari|maret|april|mei|juni|juli|agustus|september|'
    r'oktober|november|desember|january|february|march|april|may|june|'
    r'july|august|september|october|november|december)\s+'
    r'(\d{4})(?:\s+(\d{1,2}):(\d{2}))?',
    caseSensitive: false,
  ).firstMatch(isi);
  if (long == null) return null;

  final month = _bulanIdEn[long.group(2)!.toLowerCase()];
  if (month == null) return null;
  return DateTime(
    int.parse(long.group(3)!),
    month,
    int.parse(long.group(1)!),
    int.tryParse(long.group(4) ?? '') ?? 0,
    int.tryParse(long.group(5) ?? '') ?? 0,
  );
}

const _bulanIdEn = <String, int>{
  'januari': 1,
  'january': 1,
  'februari': 2,
  'february': 2,
  'maret': 3,
  'march': 3,
  'april': 4,
  'mei': 5,
  'may': 5,
  'juni': 6,
  'june': 6,
  'juli': 7,
  'july': 7,
  'agustus': 8,
  'august': 8,
  'september': 9,
  'oktober': 10,
  'october': 10,
  'november': 11,
  'desember': 12,
  'december': 12,
};
