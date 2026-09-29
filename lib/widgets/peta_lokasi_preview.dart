import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/theme.dart';
import '../models/wilayah_cakupan.dart';

/// Peta kecil read-only untuk titik rumah; tombol "Edit" (kiri atas) membuka
/// layar peta penuh untuk memindahkan titik.
class PetaLokasiPreview extends StatelessWidget {
  const PetaLokasiPreview({
    super.key,
    required this.cakupan,
    required this.latitude,
    required this.longitude,
    required this.onEdit,
    this.height = 180,
    this.keterangan,
  });

  final WilayahCakupan cakupan;
  final double? latitude;
  final double? longitude;
  final VoidCallback onEdit;
  final double height;

  /// Teks di bawah peta saat titik sudah ada (default: titik rumah).
  final String? keterangan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pin = latitude != null && longitude != null
        ? LatLng(latitude!, longitude!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                // Titik berubah → bangun ulang agar peta berpusat di titik baru.
                key: ValueKey(pin),
                options: MapOptions(
                  initialCenter: pin ?? cakupan.pusatPeta,
                  initialZoom: pin != null ? 16 : cakupan.zoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.mirubanksampah.app',
                  ),
                  if (pin != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: pin,
                          width: 40,
                          height: 40,
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: AppTheme.errorColor,
                            shadows: [
                              Shadow(
                                blurRadius: 4,
                                color: Colors.black26,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  const RichAttributionWidget(
                    showFlutterMapAttribution: false,
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              if (pin == null)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.white.withValues(alpha: 0.6),
                    child: Center(
                      child: Text(
                        'Titik rumah belum ditandai',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                left: 8,
                child: FilledButton.tonalIcon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                  label: Text(pin == null ? 'Tandai' : 'Edit'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pin == null
              ? 'Ketuk "Tandai" untuk memilih titik rumah di peta.'
              : keterangan ??
                  'Titik rumah sudah ditandai. Ketuk "Edit" untuk memindahkannya.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
