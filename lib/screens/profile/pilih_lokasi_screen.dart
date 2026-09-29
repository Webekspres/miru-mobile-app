import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../config/theme.dart';
import '../../models/wilayah_cakupan.dart';
import '../../widgets/peta_pin_picker.dart';

/// Buka [PilihLokasiScreen]; `null` bila pengguna kembali tanpa memilih.
Future<LatLng?> pilihLokasi(
  BuildContext context, {
  required WilayahCakupan cakupan,
  double? latitude,
  double? longitude,
  String title = 'Titik Lokasi Rumah',
}) {
  return Navigator.of(context).push<LatLng>(
    MaterialPageRoute(
      builder: (_) => PilihLokasiScreen(
        cakupan: cakupan,
        latitude: latitude,
        longitude: longitude,
        title: title,
      ),
    ),
  );
}

/// Layar peta penuh untuk memilih titik rumah. Mengembalikan [LatLng] saat
/// pengguna menekan "Gunakan titik ini"; kembali tanpa menyimpan → `null`.
class PilihLokasiScreen extends StatefulWidget {
  const PilihLokasiScreen({
    super.key,
    required this.cakupan,
    this.latitude,
    this.longitude,
    this.title = 'Titik Lokasi Rumah',
  });

  final WilayahCakupan cakupan;
  final double? latitude;
  final double? longitude;
  final String title;

  @override
  State<PilihLokasiScreen> createState() => _PilihLokasiScreenState();
}

class _PilihLokasiScreenState extends State<PilihLokasiScreen> {
  late double? _latitude = widget.latitude;
  late double? _longitude = widget.longitude;

  bool get _adaTitik => _latitude != null && _longitude != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diLuarArea =
        _adaTitik && !widget.cakupan.dalamArea(LatLng(_latitude!, _longitude!));

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PetaPinPicker(
              cakupan: widget.cakupan,
              latitude: _latitude,
              longitude: _longitude,
              height: double.infinity,
              showInfo: false,
              onChanged: (lat, lng) => setState(() {
                _latitude = lat;
                _longitude = lng;
              }),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _adaTitik
                        ? 'Pin merah menandai rumah Anda. Geser peta bila belum tepat.'
                        : 'Geser peta sampai pin merah tepat di rumah Anda, '
                            'atau ketuk "Lokasi saya".',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (diLuarArea) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Titik berada di luar area Distrik Mimika Baru. '
                      'Pastikan titik sudah benar.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Titik ini membantu petugas menemukan rumah Anda saat '
                    'penjemputan. Hanya penanda lokasi, bukan pelacakan perjalanan.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _adaTitik
                        ? () => Navigator.of(context)
                            .pop(LatLng(_latitude!, _longitude!))
                        : null,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Gunakan titik ini'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
