import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/models/user.dart';
import 'package:mirumobileapp/providers/home_provider.dart';

import '../helpers/test_http.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('shows the login poin at once, then the fresh /me/ value', () async {
    final adapter = ScriptedAdapter((options) {
      if (options.path.endsWith('/auth/me/')) return jsonBody(userJson(poin: 910));
      return jsonBody(<dynamic>[]);
    });
    final home = HomeProvider(apiClient: apiClientWith(adapter));
    expect(home.hasData, isFalse);

    home.hydrateFrom(User.fromJson(userJson(poin: 909)));
    expect(home.poin, 909);

    await home.refresh();
    expect(home.poin, 910);
  });

  test('a new login after logout starts from the new user, not 0', () async {
    final adapter = ScriptedAdapter((options) {
      if (options.path.endsWith('/auth/me/')) return jsonBody(userJson(poin: 50));
      return jsonBody(<dynamic>[]);
    });
    final home = HomeProvider(apiClient: apiClientWith(adapter));
    home.hydrateFrom(User.fromJson(userJson(poin: 909)));
    home.clearCache();

    home.hydrateFrom(User.fromJson(userJson(id: 2, poin: 50)));
    expect(home.poin, 50);
  });
}
