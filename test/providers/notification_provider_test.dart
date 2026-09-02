import 'package:flutter_test/flutter_test.dart';
import 'package:mirumobileapp/providers/notification_provider.dart';

import '../helpers/test_http.dart';

List<Map<String, dynamic>> _items({required bool firstRead}) => [
      {
        'id': 1,
        'judul': 'Setoran masuk',
        'deskripsi': 'Saldo bertambah',
        'is_read': firstRead,
        'created_at': '2026-09-01T00:00:00Z',
      },
      {
        'id': 2,
        'judul': 'Jemput dijadwalkan',
        'deskripsi': 'Petugas berangkat',
        'is_read': false,
        'created_at': '2026-09-02T00:00:00Z',
      },
    ];

void main() {
  test('unread badge counts unread rows', () async {
    final provider = NotificationProvider(
      apiClient: apiClientWith(
        ScriptedAdapter((_) => jsonBody(_items(firstRead: false))),
      ),
    );

    await provider.loadNotifications();

    expect(provider.unreadCount, 2);
  });

  test('markAsRead drops the badge by one', () async {
    final provider = NotificationProvider(
      apiClient: apiClientWith(
        ScriptedAdapter((options) {
          if (options.path.contains('/read/')) {
            return jsonBody({'ok': true});
          }
          return jsonBody(_items(firstRead: false));
        }),
      ),
    );
    await provider.loadNotifications();
    expect(provider.unreadCount, 2);

    await provider.markAsRead(1);

    expect(provider.unreadCount, 1);
    expect(provider.notifications.firstWhere((n) => n.id == 1).isRead, isTrue);
  });

  test('markAllAsRead clears the badge', () async {
    final provider = NotificationProvider(
      apiClient: apiClientWith(
        ScriptedAdapter((options) {
          if (options.path.contains('mark-all-read')) {
            return jsonBody({'ok': true});
          }
          return jsonBody(_items(firstRead: false));
        }),
      ),
    );
    await provider.loadNotifications();

    await provider.markAllAsRead();

    expect(provider.unreadCount, 0);
  });
}
