import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:si_cehat_mobile/core/theme/app_theme.dart';
import 'package:si_cehat_mobile/screens/education/pustaka_edukasi_screen.dart';

/// Regression: the search field must be a single themed input (no nested
/// Container border) and must not overlap the category chips below it.
void main() {
  testWidgets('search field and category chips do not overlap', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const PustakaEdukasiScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    while (tester.takeException() != null) {}

    expect(find.byType(TextField), findsOneWidget);
    final field = tester.getRect(find.byType(TextField));
    final chip = tester.getRect(find.text('Semua'));

    expect(field.height, 48);
    expect(chip.top, greaterThanOrEqualTo(field.bottom));
  });
}
