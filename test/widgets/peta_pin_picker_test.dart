import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/wilayah_cakupan.dart';
import 'package:mirumobileapp/widgets/peta_pin_picker.dart';

void main() {
  Future<List<List<double>>> pumpPicker(WidgetTester tester, {double? lat, double? lng}) async {
    final reported = <List<double>>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PetaPinPicker(
            cakupan: WilayahCakupan.fallback,
            latitude: lat,
            longitude: lng,
            onChanged: (a, b) => reported.add([a, b]),
          ),
        ),
      ),
    ));
    await tester.pump();
    return reported;
  }

  testWidgets('dragging the map reports the new center under the fixed pin', (tester) async {
    final reported = await pumpPicker(tester);
    expect(find.textContaining('Geser peta sampai pin merah'), findsOneWidget);

    await tester.drag(find.byType(FlutterMap), const Offset(-80, 60));
    await tester.pumpAndSettle();

    expect(reported, isNotEmpty);
    final c = WilayahCakupan.fallback.pusatPeta;
    expect(reported.last[0], isNot(closeTo(c.latitude, 1e-9)));
    expect(reported.last[1], greaterThan(c.longitude)); // geser ke kiri → pusat ke timur
  });

  testWidgets('never shows raw coordinates', (tester) async {
    await pumpPicker(tester, lat: -4.5467, lng: 136.8833);

    expect(find.text('Titik sudah ditandai. Geser peta untuk memindahkannya.'), findsOneWidget);
    expect(find.textContaining('-4.5'), findsNothing);
    expect(find.textContaining('136.8'), findsNothing);
  });
}
