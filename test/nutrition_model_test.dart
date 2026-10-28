import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/data/local_food_catalog.dart';
import 'package:si_cehat_mobile/data/models/nutrition_model.dart';

void main() {
  group('NutritionValues', () {
    test('scales per-100g values to the requested weight', () {
      const values = NutritionValues(
        caloriesKkal: 130,
        carbsGram: 28,
        proteinGram: 2.7,
        fatGram: 0.3,
        sugarGram: 0.1,
        fiberGram: 0.4,
      );

      final scaled = values.scaled(150);

      expect(scaled.caloriesKkal, 195);
      expect(scaled.carbsGram, 42);
      expect(scaled.proteinGram, 4.1);
      expect(scaled.fatGram, 0.5);
      expect(scaled.sugarGram, 0.2);
      expect(scaled.fiberGram, 0.6);
    });

    test('returns zeroes for zero or negative weight', () {
      const values = NutritionValues(caloriesKkal: 130, carbsGram: 28);

      expect(values.scaled(0), NutritionValues.zero);
      expect(values.scaled(-5), NutritionValues.zero);
    });

    test('adds two nutrient sets', () {
      const a = NutritionValues(caloriesKkal: 100, proteinGram: 4.1);
      const b = NutritionValues(caloriesKkal: 50, proteinGram: 2.2);

      final total = a + b;

      expect(total.caloriesKkal, 150);
      expect(total.proteinGram, 6.3);
    });
  });

  group('Nutrition parsing', () {
    test('parses a FoodItem from the catalog response', () {
      final food = FoodItem.fromJson({
        'id': 'food-1',
        'name': 'Nasi Putih',
        'aliases': 'nasi',
        'category': 'makanan_pokok',
        'caloriesKkal': 130,
        'carbsGram': 28,
        'proteinGram': 2.7,
        'fatGram': 0.3,
        'sugarGram': 0.1,
        'fiberGram': 0.4,
        'portionDescription': '1 centong (100 g)',
      });

      expect(food.name, 'Nasi Putih');
      expect(food.caloriesKkal, 130);
      expect(food.per100g.carbsGram, 28);
      expect(food.portionDescription, '1 centong (100 g)');
    });

    test('parses a summary including null percentages', () {
      final summary = NutritionSummary.fromJson({
        'date': '2026-10-28',
        'childId': 'child-1',
        'entries': [
          {
            'id': 'entry-1',
            'mealSlot': 'sarapan',
            'foodName': 'Nasi Putih',
            'portion': '150 g',
            'caloriesKkal': 195,
            'carbsGram': 42,
            'proteinGram': 4.1,
            'fatGram': 0.5,
            'sugarGram': 0.2,
            'fiberGram': 0.6,
          }
        ],
        'totals': {'caloriesKkal': 195, 'carbsGram': 42},
        'target': {'caloriesKkal': 1650, 'carbsGram': 250},
        'remaining': {'caloriesKkal': 1455, 'carbsGram': 208},
        'percent': {'caloriesKkal': 12, 'fiberGram': null},
      });

      expect(summary.entries, hasLength(1));
      expect(summary.entries.first.foodName, 'Nasi Putih');
      expect(summary.totals.caloriesKkal, 195);
      expect(summary.target.caloriesKkal, 1650);
      expect(summary.percent['caloriesKkal'], 12);
      expect(summary.percent['fiberGram'], isNull);
    });

    test('parses an AKG target', () {
      final target = NutritionTarget.fromJson({
        'caloriesKkal': 1650,
        'carbsGram': 250,
        'proteinGram': 45,
        'fatGram': 55,
        'sugarGram': 25,
        'fiberGram': 23,
        'source': 'AKG',
      });

      expect(target.values.caloriesKkal, 1650);
      expect(target.source, 'AKG');
    });
  });

  group('Local catalog', () {
    test('contains 22 offline foods', () {
      expect(localFoodCatalog, hasLength(22));
    });

    test('draft item scales its food values', () {
      final item = NutritionDraftItem(
        food: localFoodCatalog.first,
        weightGram: 150,
      );

      expect(item.values.caloriesKkal, 195);
    });
  });
}
