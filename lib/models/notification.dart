/// Model for in-app notification items.
///
/// These are distinct from announcements (pengumuman).
/// Notifications are user-specific: new deposit, pickup status change,
/// withdrawal approved/rejected, reward redemption processed, etc.
class AppNotification {
  final int id;
  final String judul;
  final String deskripsi;
  final String? kategori;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.kategori,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      judul: json['judul'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      kategori: json['kategori'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  static List<AppNotification> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      judul: judul,
      deskripsi: deskripsi,
      kategori: kategori,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
