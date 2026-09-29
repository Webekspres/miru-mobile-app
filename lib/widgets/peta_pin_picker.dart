import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../config/theme.dart';
import '../models/wilayah_cakupan.dart';

/// Peta OpenStreetMap untuk menandai titik rumah / penjemputan.
///
/// Pin selalu di tengah kotak; pengguna cukup menggeser peta sampai pin tepat
/// di rumahnya (titik dilaporkan saat peta berhenti bergeser), atau memakai
/// "Lokasi saya". Geser peta dibatasi sekitar Timika; titik di luar area hanya
/// diberi peringatan (batas yang mengikat adalah pilihan kelurahan).
class PetaPinPicker extends StatefulWidget {
  const PetaPinPicker({
    super.key,
    required this.cakupan,
    required this.latitude,
    required this.longitude,
    required this.onChanged,
    this.height = 220,
    this.showInfo = true,
  });

  final WilayahCakupan cakupan;
  final double? latitude;
  final double? longitude;
  final void Function(double latitude, double longitude) onChanged;

  /// Tinggi peta; `double.infinity` untuk mengisi ruang (layar penuh).
  final double height;

  /// Tampilkan petunjuk & peringatan di bawah peta.
  final bool showInfo;

  @override
  State<PetaPinPicker> createState() => _PetaPinPickerState();
}

class _PetaPinPickerState extends State<PetaPinPicker> {
  final _mapController = MapController();
  bool _locating = false;

  /// Titik terakhir yang dilaporkan dari peta ini — pembaruan prop yang sama
  /// tidak perlu menggerakkan peta lagi.
  LatLng? _reported;

  LatLng? get _pin => widget.latitude != null && widget.longitude != null
      ? LatLng(widget.latitude!, widget.longitude!)
      : null;

  @override
  void didUpdateWidget(covariant PetaPinPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pin = _pin;
    final hadPin = oldWidget.latitude != null && oldWidget.longitude != null;
    // Isi awal dari profil: pusatkan peta ke titik itu.
    if (pin != null && !hadPin && pin != _reported) _moveTo(pin);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _moveTo(LatLng point) {
    try {
      _mapController.move(point, 16);
    } catch (_) {
      // Peta belum siap; initialCenter sudah memakai titik ini.
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _lokasiSaya() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) {
          _showMessage(
            'Layanan lokasi perangkat belum aktif. Aktifkan dulu, lalu coba lagi.',
          );
        }
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showMessage('Izin lokasi diperlukan untuk menandai titik.');
        }
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showMessage(
            'Izin lokasi ditutup. Buka pengaturan aplikasi untuk mengizinkan lokasi.',
          );
        }
        return;
      }
      // Akurasi tinggi sering timeout di dalam ruangan → pakai posisi
      // terakhir yang diketahui perangkat sebagai cadangan.
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 20),
          ),
        );
      } on TimeoutException {
        pos = await Geolocator.getLastKnownPosition();
      }
      if (!mounted) return;
      if (pos == null) {
        _showMessage(
          'Lokasi belum ditemukan. Pastikan GPS aktif, coba di tempat terbuka, lalu ulangi.',
        );
        return;
      }
      final titik = LatLng(pos.latitude, pos.longitude);
      if (!widget.cakupan.dalamArea(titik)) {
        // Peta dibatasi sekitar Timika; titik di luar area tidak bisa dipusatkan.
        _showMessage(
          'Lokasi Anda saat ini di luar area layanan MIRU (Timika). '
          'Geser peta untuk menandai rumah Anda.',
        );
        return;
      }
      _report(titik);
      _moveTo(titik);
    } catch (e) {
      debugPrint('Lokasi saya gagal: $e');
      if (mounted) _showMessage('Tidak dapat mengambil lokasi. Coba lagi.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _report(LatLng titik) {
    if (titik == _reported) return;
    _reported = titik;
    widget.onChanged(titik.latitude, titik.longitude);
  }

  /// Laporkan titik tengah peta setelah gerakan pengguna selesai.
  void _onMapEvent(MapEvent event) {
    if (event.source == MapEventSource.mapController) return;
    final selesai =
        event is MapEventMoveEnd ||
        event is MapEventFlingAnimationEnd ||
        event is MapEventFlingAnimationNotStarted ||
        event is MapEventDoubleTapZoomEnd;
    if (selesai) _report(event.camera.center);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cakupan = widget.cakupan;
    final pin = _pin;
    final diLuarArea = pin != null && !cakupan.dalamArea(pin);

    final isiPeta = Container(
      height: widget.height.isFinite ? widget.height : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: pin ?? cakupan.pusatPeta,
              initialZoom: pin != null ? 16 : cakupan.zoom,
              minZoom: 11,
              maxZoom: 18,
              cameraConstraint: CameraConstraint.containCenter(
                bounds: LatLngBounds(
                  cakupan.batasSelatanBarat,
                  cakupan.batasUtaraTimur,
                ),
              ),
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.drag |
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.doubleTapZoom,
              ),
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.mirubanksampah.app',
              ),
              const RichAttributionWidget(
                showFlutterMapAttribution: false,
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          // Pin tetap di tengah; ujung bawah ikon = titik yang dipilih.
          IgnorePointer(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Icon(
                  Icons.location_on,
                  size: 40,
                  color: pin == null
                      ? AppTheme.errorColor.withValues(alpha: 0.55)
                      : AppTheme.errorColor,
                  shadows: const [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black26,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: FilledButton.tonalIcon(
              onPressed: _locating ? null : _lokasiSaya,
              icon: _locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded, size: 18),
              label: Text(_locating ? 'Mencari…' : 'Lokasi saya'),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.height.isFinite) isiPeta else Expanded(child: isiPeta),
        if (widget.showInfo) ...[
          const SizedBox(height: 8),
          Text(
            pin == null
                ? 'Geser peta sampai pin merah tepat di rumah Anda, atau pakai "Lokasi saya".'
                : 'Lokasi ditandai. Geser peta untuk memindahkannya.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (diLuarArea) ...[
            const SizedBox(height: 6),
            Text(
              'Anda berada di luar area Distrik Mimika Baru. Pastikan titik sudah benar.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Titik ini hanya penanda lokasi, bukan pelacakan perjalanan.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
