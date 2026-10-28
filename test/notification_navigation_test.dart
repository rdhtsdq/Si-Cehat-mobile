import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/core/services/notification_navigation.dart';

void main() {
  group('NotificationNavigation.routeNameForPayload', () {
    test('routes reminder payloads to the reminder screen', () {
      expect(
        NotificationNavigation.routeNameForPayload(
          '{"type":"REMINDER","reminderId":"rem-1"}',
        ),
        'reminder',
      );
    });

    test('routes server event payloads to the notification center', () {
      expect(
        NotificationNavigation.routeNameForPayload(
          '{"type":"GAME","referenceId":"session-1"}',
        ),
        'notifications',
      );
    });

    test('returns null for unknown or invalid payloads', () {
      expect(NotificationNavigation.routeNameForPayload(null), isNull);
      expect(NotificationNavigation.routeNameForPayload(''), isNull);
      expect(NotificationNavigation.routeNameForPayload('not-json'), isNull);
      expect(
        NotificationNavigation.routeNameForPayload('{"type":"UNKNOWN"}'),
        isNull,
      );
    });
  });
}
