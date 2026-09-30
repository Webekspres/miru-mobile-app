import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/pickup.dart';
import 'package:mirumobileapp/widgets/notif_style.dart';
import 'package:mirumobileapp/widgets/push_banner.dart';

void main() {
  Future<OverlayState> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox.expand())));
    return tester.state<OverlayState>(find.byType(Overlay).first);
  }

  testWidgets('shows a styled banner that opens its target when tapped', (tester) async {
    final overlay = await pumpHost(tester);
    var opened = false;
    showPushBanner(
      overlay,
      title: '🎉 Selamat! Penjemputan selesai',
      body: 'Hasil timbang Rp12.000 sudah masuk ke saldo Anda.',
      kategori: 'penjemputan',
      onTap: () => opened = true,
    );
    await tester.pumpAndSettle();

    expect(find.text('🎉 Selamat! Penjemputan selesai'), findsOneWidget);
    expect(find.byIcon(Icons.local_shipping_rounded), findsOneWidget);

    await tester.tap(find.text('🎉 Selamat! Penjemputan selesai'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
    expect(find.text('🎉 Selamat! Penjemputan selesai'), findsNothing);
  });

  testWidgets('hides itself after a few seconds', (tester) async {
    final overlay = await pumpHost(tester);
    showPushBanner(overlay, title: '💰 Setoran berhasil', kategori: 'setoran');
    await tester.pumpAndSettle();
    expect(find.text('💰 Setoran berhasil'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('💰 Setoran berhasil'), findsNothing);
  });

  test('each category has its own look; saldo-changing ones refresh home', () {
    expect(notifStyleFor('setoran').icon, Icons.savings_rounded);
    expect(notifStyleFor('penarikan').color, isNot(notifStyleFor('setoran').color));
    expect(notifStyleFor(null).icon, Icons.notifications_rounded);
    expect(notifChangesHome('setoran'), isTrue);
    expect(notifChangesHome('pengumuman'), isFalse);
  });

  test('pickup reads the weighed amount credited to saldo', () {
    final pickup = Pickup.fromJson({
      'id': 1,
      'nasabah': 7,
      'estimasi_berat': '10.00',
      'alamat_jemput': 'Timika',
      'jadwal': '2026-09-30T08:00:00Z',
      'status': 'selesai',
      'setoran_total': '12000.00',
    });
    expect(pickup.setoranTotal, 12000);
  });
}
