import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/providers/auth_session.dart';
import 'package:mirumobileapp/services/storage_service.dart';

void main() {
  test('markSessionExpired queues a Bahasa Indonesia logout message', () {
    final session = AuthSession(StorageService());
    session.setLoggedIn(true);
    session.markSessionExpired();

    expect(session.isLoggedIn, isFalse);
    expect(
      session.consumeSessionMessage(),
      'Sesi Anda telah berakhir. Silakan masuk kembali.',
    );
    expect(session.consumeSessionMessage(), isNull);
  });
}
