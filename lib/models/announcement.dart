class Announcement {
  final int id;
  final String judul;
  final String isi;
  final DateTime tanggal;
  final String status;

  const Announcement({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tanggal,
    this.status = 'aktif',
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] as int,
      judul: json['judul'] as String? ?? '',
      isi: json['isi'] as String? ?? '',
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? 'aktif',
    );
  }

  static List<Announcement> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
