import 'package:shared_preferences/shared_preferences.dart';

/// Append-only queue for nutrition batches that could not be saved while
/// offline. Entries are retried when the nutrition screen loads.
class PendingNutritionQueue {
  static const String storageKey = 'pending_nutrition_batches';

  Future<List<String>> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(storageKey) ?? [];
  }

  Future<int> count() async => (await read()).length;

  Future<void> add(String encodedPayload) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(storageKey) ?? [];
    items.add(encodedPayload);
    await prefs.setStringList(storageKey, items);
  }

  Future<void> replace(List<String> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(storageKey, items);
  }
}
