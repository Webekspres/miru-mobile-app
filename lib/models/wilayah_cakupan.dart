import 'package:latlong2/latlong.dart';

import 'json_parsing.dart';

/// Kelurahan/kampung yang bisa dipilih (`WilayahLayanan` aktif).
class KelurahanOption {
  const KelurahanOption({
    required this.id,
    required this.nama,
    this.kode = '',
    this.jenis = '',
  });

  final int id;
  final String nama;
  final String kode;

  /// `kelurahan` atau `kampung`.
  final String jenis;

  /// "Kampung Nayaro" / "Kelurahan Kwamki".
  String get label =>
      jenis == 'kampung' ? 'Kampung $nama' : 'Kelurahan $nama';

  factory KelurahanOption.fromJson(Map<String, dynamic> json) {
    return KelurahanOption(
      id: parseInt(json['id']),
      nama: json['nama'] as String? ?? '',
      kode: json['kode'] as String? ?? '',
      jenis: json['jenis'] as String? ?? '',
    );
  }
}

/// Cakupan layanan MIRU (`GET /api/wilayah/cakupan/`): provinsi, kabupaten
/// dan distrik terkunci ke Distrik Mimika Baru; kelurahan dipilih pengguna.
class WilayahCakupan {
  const WilayahCakupan({
    required this.provinsi,
    required this.kabupaten,
    required this.distrik,
    required this.kelurahan,
    required this.pesan,
    required this.pusatPeta,
    required this.batasSelatanBarat,
    required this.batasUtaraTimur,
    this.zoom = 13,
  });

  final String provinsi;
  final String kabupaten;
  final String distrik;
  final List<KelurahanOption> kelurahan;
  final String pesan;
  final LatLng pusatPeta;
  final LatLng batasSelatanBarat;
  final LatLng batasUtaraTimur;
  final double zoom;

  /// Dipakai sebelum/jika API gagal agar peta tetap bisa tampil.
  static const fallback = WilayahCakupan(
    provinsi: 'Papua Tengah',
    kabupaten: 'Kabupaten Mimika',
    distrik: 'Mimika Baru',
    kelurahan: [],
    pesan:
        'MIRU Bank Sampah hanya melayani warga Distrik Mimika Baru, '
        'Kabupaten Mimika, Papua Tengah.',
    pusatPeta: LatLng(-4.5467, 136.8833),
    batasSelatanBarat: LatLng(-4.70, 136.65),
    batasUtaraTimur: LatLng(-4.25, 137.05),
  );

  bool dalamArea(LatLng titik) =>
      titik.latitude >= batasSelatanBarat.latitude &&
      titik.latitude <= batasUtaraTimur.latitude &&
      titik.longitude >= batasSelatanBarat.longitude &&
      titik.longitude <= batasUtaraTimur.longitude;

  KelurahanOption? kelurahanById(int? id) {
    for (final k in kelurahan) {
      if (k.id == id) return k;
    }
    return null;
  }

  factory WilayahCakupan.fromJson(Map<String, dynamic> json) {
    String nama(dynamic v) =>
        v is Map ? (v['nama'] as String? ?? '') : '';
    final peta = json['peta'] is Map
        ? Map<String, dynamic>.from(json['peta'] as Map)
        : const <String, dynamic>{};
    final pusat = peta['pusat'] is Map ? peta['pusat'] as Map : const {};
    final batas = peta['batas'] is Map ? peta['batas'] as Map : const {};
    final f = fallback;
    return WilayahCakupan(
      provinsi: nama(json['provinsi']),
      kabupaten: nama(json['kabupaten']),
      distrik: nama(json['distrik']),
      kelurahan: (json['kelurahan'] as List? ?? const [])
          .map((e) => KelurahanOption.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pesan: json['pesan'] as String? ?? f.pesan,
      pusatPeta: LatLng(
        parseDecimal(pusat['lat'], defaultValue: f.pusatPeta.latitude),
        parseDecimal(pusat['lng'], defaultValue: f.pusatPeta.longitude),
      ),
      batasSelatanBarat: LatLng(
        parseDecimal(batas['selatan'], defaultValue: f.batasSelatanBarat.latitude),
        parseDecimal(batas['barat'], defaultValue: f.batasSelatanBarat.longitude),
      ),
      batasUtaraTimur: LatLng(
        parseDecimal(batas['utara'], defaultValue: f.batasUtaraTimur.latitude),
        parseDecimal(batas['timur'], defaultValue: f.batasUtaraTimur.longitude),
      ),
      zoom: parseDecimal(peta['zoom'], defaultValue: f.zoom),
    );
  }
}
