import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/core/services/push_notification_service.dart';

void main() {
  group('PushMessage', () {
    test('parses a foreground/data payload', () {
      final message = PushMessage.fromData({
        'title': 'Permainan selesai',
        'body': 'Kamu mendapat 75 XP',
        'type': 'GAME',
        'referenceId': 'session-1',
      });

      expect(message.title, 'Permainan selesai');
      expect(message.body, 'Kamu mendapat 75 XP');
      expect(message.type, 'GAME');
      expect(message.referenceId, 'session-1');
    });

    test('uses safe defaults for missing fields', () {
      final message = PushMessage.fromData({});

      expect(message.title, 'Notifikasi Si Cehat');
      expect(message.body, '');
      expect(message.type, isNull);
    });

  });
}
