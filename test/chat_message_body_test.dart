import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/screens/chat/widgets/chat_message_body.dart';

const TextStyle _style = TextStyle(fontSize: 12, color: Colors.black);

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

Iterable<TextSpan> _flatten(InlineSpan span) sync* {
  yield span as TextSpan;
  final children = span.children;
  if (children == null) return;
  for (final child in children) {
    yield* _flatten(child);
  }
}

void main() {
  testWidgets('renders bullet lists with one marker per item', (tester) async {
    await tester.pumpWidget(
      _app(
        const ChatMessageBody(
          content: 'Menu sarapan:\n- Nasi merah\n- Telur rebus',
          style: _style,
        ),
      ),
    );

    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('Nasi merah', findRichText: true), findsOneWidget);
    expect(find.text('Telur rebus', findRichText: true), findsOneWidget);
  });

  testWidgets('renders numbered lists with their original numbers', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const ChatMessageBody(
          content: '1. Minum air putih\n2. Kurangi gula',
          style: _style,
        ),
      ),
    );

    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('Kurangi gula', findRichText: true), findsOneWidget);
  });

  testWidgets('highlights bold spans and headings', (tester) async {
    await tester.pumpWidget(
      _app(
        const ChatMessageBody(
          content: '## Catatan\nHindari **gula berlebih** setiap hari.',
          style: _style,
        ),
      ),
    );

    final spans = tester
        .widgetList<RichText>(find.byType(RichText))
        .expand((rich) => _flatten(rich.text))
        .toList();

    final bold = spans.where(
      (span) =>
          span.text == 'gula berlebih' &&
          span.style?.fontWeight == FontWeight.w700,
    );
    final heading = spans.where(
      (span) =>
          span.text == 'Catatan' && span.style?.fontWeight == FontWeight.w700,
    );

    expect(bold, hasLength(1));
    expect(heading, hasLength(1));
  });

  testWidgets('leaves user text untouched', (tester) async {
    await tester.pumpWidget(
      _app(
        const ChatMessageBody(
          content: '**jangan** diubah\n- bukan list',
          isUser: true,
          style: _style,
        ),
      ),
    );

    expect(find.text('**jangan** diubah\n- bukan list'), findsOneWidget);
    expect(find.text('•'), findsNothing);
  });
}
