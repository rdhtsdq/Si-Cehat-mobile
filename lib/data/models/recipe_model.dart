import 'dart:convert';

class RecipeModel {
  final String id;
  final String name;
  final String category; // makanan, minuman, cemilan
  final String summary;
  final String calories;
  final String fiber;
  final String protein;
  final String portion;
  final List<String> ingredients;
  final List<String> instructions;
  final String note;
  final String iconEmoji;
  final String? imageUrl;

  RecipeModel({
    required this.id,
    required this.name,
    required this.category,
    required this.summary,
    required this.calories,
    required this.fiber,
    required this.protein,
    this.portion = '1 Porsi Anak',
    required this.ingredients,
    required this.instructions,
    this.note = 'Resep gizi seimbang untuk keluarga.',
    this.iconEmoji = '🍲',
    this.imageUrl,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    List<String> ing = [];
    if (json['ingredients'] is List) {
      ing = (json['ingredients'] as List).map((e) => e.toString()).toList();
    } else if (json['ingredients'] is String) {
      try {
        final parsed = jsonDecode(json['ingredients']);
        if (parsed is List) ing = parsed.map((e) => e.toString()).toList();
        else ing = [json['ingredients']];
      } catch (_) {
        ing = [json['ingredients']];
      }
    }

    List<String> inst = [];
    if (json['instructions'] is List) {
      inst = (json['instructions'] as List).map((e) => e.toString()).toList();
    } else if (json['instructions'] is String) {
      try {
        final parsed = jsonDecode(json['instructions']);
        if (parsed is List) inst = parsed.map((e) => e.toString()).toList();
        else inst = [json['instructions']];
      } catch (_) {
        inst = [json['instructions']];
      }
    }

    final cat = (json['category'] as String? ?? 'makanan').toLowerCase();
    String emoji = '🍲';
    if (cat.contains('minuman')) emoji = '🥤';
    else if (cat.contains('cemilan') || cat.contains('camilan')) emoji = '🥗';

    return RecipeModel(
      id: json['id']?.toString() ?? '',
      name: (json['title'] ?? json['name'] ?? 'Resep Sehat') as String,
      category: cat,
      summary: (json['description'] ?? json['summary'] ?? 'Pilihan gizi seimbang rendah gula') as String,
      calories: json['caloriesKkal'] != null ? '${json['caloriesKkal']} kkal' : (json['calories'] ?? '150 kkal'),
      fiber: json['fiberGram'] != null ? '${json['fiberGram']} g' : (json['fiber'] ?? '3.0 g'),
      protein: json['proteinGram'] != null ? '${json['proteinGram']} g' : (json['protein'] ?? '6.0 g'),
      portion: json['portion'] ?? '1 Porsi Anak',
      ingredients: ing.isNotEmpty ? ing : ['Bahan alami segar lokal'],
      instructions: inst.isNotEmpty ? inst : ['Masak dengan higienis dan rendah minyak.'],
      note: json['note'] ?? 'Serat dan nutrisi alami mendukung kesehatan anak.',
      iconEmoji: emoji,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
