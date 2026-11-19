import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_cehat_mobile/providers/app_providers.dart';
import 'package:si_cehat_mobile/screens/home/widgets/nutrition_daily_card.dart';

class _AnalyzingNutritionProvider extends NutritionProvider {
  _AnalyzingNutritionProvider() : super(autoLoad: false);

  @override
  bool get isAnalyzingPhoto => true;

  @override
  Future<void> loadSummary(String childId, String date) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows a processing indicator while the photo is analysed', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nutritionProvider.overrideWith(
            (ref) => _AnalyzingNutritionProvider(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: NutritionDailyCard(
              childId: '1',
              onPhoto: () {},
              onDetail: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Menganalisis foto...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
