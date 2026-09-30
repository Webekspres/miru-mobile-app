import 'package:flutter/material.dart';

/// Ikon & warna per kategori notifikasi — dipakai daftar notifikasi dan
/// banner push saat aplikasi terbuka.
class NotifStyle {
  const NotifStyle(this.icon, this.color);

  final IconData icon;
  final Color color;

  Color get background => color.withValues(alpha: 0.12);
}

NotifStyle notifStyleFor(String? kategori) {
  switch (kategori) {
    case 'penjemputan':
      return const NotifStyle(Icons.local_shipping_rounded, Color(0xFF16A34A));
    case 'jadwal_jemput':
      return const NotifStyle(Icons.event_available_rounded, Color(0xFF0D9488));
    case 'setoran':
      return const NotifStyle(Icons.savings_rounded, Color(0xFF059669));
    case 'penarikan':
      return const NotifStyle(Icons.payments_rounded, Color(0xFF2563EB));
    case 'penukaran':
      return const NotifStyle(Icons.card_giftcard_rounded, Color(0xFF9333EA));
    case 'pengaduan':
      return const NotifStyle(Icons.support_agent_rounded, Color(0xFFEA580C));
    case 'harga':
      return const NotifStyle(Icons.trending_up_rounded, Color(0xFFD97706));
    case 'pengumuman':
      return const NotifStyle(Icons.campaign_rounded, Color(0xFF4F46E5));
    default:
      return const NotifStyle(Icons.notifications_rounded, Color(0xFF64748B));
  }
}

/// Kategori yang mengubah saldo/poin/status penjemputan (perlu muat ulang beranda).
bool notifChangesHome(String? kategori) =>
    const {'setoran', 'penjemputan', 'penarikan', 'penukaran'}.contains(kategori);
