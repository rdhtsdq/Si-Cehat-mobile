import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:si_cehat_mobile/core/theme/app_theme.dart';
import 'package:si_cehat_mobile/screens/home/home_screen.dart';
import 'package:si_cehat_mobile/screens/menu/meal_plan_screen.dart';
import 'package:si_cehat_mobile/screens/nutrition/nutrition_calculator_screen.dart';

Widget _createTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

void main() {
  testWidgets('Test HomeScreen for overflows', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_createTestApp(const HomeScreen()));
    await tester.pumpAndSettle();
  });

  testWidgets('Test MealPlanScreen for overflows', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_createTestApp(const MealPlanScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  });

  testWidgets('Test NutritionCalculatorScreen for overflows', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_createTestApp(const NutritionCalculatorScreen()));
    await tester.pumpAndSettle();
  });
}
