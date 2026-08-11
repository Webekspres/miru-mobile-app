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
    this.phoneVerified = true,
    this.nik = '',
    this.noHp = '',
    this.alamat = '',
    this.rt = '',
    this.rw = '',
    this.kelurahanId,
    this.kelurahanNama = '',
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
  final String rt;
  final String rw;

  /// ID wilayah layanan (FK ke WilayahLayanan) — nullable.
  final int? kelurahanId;

  /// Nama kelurahan (read-only dari API).
  final String kelurahanNama;

  /// Raw saldo string from API, e.g. `"125000.00"`.
  final String saldo;
  final int poin;
  final bool isActive;

  /// False untuk akun admin-created / nomor belum diverifikasi OTP.
  final bool phoneVerified;
  final DateTime? dateJoined;
  final UserQr? qr;

  double get saldoAsDouble => parseDecimal(saldo);

  bool get isNasabah => role == 'nasabah';

  /// Alamat profil wajib untuk transaksi (jemput / tarik / tukar).
  /// Maps patokan belum ada di model API — hanya [alamat].
  bool get hasCompleteAddress => alamat.trim().isNotEmpty;

  /// Teks alamat untuk prefill form penjemputan (boleh diubah user).
  String get formattedPickupAddress {
    final parts = <String>[];
    final trimmed = alamat.trim();
    if (trimmed.isNotEmpty) parts.add(trimmed);

    final rtRw = [
      if (rt.trim().isNotEmpty) 'RT ${rt.trim()}',
      if (rw.trim().isNotEmpty) 'RW ${rw.trim()}',
    ].join(' ');
    if (rtRw.isNotEmpty) parts.add(rtRw);

    final kelurahan = kelurahanNama.trim();
    if (kelurahan.isNotEmpty) parts.add(kelurahan);

    return parts.join(', ');
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      role: json['role'] as String? ?? 'nasabah',
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      nik: json['nik'] as String? ?? '',
      noHp: json['no_hp'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      rt: json['rt'] as String? ?? '',
      rw: json['rw'] as String? ?? '',
      kelurahanId: json['kelurahan'] as int?,
      kelurahanNama: json['kelurahan_nama'] as String? ?? '',
      saldo: json['saldo']?.toString() ?? '0.00',
      poin: json['poin'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      phoneVerified: json['phone_verified'] as bool? ?? true,
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
        'rt': rt,
        'rw': rw,
        if (kelurahanId != null) 'kelurahan': kelurahanId,
        'saldo': saldo,
        'poin': poin,
        'is_active': isActive,
        'phone_verified': phoneVerified,
        if (dateJoined != null) 'date_joined': dateJoined!.toIso8601String(),
        if (qr != null) 'qr': qr!.toJson(),
      };

  User copyWith({
    bool? phoneVerified,
    String? noHp,
  }) {
    return User(
      id: id,
      username: username,
      role: role,
      namaLengkap: namaLengkap,
      nik: nik,
      noHp: noHp ?? this.noHp,
      alamat: alamat,
      rt: rt,
      rw: rw,
      kelurahanId: kelurahanId,
      kelurahanNama: kelurahanNama,
      saldo: saldo,
      poin: poin,
      isActive: isActive,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      dateJoined: dateJoined,
      qr: qr,
    );
  }

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
