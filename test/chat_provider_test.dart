import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/core/api/api_client.dart';
import 'package:si_cehat_mobile/data/models/chat_message.dart';
import 'package:si_cehat_mobile/providers/chat_provider.dart';

void main() {
  group('ChatMessage', () {
    test('serializes roles for the wire', () {
      expect(ChatMessage.user('Halo').toJson(), {
        'role': 'user',
        'content': 'Halo',
      });
      expect(ChatMessage.assistant('Hai').toJson(), {
        'role': 'assistant',
        'content': 'Hai',
      });
      expect(ChatMessage.user('x').isUser, isTrue);
      expect(ChatMessage.assistant('x').isUser, isFalse);
    });
  });

  group('ChatProvider', () {
    test('appends the user message and the trimmed reply', () async {
      Map<String, dynamic>? captured;
      final provider = ChatProvider(
        transport: (body) async {
          captured = body;
          return ApiResponse.success({
            'message': '  Makan sayur setiap hari.  ',
          });
        },
      );

      final ok = await provider.send('  Kenapa harus makan sayur?  ');

      expect(ok, isTrue);
      expect(provider.isSending, isFalse);
      expect(provider.error, isNull);
      expect(provider.messages, hasLength(2));
      expect(provider.messages.first.isUser, isTrue);
      expect(provider.messages.first.content, 'Kenapa harus makan sayur?');
      expect(provider.messages.last.isUser, isFalse);
      expect(provider.messages.last.content, 'Makan sayur setiap hari.');
      expect(captured!['messages'], hasLength(1));
    });

    test('only sends the last ${ChatProvider.maxHistory} turns', () async {
      Map<String, dynamic>? captured;
      final provider = ChatProvider(
        transport: (body) async {
          captured = body;
          return ApiResponse.success({'message': 'ok'});
        },
      );

      for (var i = 0; i < 25; i++) {
        await provider.send('pesan $i');
      }

      final payload = captured!['messages'] as List;
      expect(payload, hasLength(ChatProvider.maxHistory));
      // The window slides: the newest user turn is last, older turns drop off.
      expect(payload.last, {'role': 'user', 'content': 'pesan 24'});
      expect(payload.map((m) => m['content']), isNot(contains('pesan 0')));
    });

    test('clamps content to the backend limit', () async {
      final provider = ChatProvider(
        transport: (_) async => ApiResponse.success({'message': 'ok'}),
      );

      await provider.send('a' * 1500);

      expect(
        provider.messages.first.content.length,
        ChatProvider.maxMessageLength,
      );
    });

    test('surfaces a 429 as the daily quota error', () async {
      final provider = ChatProvider(
        transport: (_) async => ApiResponse.failure(
          'Batas pesan harian Si Cehat sudah tercapai. Coba lagi besok ya.',
          statusCode: 429,
        ),
      );

      final ok = await provider.send('Halo');

      expect(ok, isFalse);
      expect(provider.isSending, isFalse);
      expect(provider.isQuotaExceeded, isTrue);
      expect(provider.error, contains('Batas pesan harian'));
      // The user's message stays so it can be retried/read.
      expect(provider.messages, hasLength(1));
    });

    test('treats an empty reply as an error', () async {
      final provider = ChatProvider(
        transport: (_) async => ApiResponse.success({'message': '   '}),
      );

      final ok = await provider.send('Halo');

      expect(ok, isFalse);
      expect(provider.error, isNotNull);
      expect(provider.messages, hasLength(1));
    });

    test('ignores blank input and concurrent sends', () async {
      final completer = Completer<ApiResponse>();
      final provider = ChatProvider(transport: (_) => completer.future);

      expect(await provider.send('   '), isFalse);
      expect(provider.messages, isEmpty);

      final first = provider.send('Halo');
      expect(provider.isSending, isTrue);
      expect(await provider.send('Lagi'), isFalse);
      expect(provider.messages, hasLength(1));

      completer.complete(ApiResponse.success({'message': 'Hai!'}));
      expect(await first, isTrue);
      expect(provider.messages, hasLength(2));
    });

    test('clearConversation resets messages and errors', () async {
      final provider = ChatProvider(
        transport: (_) async => ApiResponse.failure('Gagal', statusCode: 500),
      );

      await provider.send('Halo');
      expect(provider.messages, hasLength(1));
      expect(provider.error, 'Gagal');

      provider.clearConversation();

      expect(provider.messages, isEmpty);
      expect(provider.error, isNull);
      expect(provider.isQuotaExceeded, isFalse);
    });
  });
}
