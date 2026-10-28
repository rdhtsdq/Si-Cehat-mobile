import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/core/services/local_notification_service.dart';

void main() {
  group('LocalNotificationService notification ids', () {
    test('is stable for the same reminder id', () {
      const id = '3a1d45ed-eed0-4fbb-a4e7-83eb6170e3ba';

      expect(
        LocalNotificationService.instance.notificationIdFor(id),
        LocalNotificationService.instance.notificationIdFor(id),
      );
    });

    test('differs for different reminder ids', () {
      expect(
        LocalNotificationService.instance.notificationIdFor('reminder-a'),
        isNot(LocalNotificationService.instance.notificationIdFor('reminder-b')),
      );
    });

    test('stays within the signed 31-bit range', () {
      final id = LocalNotificationService.instance.notificationIdFor(
        'reminder-with-a-long-identifier-1234567890',
      );

      expect(id, greaterThanOrEqualTo(0));
      expect(id, lessThanOrEqualTo(0x7fffffff));
    });
  });
}
