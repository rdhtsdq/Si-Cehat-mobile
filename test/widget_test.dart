import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/main.dart';

void main() {
  testWidgets('Si Cehat Mobile splash smoke test', (WidgetTester tester) async {
    // Build SiCehatApp and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: SiCehatApp()));

    // Verify that splash screen displays branding immediately
    expect(find.text('Si Cehat'), findsOneWidget);
    expect(find.textContaining('Sistem Cerdas Anak Sehat'), findsOneWidget);

    // Advance the timer past Future.delayed in splash
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
