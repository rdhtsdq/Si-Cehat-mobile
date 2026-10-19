import 'dart:convert';

class RecipeModel {
  final String id;
  final String name;
  final String category; // makanan, minuman, cemilan
  final String summary;
  final String calories;
  final String fiber;
  final String protein;
  final String carbs;
  final String fat;
  final String sugar;
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
    this.carbs = '20 g',
    this.fat = '4 g',
    this.sugar = '2 g',
    this.portion = '1 Porsi Anak',
    required this.ingredients,
    required this.instructions,
    this.note = 'Resep gizi seimbang untuk keluarga.',
    this.iconEmoji = '\ud83c\udf72',
    this.imageUrl,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    List<String> ing = [];
    if (json['ingredients'] is List) {
      ing = (json['ingredients'] as List).map((e) => e.toString()).toList();
    } else if (json['ingredients'] is String) {
      try {
        final parsed = jsonDecode(json['ingredients']);
        if (parsed is List) {
          ing = parsed.map((e) => e.toString()).toList();
        } else {
          ing = [json['ingredients']];
        }
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
        if (parsed is List) {
          inst = parsed.map((e) => e.toString()).toList();
        } else {
          inst = [json['instructions']];
        }
      } catch (_) {
        inst = [json['instructions']];
      }
    }

    final cat = (json['category'] as String? ?? 'makanan').toLowerCase();
    String emoji = '\ud83c\udf72';
    if (cat.contains('minuman')) {
      emoji = '\ud83e\udd64';
    } else if (cat.contains('cemilan') || cat.contains('camilan')) {
      emoji = '\ud83c\udf4c';
    }

    final carbsVal = json['carbsGram'] != null
        ? '${json['carbsGram']} g'
        : (json['carbs']?.toString() ?? '20 g');
    final fatVal = json['fatGram'] != null
        ? '${json['fatGram']} g'
        : (json['fat']?.toString() ?? '4 g');
    final sugarVal = json['sugarGram'] != null
        ? '${json['sugarGram']} g'
        : (json['sugar']?.toString() ?? '2 g');

    final defaultNote = json['sugarGram'] != null
        ? 'Rendah gula ($sugarVal) & karbohidrat terukur ($carbsVal), mendukung kestabilan glukosa darah dan tumbuh kembang anak.'
        : 'Serat dan nutrisi alami mendukung kesehatan anak.';

    return RecipeModel(
      id: json['id']?.toString() ?? '',
      name: (json['title'] ?? json['name'] ?? 'Resep Sehat') as String,
      category: cat,
      summary:
          (json['description'] ??
                  json['summary'] ??
                  'Pilihan gizi seimbang rendah gula')
              as String,
      calories: json['caloriesKkal'] != null
          ? '${json['caloriesKkal']} kkal'
          : (json['calories']?.toString() ?? '150 kkal'),
      fiber: json['fiberGram'] != null
          ? '${json['fiberGram']} g'
          : (json['fiber']?.toString() ?? '3.0 g'),
      protein: json['proteinGram'] != null
          ? '${json['proteinGram']} g'
          : (json['protein']?.toString() ?? '6.0 g'),
      carbs: carbsVal,
      fat: fatVal,
      sugar: sugarVal,
      portion: json['portion']?.toString() ?? '1 Porsi Anak',
      ingredients: ing.isNotEmpty ? ing : ['Bahan alami segar lokal'],
      instructions: inst.isNotEmpty
          ? inst
          : ['Masak dengan higienis dan rendah minyak.'],
      note: (json['note'] as String?) ?? defaultNote,
      iconEmoji: emoji,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class RecommendedMenuModel {
  final String id;
  final String title;
  final String note;
  final int orderIndex;

  const RecommendedMenuModel({
    required this.id,
    required this.title,
    required this.note,
    this.orderIndex = 0,
  });

  factory RecommendedMenuModel.fromJson(Map<String, dynamic> json) {
    return RecommendedMenuModel(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? '') as String,
      note: (json['note'] ?? '') as String,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    );
  }
}

class MealPlanItemModel {
  final String type;
  final String title;
  final String time;
  final String image;
  final String calories;
  final String protein;
  final String fiber;
  final String carbs;
  final String description;
  final String tips;
  final String? relatedRecipeId;
  final String? relatedRecipeTitle;

  const MealPlanItemModel({
    required this.type,
    required this.title,
    required this.time,
    required this.image,
    required this.calories,
    required this.protein,
    required this.fiber,
    required this.carbs,
    required this.description,
    required this.tips,
    this.relatedRecipeId,
    this.relatedRecipeTitle,
  });

  factory MealPlanItemModel.fromJson(Map<String, dynamic> json) {
    return MealPlanItemModel(
      type: (json['type'] ?? 'Makan Siang') as String,
      title: (json['title'] ?? '') as String,
      time: (json['time'] ?? '12:00') as String,
      image: (json['image'] ?? 'dish-1.png') as String,
      calories: (json['calories'] ?? '250 kkal') as String,
      protein: (json['protein'] ?? '12 g') as String,
      fiber: (json['fiber'] ?? '3.0 g') as String,
      carbs: (json['carbs'] ?? '35 g') as String,
      description: (json['description'] ?? '') as String,
      tips: (json['tips'] ?? '') as String,
      relatedRecipeId: json['relatedRecipeId']?.toString(),
      relatedRecipeTitle: (json['relatedRecipeTitle'] ?? json['recipeKeyword'])
          ?.toString(),
    );
  }
}

class MealPlanDayModel {
  final int dayNumber;
  final String focusTitle;
  final List<MealPlanItemModel> meals;

  const MealPlanDayModel({
    required this.dayNumber,
    required this.focusTitle,
    required this.meals,
  });

  factory MealPlanDayModel.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'] as List<dynamic>? ?? const [];
    return MealPlanDayModel(
      dayNumber: (json['dayNumber'] as num?)?.toInt() ?? 1,
      focusTitle: (json['focusTitle'] ?? 'Gizi Seimbang Harian') as String,
      meals: rawMeals
          .whereType<Map<String, dynamic>>()
          .map(MealPlanItemModel.fromJson)
          .toList(),
    );
  }
}
