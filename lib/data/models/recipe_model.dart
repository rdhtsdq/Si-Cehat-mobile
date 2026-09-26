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
  });
}
