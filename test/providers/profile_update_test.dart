import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/user.dart';
import 'package:mirumobileapp/providers/profile_provider.dart';

import '../helpers/test_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('clearing RT/RW is sent so the old value is really removed', () async {
    Map<String, dynamic>? sent;
    final adapter = ScriptedAdapter((options) {
      if (options.method == 'PATCH') {
        sent = Map<String, dynamic>.from(
          options.data is String ? jsonDecode(options.data as String) : options.data as Map,
        );
      }
      return jsonBody(userJson());
    });
    final profile = ProfileProvider(apiClient: apiClientWith(adapter))
      ..hydrateFrom(User.fromJson({...userJson(), 'rt': '003', 'rw': '004'}));

    final ok = await profile.updateProfile(
      namaLengkap: 'Budi',
      noHp: '081234567890',
      alamat: 'Jl. Papua 1',
      rt: '',
      rw: '',
    );

    expect(ok, isTrue);
    expect(sent?['rt'], '');
    expect(sent?['rw'], '');
  });
}
