import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:si_cehat_mobile/core/theme/app_theme.dart';
import 'package:si_cehat_mobile/core/widgets/calm_widgets.dart';
import 'package:si_cehat_mobile/screens/home/home_screen.dart';
import 'package:si_cehat_mobile/screens/menu/meal_plan_screen.dart';
import 'package:si_cehat_mobile/screens/shell/main_shell_screen.dart';

/// Guards the shell chrome: the bottom bar must keep its compact height and
/// must never leak into pushed routes (which render full-screen).
void main() {
  void drainErrors(WidgetTester tester) {
    while (tester.takeException() != null) {}
  }

  testWidgets('bottom nav keeps its height and hides on pushed routes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
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
          home: const MainShellScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    drainErrors(tester);

    expect(find.byType(AppBottomNav), findsOneWidget);
    expect(tester.getSize(find.byType(AppBottomNav)).height, 62);

    final ctx = tester.element(find.byType(HomeScreen));
    Navigator.of(
      ctx,
    ).push(MaterialPageRoute(builder: (_) => const MealPlanScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    drainErrors(tester);

    expect(find.byType(MealPlanScreen), findsOneWidget);
    expect(find.byType(AppBottomNav), findsNothing);
  });
}
