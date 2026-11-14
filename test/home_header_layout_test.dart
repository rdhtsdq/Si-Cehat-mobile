import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:si_cehat_mobile/core/theme/app_theme.dart';
import 'package:si_cehat_mobile/screens/home/home_screen.dart';

/// Regression: the child summary card must tuck under the green header without
/// covering the greeting.
void main() {
  testWidgets('greeting is not covered by the child summary card', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final greeting = tester.getRect(find.textContaining('Halo,'));
    final card = tester.getRect(find.bySemanticsLabel(RegExp('Profil anak')));

    expect(card.top, greaterThanOrEqualTo(greeting.bottom));
  });
}
