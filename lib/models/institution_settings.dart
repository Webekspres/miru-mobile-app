class InstitutionSettings {
  final String namaInstitusi;
  final String alamat;
  final String kontak;
  final String email;
  final String? logoUrl;
  final String jamOperasional;
  final String pengumuman;

  const InstitutionSettings({
    required this.namaInstitusi,
    this.alamat = '',
    this.kontak = '',
    this.email = '',
    this.logoUrl,
    this.jamOperasional = '',
    this.pengumuman = '',
  });

  factory InstitutionSettings.fromJson(Map<String, dynamic> json) {
    return InstitutionSettings(
      namaInstitusi: json['nama_institusi'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      kontak: json['kontak'] as String? ?? '',
      email: json['email'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      jamOperasional: json['jam_operasional'] as String? ?? '',
      pengumuman: json['pengumuman'] as String? ?? '',
    );
  }
}
