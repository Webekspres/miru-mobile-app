import 'json_parsing.dart';

class User {
  const User({
    required this.id,
    required this.username,
    required this.role,
    required this.namaLengkap,
    required this.saldo,
    required this.poin,
    required this.isActive,
    this.nik = '',
    this.noHp = '',
    this.alamat = '',
    this.dateJoined,
    this.qr,
  });

  final int id;
  final String username;
  final String role;
  final String namaLengkap;
  final String nik;
  final String noHp;
  final String alamat;

  /// Raw saldo string from API, e.g. `"125000.00"`.
  final String saldo;
  final int poin;
  final bool isActive;
  final DateTime? dateJoined;
  final UserQr? qr;

  double get saldoAsDouble => parseDecimal(saldo);

  bool get isNasabah => role == 'nasabah';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      role: json['role'] as String? ?? 'nasabah',
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      noHp: json['no_hp'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      saldo: json['saldo']?.toString() ?? '0.00',
      poin: json['poin'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      dateJoined: parseOptionalDateTime(json['date_joined']),
      qr: json['qr'] != null
          ? UserQr.fromJson(Map<String, dynamic>.from(json['qr'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
        'nama_lengkap': namaLengkap,
        'nik': nik,
        'no_hp': noHp,
        'alamat': alamat,
        'saldo': saldo,
        'poin': poin,
        'is_active': isActive,
        if (dateJoined != null) 'date_joined': dateJoined!.toIso8601String(),
        if (qr != null) 'qr': qr!.toJson(),
      };

  static List<User> listFromJson(dynamic json) {
    if (json is! List) return const [];
    return json
        .map((item) => User.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}

class UserQr {
  const UserQr({
    required this.id,
    required this.namaLengkap,
    required this.noHp,
  });

  final int id;
  final String namaLengkap;
  final String noHp;

  factory UserQr.fromJson(Map<String, dynamic> json) {
    return UserQr(
      id: json['id'] as int,
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      noHp: json['no_hp'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama_lengkap': namaLengkap,
        'no_hp': noHp,
      };
}
