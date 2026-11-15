import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/core/api/api_client.dart';
import 'package:si_cehat_mobile/core/theme/app_theme.dart';
import 'package:si_cehat_mobile/providers/app_providers.dart';
import 'package:si_cehat_mobile/screens/chat/chat_screen.dart';

Widget _app(ChatProvider provider) {
  return ProviderScope(
    overrides: [chatProvider.overrideWith((ref) => provider)],
    child: MaterialApp(theme: AppTheme.lightTheme, home: const ChatScreen()),
  );
}

void main() {
  testWidgets('empty state shows the greeting and suggestion chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        ChatProvider(
          transport: (_) async => ApiResponse.success({'message': 'ok'}),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Tanya Si Cehat'), findsOneWidget);
    expect(find.text('Halo! Aku Si Cehat'), findsOneWidget);
    expect(find.text('Menu sarapan sehat itu apa?'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('a suggestion sends and renders the reply', (tester) async {
    final provider = ChatProvider(
      transport: (_) async => ApiResponse.success({
        'message': 'Sarapan sehat: nasi, telur, dan sayur.',
      }),
    );

    await tester.pumpWidget(_app(provider));
    await tester.pump();

    await tester.tap(find.text('Menu sarapan sehat itu apa?'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Menu sarapan sehat itu apa?'), findsOneWidget);
    expect(find.text('Sarapan sehat: nasi, telur, dan sayur.'), findsOneWidget);
    expect(find.text('Halo! Aku Si Cehat'), findsNothing);
  });

  testWidgets('typing indicator shows while the request is pending', (
    tester,
  ) async {
    final completer = Completer<ApiResponse>();
    final provider = ChatProvider(transport: (_) => completer.future);

    await tester.pumpWidget(_app(provider));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Halo Si Cehat');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(find.text('Si Cehat sedang mengetik…'), findsOneWidget);
    expect(find.text('Halo Si Cehat'), findsOneWidget);

    completer.complete(ApiResponse.success({'message': 'Hai juga!'}));
    await tester.pumpAndSettle();

    expect(find.text('Si Cehat sedang mengetik…'), findsNothing);
    expect(find.text('Hai juga!'), findsOneWidget);
  });

  testWidgets('error banner is dismissible', (tester) async {
    final provider = ChatProvider(
      transport: (_) async => ApiResponse.failure(
        'Batas pesan harian Si Cehat sudah tercapai.',
        statusCode: 429,
      ),
    );

    await tester.pumpWidget(_app(provider));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Halo');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.textContaining('Batas pesan harian'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(find.textContaining('Batas pesan harian'), findsNothing);
  });

  testWidgets('reset button clears the thread', (tester) async {
    final provider = ChatProvider(
      transport: (_) async => ApiResponse.success({'message': 'Hai!'}),
    );

    await tester.pumpWidget(_app(provider));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Halo');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Halo'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Hai!'), findsNothing);
    expect(find.text('Halo! Aku Si Cehat'), findsOneWidget);
  });
}
