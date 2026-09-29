import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/user.dart';
import 'package:mirumobileapp/providers/profile_provider.dart';
import 'package:mirumobileapp/providers/wilayah_provider.dart';
import 'package:mirumobileapp/screens/profile/edit_profile_screen.dart';
import 'package:provider/provider.dart';

import '../helpers/test_http.dart';

void main() {
  late ScriptedAdapter adapter;
  late List<String> patches;

  Future<void> openEditor(
    WidgetTester tester, {
    Map<String, dynamic> userExtra = const {},
  }) async {
    patches = [];
    adapter = ScriptedAdapter((options) {
      if (options.path.endsWith('/wilayah/cakupan/')) {
        return jsonBody({
          'provinsi': {'nama': 'Papua Tengah'},
          'kabupaten': {'nama': 'Kabupaten Mimika'},
          'distrik': {'nama': 'Mimika Baru'},
          'kelurahan': [
            {'id': 2, 'nama': 'Kwamki', 'jenis': 'kelurahan'},
          ],
          'pesan': 'MIRU hanya melayani warga Distrik Mimika Baru.',
        });
      }
      if (options.method == 'PATCH') {
        patches.add(options.path);
        return jsonBody(userJson(nama: 'Budi Baru'));
      }
      return jsonBody({});
    });
    final api = apiClientWith(adapter);
    final user = User.fromJson({...userJson(), ...userExtra});
    final profile = ProfileProvider(apiClient: api)..hydrateFrom(user);

    await tester.binding.setSurfaceSize(const Size(420, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: profile),
        ChangeNotifierProvider(create: (_) => WilayahProvider(apiClient: api)),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => EditProfileScreen(initialUser: user),
                )),
                child: const Text('buka'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profil'), findsOneWidget);
  }

  Future<void> pressBack(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
  }

  testWidgets('leaves directly when nothing changed', (tester) async {
    await openEditor(tester);
    await pressBack(tester);

    expect(find.text('Perubahan belum disimpan'), findsNothing);
    expect(find.text('Edit Profil'), findsNothing);
  });

  testWidgets('asks before leaving; "Tidak" discards', (tester) async {
    await openEditor(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Budi Baru');
    await pressBack(tester);

    expect(find.text('Perubahan belum disimpan'), findsOneWidget);
    await tester.tap(find.text('Tidak'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profil'), findsNothing);
    expect(patches, isEmpty);
  });

  testWidgets('dismissing the dialog keeps the user on the form', (tester) async {
    await openEditor(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Budi Baru');
    await pressBack(tester);

    await tester.tapAt(const Offset(5, 5)); // di luar dialog
    await tester.pumpAndSettle();

    expect(find.text('Perubahan belum disimpan'), findsNothing);
    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Budi Baru'), findsOneWidget);
  });

  testWidgets('"Simpan" saves then leaves', (tester) async {
    await openEditor(tester);
    await tester.enterText(find.byType(TextFormField).first, 'Budi Baru');
    await tester.enterText(find.byType(TextFormField).at(1), '081234567890');
    await pressBack(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    expect(patches, ['/users/1/']);
    expect(find.text('Edit Profil'), findsNothing);
  });

  testWidgets('email is read-only; changing it goes through the verified flow', (tester) async {
    await openEditor(
      tester,
      userExtra: {'email': 'admin@mirubanksampah.id', 'email_verified': true},
    );

    final field = tester.widget<TextField>(
      find.descendant(
        of: find.widgetWithText(TextFormField, 'admin@mirubanksampah.id'),
        matching: find.byType(TextField),
      ),
    );
    expect(field.enabled, isFalse);
    expect(find.text('Ganti email'), findsOneWidget);
    expect(
      find.text('Mengganti email memerlukan kata sandi dan kode OTP ke email baru.'),
      findsOneWidget,
    );
  });

  testWidgets('offers to add an email when there is none', (tester) async {
    await openEditor(tester);

    expect(find.text('Tambah email'), findsOneWidget);
    expect(find.text('Belum ada email'), findsOneWidget);
  });
}
