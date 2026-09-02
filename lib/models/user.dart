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
    this.noHp = '',
    this.alamat = '',
    this.rt = '',
    this.rw = '',
    this.kelurahanId,
    this.kelurahanNama = '',
    this.latitude,
    this.longitude,
    this.dateJoined,
    this.qr,
    this.avatarUrl,
  });

  final int id;
  final String username;
  final String role;
  final String namaLengkap;
  final String noHp;
  final String alamat;
  final String rt;
  final String rw;

  /// ID wilayah layanan (FK ke WilayahLayanan) — nullable.
  final int? kelurahanId;

  /// Nama kelurahan (read-only dari API).
  final String kelurahanNama;

  /// Koordinat profil (opsional) untuk prefill titik jemput.
  final double? latitude;
  final double? longitude;

  /// Raw saldo string from API, e.g. `"125000.00"`.
  final String saldo;
  final int poin;
  final bool isActive;

  /// False untuk akun admin-created / nomor belum diverifikasi OTP.
  final bool phoneVerified;
  final DateTime? dateJoined;
  final UserQr? qr;
  final String? avatarUrl;

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
      id: parseInt(json['id']),
      username: json['username'] as String,
      role: json['role'] as String? ?? 'nasabah',
      namaLengkap: json['nama_lengkap'] as String? ?? '',
      noHp: json['no_hp'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      rt: json['rt'] as String? ?? '',
      rw: json['rw'] as String? ?? '',
      kelurahanId: json['kelurahan'] == null ? null : parseInt(json['kelurahan']),
      kelurahanNama: json['kelurahan_nama'] as String? ?? '',
      latitude: parseOptionalDecimal(json['latitude']),
      longitude: parseOptionalDecimal(json['longitude']),
      saldo: json['saldo']?.toString() ?? '0.00',
      poin: parseInt(json['poin']),
      isActive: json['is_active'] as bool? ?? true,
      phoneVerified: json['phone_verified'] as bool? ?? true,
      dateJoined: parseOptionalDateTime(json['date_joined']),
      qr: json['qr'] != null
          ? UserQr.fromJson(Map<String, dynamic>.from(json['qr'] as Map))
          : null,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
        'nama_lengkap': namaLengkap,
        'no_hp': noHp,
        'alamat': alamat,
        'rt': rt,
        'rw': rw,
        if (kelurahanId != null) 'kelurahan': kelurahanId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'saldo': saldo,
        'poin': poin,
        'is_active': isActive,
        'phone_verified': phoneVerified,
        if (dateJoined != null) 'date_joined': dateJoined!.toIso8601String(),
        if (qr != null) 'qr': qr!.toJson(),
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

  User copyWith({
    bool? phoneVerified,
    String? noHp,
    String? avatarUrl,
  }) {
    return User(
      id: id,
      username: username,
      role: role,
      namaLengkap: namaLengkap,
      noHp: noHp ?? this.noHp,
      alamat: alamat,
      rt: rt,
      rw: rw,
      kelurahanId: kelurahanId,
      kelurahanNama: kelurahanNama,
      latitude: latitude,
      longitude: longitude,
      saldo: saldo,
      poin: poin,
      isActive: isActive,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      dateJoined: dateJoined,
      qr: qr,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
