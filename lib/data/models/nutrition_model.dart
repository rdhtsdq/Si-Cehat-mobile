double _round1(double value) => (value * 10).round() / 10;

class NutritionValues {
  final int caloriesKkal;
  final double carbsGram;
  final double proteinGram;
  final double fatGram;
  final double sugarGram;
  final double fiberGram;

  const NutritionValues({
    this.caloriesKkal = 0,
    this.carbsGram = 0,
    this.proteinGram = 0,
    this.fatGram = 0,
    this.sugarGram = 0,
    this.fiberGram = 0,
  });

  static const NutritionValues zero = NutritionValues();

  factory NutritionValues.fromJson(Map<String, dynamic> json) {
    return NutritionValues(
      caloriesKkal: (json['caloriesKkal'] as num?)?.round() ?? 0,
      carbsGram: (json['carbsGram'] as num?)?.toDouble() ?? 0,
      proteinGram: (json['proteinGram'] as num?)?.toDouble() ?? 0,
      fatGram: (json['fatGram'] as num?)?.toDouble() ?? 0,
      sugarGram: (json['sugarGram'] as num?)?.toDouble() ?? 0,
      fiberGram: (json['fiberGram'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'caloriesKkal': caloriesKkal,
        'carbsGram': carbsGram,
        'proteinGram': proteinGram,
        'fatGram': fatGram,
        'sugarGram': sugarGram,
        'fiberGram': fiberGram,
      };

  /// Scales a per-100 g value to the requested weight.
  NutritionValues scaled(double weightGram) {
    final grams = weightGram.isFinite && weightGram > 0 ? weightGram : 0.0;
    final multiplier = grams / 100;
    return NutritionValues(
      caloriesKkal: (caloriesKkal * multiplier).round(),
      carbsGram: _round1(carbsGram * multiplier),
      proteinGram: _round1(proteinGram * multiplier),
      fatGram: _round1(fatGram * multiplier),
      sugarGram: _round1(sugarGram * multiplier),
      fiberGram: _round1(fiberGram * multiplier),
    );
  }

  NutritionValues operator +(NutritionValues other) {
    return NutritionValues(
      caloriesKkal: caloriesKkal + other.caloriesKkal,
      carbsGram: _round1(carbsGram + other.carbsGram),
      proteinGram: _round1(proteinGram + other.proteinGram),
      fatGram: _round1(fatGram + other.fatGram),
      sugarGram: _round1(sugarGram + other.sugarGram),
      fiberGram: _round1(fiberGram + other.fiberGram),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NutritionValues &&
        other.caloriesKkal == caloriesKkal &&
        other.carbsGram == carbsGram &&
        other.proteinGram == proteinGram &&
        other.fatGram == fatGram &&
        other.sugarGram == sugarGram &&
        other.fiberGram == fiberGram;
  }

  @override
  int get hashCode => Object.hash(
        caloriesKkal,
        carbsGram,
        proteinGram,
        fatGram,
        sugarGram,
        fiberGram,
      );
}

class FoodItem {
  final String id;
  final String name;
  final String? aliases;
  final String category;
  final NutritionValues per100g;
  final String portionDescription;

  const FoodItem({
    required this.id,
    required this.name,
    this.aliases,
    this.category = 'makanan_pokok',
    required this.per100g,
    this.portionDescription = '100 g',
  });

  int get caloriesKkal => per100g.caloriesKkal;
  double get carbsGram => per100g.carbsGram;
  double get proteinGram => per100g.proteinGram;
  double get fatGram => per100g.fatGram;
  double get sugarGram => per100g.sugarGram;
  double get fiberGram => per100g.fiberGram;

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Makanan',
      aliases: json['aliases'] as String?,
      category: json['category'] as String? ?? 'makanan_pokok',
      per100g: NutritionValues.fromJson(json),
      portionDescription:
          json['portionDescription'] as String? ?? '100 g',
    );
  }
}

class NutritionTarget {
  final NutritionValues values;
  final String source;

  const NutritionTarget({required this.values, this.source = 'AKG'});

  factory NutritionTarget.fromJson(Map<String, dynamic> json) {
    return NutritionTarget(
      values: NutritionValues.fromJson(json),
      source: json['source'] as String? ?? 'AKG',
    );
  }

  static const NutritionTarget akgDefault = NutritionTarget(
    values: NutritionValues(
      caloriesKkal: 1650,
      carbsGram: 250,
      proteinGram: 45,
      fatGram: 55,
      sugarGram: 25,
      fiberGram: 23,
    ),
  );
}

class NutritionEntry {
  final String id;
  final String? foodItemId;
  final String mealSlot;
  final String foodName;
  final String portion;
  final NutritionValues values;

  const NutritionEntry({
    required this.id,
    this.foodItemId,
    required this.mealSlot,
    required this.foodName,
    required this.portion,
    required this.values,
  });

  factory NutritionEntry.fromJson(Map<String, dynamic> json) {
    return NutritionEntry(
      id: json['id']?.toString() ?? '',
      foodItemId: json['foodItemId']?.toString(),
      mealSlot: json['mealSlot'] as String? ?? 'sarapan',
      foodName: json['foodName'] as String? ?? '',
      portion: json['portion'] as String? ?? '',
      values: NutritionValues.fromJson(json),
    );
  }
}

class NutritionSummary {
  final String date;
  final String childId;
  final List<NutritionEntry> entries;
  final NutritionValues totals;
  final NutritionValues target;
  final NutritionValues remaining;
  final Map<String, int?> percent;

  const NutritionSummary({
    required this.date,
    required this.childId,
    required this.entries,
    required this.totals,
    required this.target,
    required this.remaining,
    required this.percent,
  });

  factory NutritionSummary.fromJson(Map<String, dynamic> json) {
    final rawPercent = json['percent'];
    final percent = <String, int?>{};
    if (rawPercent is Map) {
      for (final entry in rawPercent.entries) {
        percent[entry.key.toString()] =
            (entry.value as num?)?.toInt();
      }
    }

    final rawEntries = json['entries'];
    return NutritionSummary(
      date: json['date']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      entries: rawEntries is List
          ? rawEntries
              .whereType<Map<String, dynamic>>()
              .map(NutritionEntry.fromJson)
              .toList()
          : const [],
      totals: json['totals'] is Map<String, dynamic>
          ? NutritionValues.fromJson(json['totals'] as Map<String, dynamic>)
          : NutritionValues.zero,
      target: json['target'] is Map<String, dynamic>
          ? NutritionValues.fromJson(json['target'] as Map<String, dynamic>)
          : NutritionValues.zero,
      remaining: json['remaining'] is Map<String, dynamic>
          ? NutritionValues.fromJson(
              json['remaining'] as Map<String, dynamic>)
          : NutritionValues.zero,
      percent: percent,
    );
  }
}

class NutritionDraftItem {
  final FoodItem food;
  final double weightGram;

  const NutritionDraftItem({required this.food, required this.weightGram});

  NutritionValues get values => food.per100g.scaled(weightGram);
}
