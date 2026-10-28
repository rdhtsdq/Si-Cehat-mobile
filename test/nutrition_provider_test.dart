import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_cehat_mobile/data/local_food_catalog.dart';
import 'package:si_cehat_mobile/data/models/nutrition_model.dart';
import 'package:si_cehat_mobile/providers/nutrition_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NutritionProvider draft', () {
    test('starts with the offline catalog and default target', () {
      final provider = NutritionProvider(autoLoad: false);

      expect(provider.foods, hasLength(22));
      expect(provider.target.values.caloriesKkal, 1650);
      expect(provider.draft, isEmpty);
    });

    test('adds items and sums local draft values', () {
      final provider = NutritionProvider(autoLoad: false);
      final nasi = localFoodCatalog.first;

      provider.addDraft(nasi, weightGram: 150);
      provider.addDraft(nasi, weightGram: 50);

      expect(provider.draft, hasLength(2));
      expect(provider.localDraftTotals.caloriesKkal, 260);
    });

    test('updates and removes draft items', () {
      final provider = NutritionProvider(autoLoad: false);
      final tempe = localFoodCatalog.firstWhere(
        (food) => food.name == 'Tempe Goreng',
      );

      provider.addDraft(tempe, weightGram: 100);
      provider.updateDraftWeight(0, 50);

      expect(provider.draft.first.weightGram, 50);
      expect(provider.localDraftTotals.caloriesKkal, 113);

      provider.removeDraft(0);
      expect(provider.draft, isEmpty);
      expect(provider.localDraftTotals, NutritionValues.zero);
    });

    test('clearDraft resets items and totals', () {
      final provider = NutritionProvider(autoLoad: false);

      provider.addDraft(localFoodCatalog.first);
      provider.clearDraft();

      expect(provider.draft, isEmpty);
      expect(provider.batchTotals, NutritionValues.zero);
    });
  });
}
