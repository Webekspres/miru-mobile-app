import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/services/push_service.dart';
import 'package:mirumobileapp/services/storage_service.dart';

import '../helpers/test_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('pushTargetRoute', () {
    test('maps backend kategori/event to screens', () {
      expect(pushTargetRoute({'kategori': 'jadwal_jemput'}), '/home/penjemputan/ajukan');
      expect(pushTargetRoute({'event': 'jadwal_jemput'}), '/home/penjemputan/ajukan');
      expect(pushTargetRoute({'kategori': 'penjemputan'}), '/home/penjemputan');
      expect(pushTargetRoute({'kategori': 'setoran'}), '/riwayat');
      expect(pushTargetRoute({'kategori': 'penarikan'}), '/riwayat');
      expect(pushTargetRoute({'kategori': 'harga'}), '/home/info-sampah');
      expect(pushTargetRoute({'kategori': 'pengumuman', 'pengumuman_id': '3'}), '/notifikasi');
      expect(pushTargetRoute({}), '/notifikasi');
    });
  });

  group('without Firebase config', () {
    late ScriptedAdapter adapter;
    late PushService push;

    setUp(() async {
      adapter = ScriptedAdapter((_) => jsonBody({}));
      push = PushService(apiClient: apiClientWith(adapter), storage: StorageService());
      await push.init(); // gagal init di test → push nonaktif, tanpa crash
    });

    test('is unavailable and never calls the API', () async {
      expect(push.isAvailable, isFalse);
      expect(await push.register(), isFalse);
      await push.unregister();
      expect(adapter.calls, 0);
    });

    test('remembers the per-device preference (default on)', () async {
      expect(await push.isEnabled(), isTrue);
      await push.setEnabled(false);
      expect(await push.isEnabled(), isFalse);
      await push.setEnabled(true);
      expect(await push.isEnabled(), isTrue);
      expect(adapter.calls, 0);
    });
  });
}
