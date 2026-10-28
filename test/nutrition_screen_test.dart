import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_cehat_mobile/data/models/child_model.dart';
import 'package:si_cehat_mobile/providers/app_providers.dart';
import 'package:si_cehat_mobile/screens/nutrition/nutrition_calculator_screen.dart';

class _NoChildProfileProvider extends ProfileProvider {
  @override
  ChildModel? get activeChild => null;

  @override
  Future<void> loadProfiles() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the quick and stack tabs without network loading',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nutritionProvider.overrideWith(
            (ref) => NutritionProvider(autoLoad: false),
          ),
          profileProvider.overrideWith((ref) => _NoChildProfileProvider()),
        ],
        child: const MaterialApp(home: NutritionCalculatorScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Hitung Cepat'), findsOneWidget);
    expect(find.text('Susun Asupan'), findsOneWidget);
    expect(find.byTooltip('Atur Target'), findsOneWidget);
    expect(find.text('Hitung Nilai Gizi'), findsOneWidget);
  });

  testWidgets('switches to the stack tab and shows the empty state',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nutritionProvider.overrideWith(
            (ref) => NutritionProvider(autoLoad: false),
          ),
          profileProvider.overrideWith((ref) => _NoChildProfileProvider()),
        ],
        child: const MaterialApp(home: NutritionCalculatorScreen()),
      ),
    );

    await tester.pump();
    await tester.tap(find.text('Susun Asupan'));
    await tester.pump();

    expect(find.text('Belum ada makanan'), findsOneWidget);
    expect(find.text('Total Asupan'), findsOneWidget);
    expect(find.text('Atur Target'), findsWidgets);
  });
}
