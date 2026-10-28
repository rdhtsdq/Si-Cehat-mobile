import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/data/models/notification_model.dart';

void main() {
  group('NotificationModel backend payload', () {
    test('parses the camelCase shape returned by /api/notifications', () {
      final notification = NotificationModel.fromJson({
        'id': '3a1d45ed-eed0-4fbb-a4e7-83eb6170e3ba',
        'guardianId': 'guardian-1',
        'title': 'Permainan PlayLab selesai',
        'message': 'Piring Sehat Nimbo selesai dengan 100 poin dan 3 bintang.',
        'type': 'GAME',
        'referenceId': 'session-1',
        'isRead': false,
        'createdAt': '2026-10-28T10:30:40.038Z',
      });

      expect(notification.id, '3a1d45ed-eed0-4fbb-a4e7-83eb6170e3ba');
      expect(notification.title, 'Permainan PlayLab selesai');
      expect(notification.type, 'GAME');
      expect(notification.referenceId, 'session-1');
      expect(notification.isRead, isFalse);
      expect(notification.createdAt.toUtc().toIso8601String(),
          '2026-10-28T10:30:40.038Z');
    });

    test('treats a read boolean as read', () {
      final notification = NotificationModel.fromJson({
        'id': 'notif-2',
        'title': 'Pengingat',
        'message': 'Waktunya minum air.',
        'type': 'REMINDER',
        'isRead': true,
        'createdAt': '2026-10-28T10:30:40.038Z',
      });

      expect(notification.isRead, isTrue);
    });
  });
}
