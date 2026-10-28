import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_cehat_mobile/core/services/pending_nutrition_queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('appends entries and reports the count', () async {
    final queue = PendingNutritionQueue();

    await queue.add('{"mealSlot":"sarapan"}');
    await queue.add('{"mealSlot":"siang"}');

    expect(await queue.count(), 2);
    expect(await queue.read(), [
      '{"mealSlot":"sarapan"}',
      '{"mealSlot":"siang"}',
    ]);
  });

  test('replace keeps only the remaining entries', () async {
    final queue = PendingNutritionQueue();

    await queue.add('first');
    await queue.add('second');
    await queue.replace(['second']);

    expect(await queue.read(), ['second']);
    expect(await queue.count(), 1);
  });
}
