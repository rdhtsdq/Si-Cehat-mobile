import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/screens/home/home_screen.dart';
import 'package:si_cehat_mobile/screens/menu/meal_plan_screen.dart';
import 'package:si_cehat_mobile/screens/nutrition/nutrition_calculator_screen.dart';

void main() {
  testWidgets('Test HomeScreen for overflows', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Test MealPlanScreen for overflows', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MealPlanScreen(),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Test NutritionCalculatorScreen for overflows', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: NutritionCalculatorScreen(),
      ),
    );
    await tester.pumpAndSettle();
  });
}
