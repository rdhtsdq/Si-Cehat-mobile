import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../diary/food_diary_screen.dart';

class FoodNutritionItem {
  final String name;
  final String
  category; // makanan_pokok, lauk_pauk, sayuran, buah, minuman_camilan
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;
  final double sugar;
  final String emoji;
  final String portionDescription;

  const FoodNutritionItem({
    required this.name,
    this.category = 'makanan_pokok',
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.fiber,
    this.sugar = 0.0,
    this.emoji = '\ud83e\udd57',
    this.portionDescription = '1 porsi (100g)',
  });

  factory FoodNutritionItem.fromJson(Map<String, dynamic> json) {
    return FoodNutritionItem(
      name: json['name'] as String? ?? 'Makanan',
      category: json['category'] as String? ?? 'makanan_pokok',
      calories: (json['calories'] as num?)?.toInt() ?? 100,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 10.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 5.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 2.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 1.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      emoji: json['emoji'] as String? ?? '\ud83e\udd57',
      portionDescription: json['portionDescription'] as String? ?? '100g',
    );
  }
}

class NutritionCalculatorScreen extends StatefulWidget {
  const NutritionCalculatorScreen({super.key});

  @override
  State<NutritionCalculatorScreen> createState() =>
      _NutritionCalculatorScreenState();
}

class _NutritionCalculatorScreenState extends State<NutritionCalculatorScreen> {
  static const List<FoodNutritionItem> _defaultFoods = [
    FoodNutritionItem(
      name: 'Nasi Putih',
      category: 'makanan_pokok',
      calories: 130,
      carbs: 28.0,
      protein: 2.7,
      fat: 0.3,
      fiber: 0.4,
      sugar: 0.1,
      emoji: '\ud83c\udf5a',
      portionDescription: '1 centong (100g)',
    ),
    FoodNutritionItem(
      name: 'Nasi Merah',
      category: 'makanan_pokok',
      calories: 111,
      carbs: 23.0,
      protein: 2.6,
      fat: 0.9,
      fiber: 1.8,
      sugar: 0.4,
      emoji: '\ud83c\udf5a',
      portionDescription: '1 centong (100g)',
    ),
    FoodNutritionItem(
      name: 'Dada Ayam Rebus',
      category: 'lauk_pauk',
      calories: 165,
      carbs: 0.0,
      protein: 31.0,
      fat: 3.6,
      fiber: 0.0,
      sugar: 0.0,
      emoji: '\ud83c\udf57',
      portionDescription: '1 potong sedang (100g)',
    ),
    FoodNutritionItem(
      name: 'Ayam Goreng',
      category: 'lauk_pauk',
      calories: 260,
      carbs: 1.5,
      protein: 25.0,
      fat: 17.0,
      fiber: 0.0,
      sugar: 0.1,
      emoji: '\ud83c\udf57',
      portionDescription: '1 potong (100g)',
    ),
    FoodNutritionItem(
      name: 'Telur Rebus',
      category: 'lauk_pauk',
      calories: 155,
      carbs: 1.1,
      protein: 13.0,
      fat: 11.0,
      fiber: 0.0,
      sugar: 1.1,
      emoji: '\ud83e\udd5a',
      portionDescription: '2 butir (100g)',
    ),
    FoodNutritionItem(
      name: 'Telur Dadar',
      category: 'lauk_pauk',
      calories: 180,
      carbs: 1.5,
      protein: 12.0,
      fat: 14.0,
      fiber: 0.0,
      sugar: 0.5,
      emoji: '\ud83c\udf73',
      portionDescription: '1 butir besar (100g)',
    ),
    FoodNutritionItem(
      name: 'Tempe Kukus / Bacem',
      category: 'lauk_pauk',
      calories: 193,
      carbs: 9.4,
      protein: 20.8,
      fat: 10.8,
      fiber: 4.8,
      sugar: 0.5,
      emoji: '\ud83e\uddc8',
      portionDescription: '2 potong sedang (100g)',
    ),
    FoodNutritionItem(
      name: 'Tempe Goreng',
      category: 'lauk_pauk',
      calories: 225,
      carbs: 12.0,
      protein: 18.0,
      fat: 15.0,
      fiber: 4.0,
      sugar: 0.5,
      emoji: '\ud83e\uddc8',
      portionDescription: '2 potong sedang (100g)',
    ),
    FoodNutritionItem(
      name: 'Tahu Putih',
      category: 'lauk_pauk',
      calories: 76,
      carbs: 1.9,
      protein: 8.0,
      fat: 4.8,
      fiber: 0.3,
      sugar: 0.5,
      emoji: '\ud83e\uddca',
      portionDescription: '1 kotak (100g)',
    ),
    FoodNutritionItem(
      name: 'Tahu Goreng',
      category: 'lauk_pauk',
      calories: 115,
      carbs: 3.5,
      protein: 9.0,
      fat: 8.0,
      fiber: 0.5,
      sugar: 0.3,
      emoji: '\ud83e\uddca',
      portionDescription: '1 kotak sedang (100g)',
    ),
    FoodNutritionItem(
      name: 'Ikan Lele Panggang',
      category: 'lauk_pauk',
      calories: 145,
      carbs: 0.0,
      protein: 18.0,
      fat: 8.0,
      fiber: 0.0,
      sugar: 0.0,
      emoji: '\ud83d\udc1f',
      portionDescription: '1 ekor sedang (100g)',
    ),
    FoodNutritionItem(
      name: 'Pecel Lele',
      category: 'lauk_pauk',
      calories: 210,
      carbs: 4.0,
      protein: 22.0,
      fat: 11.0,
      fiber: 1.5,
      sugar: 1.0,
      emoji: '\ud83d\udc1f',
      portionDescription: '1 ekor lele (100g)',
    ),
    FoodNutritionItem(
      name: 'Sayur Bening Bayam',
      category: 'sayuran',
      calories: 28,
      carbs: 4.2,
      protein: 2.5,
      fat: 0.5,
      fiber: 2.5,
      sugar: 0.8,
      emoji: '\ud83e\udd6c',
      portionDescription: '1 mangkuk (100g)',
    ),
    FoodNutritionItem(
      name: 'Sayur Asem',
      category: 'sayuran',
      calories: 35,
      carbs: 6.5,
      protein: 1.8,
      fat: 0.5,
      fiber: 1.5,
      sugar: 1.8,
      emoji: '\ud83c\udf72',
      portionDescription: '1 mangkuk sedang (100g)',
    ),
    FoodNutritionItem(
      name: 'Wortel Rebus',
      category: 'sayuran',
      calories: 41,
      carbs: 9.6,
      protein: 0.9,
      fat: 0.2,
      fiber: 2.8,
      sugar: 4.7,
      emoji: '\ud83e\udd55',
      portionDescription: '1 buah sedang (100g)',
    ),
    FoodNutritionItem(
      name: 'Apel Segar',
      category: 'buah',
      calories: 52,
      carbs: 13.8,
      protein: 0.3,
      fat: 0.2,
      fiber: 2.4,
      sugar: 10.4,
      emoji: '\ud83c\udf4e',
      portionDescription: '1 buah kecil (100g)',
    ),
    FoodNutritionItem(
      name: 'Pisang Barangan',
      category: 'buah',
      calories: 89,
      carbs: 22.8,
      protein: 1.1,
      fat: 0.3,
      fiber: 2.6,
      sugar: 12.2,
      emoji: '\ud83c\udf4c',
      portionDescription: '1 buah sedang (100g)',
    ),
    FoodNutritionItem(
      name: 'Pepaya Segar Potong',
      category: 'buah',
      calories: 43,
      carbs: 10.8,
      protein: 0.5,
      fat: 0.3,
      fiber: 1.7,
      sugar: 7.8,
      emoji: '\ud83c\udf48',
      portionDescription: '1 mangkuk potong (100g)',
    ),
    FoodNutritionItem(
      name: 'Susu Sapi Segar',
      category: 'minuman_camilan',
      calories: 65,
      carbs: 4.8,
      protein: 3.3,
      fat: 3.6,
      fiber: 0.0,
      sugar: 5.1,
      emoji: '\ud83e\udd5b',
      portionDescription: '1 gelas kecil (100ml)',
    ),
    FoodNutritionItem(
      name: 'Donat Gula',
      category: 'minuman_camilan',
      calories: 452,
      carbs: 51.0,
      protein: 4.9,
      fat: 25.0,
      fiber: 1.5,
      sugar: 27.0,
      emoji: '\ud83c\udf69',
      portionDescription: '1 buah (100g)',
    ),
    FoodNutritionItem(
      name: 'Es Teh Manis',
      category: 'minuman_camilan',
      calories: 90,
      carbs: 23.0,
      protein: 0.1,
      fat: 0.0,
      fiber: 0.0,
      sugar: 22.0,
      emoji: '\ud83e\uddcb',
      portionDescription: '1 gelas (200ml)',
    ),
    FoodNutritionItem(
      name: 'Minuman Boba Manis',
      category: 'minuman_camilan',
      calories: 320,
      carbs: 78.0,
      protein: 0.5,
      fat: 1.2,
      fiber: 0.5,
      sugar: 48.0,
      emoji: '\ud83e\uddcb',
      portionDescription: '1 cup (250ml)',
    ),
  ];

  List<FoodNutritionItem> _foods = List.from(_defaultFoods);
  final _foodController = TextEditingController();
  final _quantityController = TextEditingController();
  final _listSearchController = TextEditingController();

  String _unit = 'gram';
  String _preparation = 'Tanpa tambahan minyak';
  bool _fromList = false;
  String _selectedCategory = 'Semua';
  bool _isLoading = false;

  FoodNutritionItem _selected = _defaultFoods.first;

  int _calcCalories = 0;
  double _calcCarbs = 0.0;
  double _calcProtein = 0.0;
  double _calcFat = 0.0;
  double _calcFiber = 0.0;
  double _calcSugar = 0.0;
  double _calcWeightGram = 100.0;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    _fetchFoodDatabase();
  }

  @override
  void dispose() {
    _foodController.dispose();
    _quantityController.dispose();
    _listSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchFoodDatabase() async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.nutritionCalculate);
      if (res.isSuccess && res.data != null && res.data['foods'] is List) {
        final list = (res.data['foods'] as List)
            .map(
              (item) =>
                  FoodNutritionItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        if (list.isNotEmpty && mounted) {
          setState(() {
            _foods = list;
          });
        }
      }
    } catch (_) {}
  }

  double _getWeightInGrams(double qty, String unit) {
    switch (unit) {
      case 'porsi':
        return qty * 150.0;
      case 'potong':
      case 'butir':
        return qty * 60.0;
      case 'gelas':
        return qty * 200.0;
      case 'gram':
      default:
        return qty;
    }
  }

  void _calculateDirect(
    FoodNutritionItem food,
    double qty,
    String unit,
    String prep,
  ) {
    final weightGram = _getWeightInGrams(qty, unit);
    final mult = weightGram / 100.0;

    double prepCaloriesMultiplier = 1.0;
    double prepFatMultiplier = 1.0;

    if (prep == 'Digoreng') {
      prepCaloriesMultiplier = 1.25;
      prepFatMultiplier = 1.40;
    } else if (prep == 'Dipanggang') {
      prepCaloriesMultiplier = 1.05;
    }

    setState(() {
      _selected = food;
      _calcWeightGram = weightGram;
      _calcCalories = (food.calories * mult * prepCaloriesMultiplier).round();
      _calcCarbs = double.parse((food.carbs * mult).toStringAsFixed(1));
      _calcProtein = double.parse((food.protein * mult).toStringAsFixed(1));
      _calcFat = double.parse(
        (food.fat * mult * prepFatMultiplier).toStringAsFixed(1),
      );
      _calcFiber = double.parse((food.fiber * mult).toStringAsFixed(1));
      _calcSugar = double.parse((food.sugar * mult).toStringAsFixed(1));
      _hasCalculated = true;
    });
  }

  Future<void> _calculate() async {
    final query = _foodController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nama makanan terlebih dahulu')),
      );
      return;
    }

    final qty =
        double.tryParse(_quantityController.text.trim().replaceAll(',', '.')) ??
        (_unit == 'gram' ? 100.0 : 1.0);
    if (_quantityController.text.trim().isEmpty) {
      _quantityController.text = qty.toStringAsFixed(0);
    }
    final weightGram = _getWeightInGrams(qty, _unit);

    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.instance.post(
        ApiConstants.nutritionCalculate,
        body: {'foodName': query, 'weightGram': weightGram},
      );

      if (res.isSuccess && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        final dynamicFood = FoodNutritionItem(
          name: d['foodName'] as String? ?? query,
          calories: (d['caloriesKkal'] as num?)?.toInt() ?? 100,
          carbs: (d['carbsGram'] as num?)?.toDouble() ?? 10.0,
          protein: (d['proteinGram'] as num?)?.toDouble() ?? 5.0,
          fat: (d['fatGram'] as num?)?.toDouble() ?? 2.0,
          fiber: (d['fiberGram'] as num?)?.toDouble() ?? 1.0,
          sugar: (d['sugarGram'] as num?)?.toDouble() ?? 0.0,
          emoji: d['emoji'] as String? ?? '\ud83e\udd57',
        );

        if (!mounted) return;
        setState(() {
          _selected = dynamicFood;
          _calcWeightGram = weightGram;
          _calcCalories = (d['caloriesKkal'] as num?)?.toInt() ?? 100;
          _calcCarbs = (d['carbsGram'] as num?)?.toDouble() ?? 10.0;
          _calcProtein = (d['proteinGram'] as num?)?.toDouble() ?? 5.0;
          _calcFat = (d['fatGram'] as num?)?.toDouble() ?? 2.0;
          _calcFiber = (d['fiberGram'] as num?)?.toDouble() ?? 1.0;
          _calcSugar = (d['sugarGram'] as num?)?.toDouble() ?? 0.0;
          _hasCalculated = true;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    final qLower = query.toLowerCase();
    final found = _foods.firstWhere(
      (f) =>
          f.name.toLowerCase() == qLower ||
          f.name.toLowerCase().contains(qLower),
      orElse: () => FoodNutritionItem(
        name: query,
        calories: 120,
        carbs: 15.0,
        protein: 5.0,
        fat: 3.0,
        fiber: 2.0,
        sugar: 2.0,
        emoji: '\ud83e\udd57',
      ),
    );

    if (!mounted) return;
    _calculateDirect(found, qty, _unit, _preparation);
    setState(() => _isLoading = false);
  }

  void _selectFoodFromList(FoodNutritionItem food) {
    setState(() {
      _selected = food;
      _foodController.text = food.name;
      if (_quantityController.text.trim().isEmpty) {
        _quantityController.text = '100';
      }
      _unit = 'gram';
    });
    final qty = double.tryParse(_quantityController.text) ?? 100.0;
    _calculateDirect(food, qty, 'gram', _preparation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Memilih ${food.name}. Nilai gizi berhasil dihitung!'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat Hasil',
          textColor: Colors.white,
          onPressed: () {
            setState(() => _fromList = false);
          },
        ),
      ),
    );
  }

  List<FoodNutritionItem> get _filteredFoods {
    final search = _listSearchController.text.trim().toLowerCase();
    return _foods.where((food) {
      final matchesSearch =
          search.isEmpty || food.name.toLowerCase().contains(search);
      if (!matchesSearch) return false;

      if (_selectedCategory == 'Semua') return true;
      if (_selectedCategory == 'Makanan Pokok')
        return food.category == 'makanan_pokok';
      if (_selectedCategory == 'Lauk Pauk') return food.category == 'lauk_pauk';
      if (_selectedCategory == 'Sayuran') return food.category == 'sayuran';
      if (_selectedCategory == 'Buah') return food.category == 'buah';
      if (_selectedCategory == 'Camilan & Minuman')
        return food.category == 'minuman_camilan';
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.chevron_left,
          size: 28,
          color: AppColors.textDark,
        ),
      ),
      title: Text(
        'Kalkulator Nutrisi',
        style: AppTypography.headingScreen.copyWith(
          fontSize: 20,
          color: AppColors.textDark,
        ),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 20),
        children: [
          Text(
            'Hitung kandungan gizi makanan anak dengan mudah. Cari makanan secara manual atau telusuri langsung dari daftar bahan.',
            style: AppTypography.bodySecondary.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _modeButton(
                  'Hitung Manual',
                  !_fromList,
                  () => setState(() => _fromList = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _modeButton(
                  'Dari Daftar Makanan (${_foods.length})',
                  _fromList,
                  () => setState(() => _fromList = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (!_fromList) ...[
            _buildManualInputForm(),
          ] else ...[
            _buildFoodDirectoryView(),
          ],

          const SizedBox(height: 14),
          if (_hasCalculated) _resultCard(),
        ],
      ),
    ),
  );

  Widget _buildManualInputForm() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF4F6F8),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldTitle(Icons.search, 'Cari / Masukkan Nama Makanan'),
        const SizedBox(height: 7),
        Autocomplete<FoodNutritionItem>(
          initialValue: TextEditingValue(text: _foodController.text),
          displayStringForOption: (item) => item.name,
          optionsBuilder: (value) => value.text.isEmpty
              ? _foods.take(8)
              : _foods.where(
                  (food) => food.name.toLowerCase().contains(
                    value.text.toLowerCase(),
                  ),
                ),
          onSelected: (food) {
            setState(() {
              _selected = food;
              _foodController.text = food.name;
              if (_quantityController.text.trim().isEmpty) {
                _quantityController.text = _unit == 'gram' ? '100' : '1';
              }
            });
            final qty = double.tryParse(_quantityController.text) ?? 100;
            _calculateDirect(food, qty, _unit, _preparation);
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmit) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (v) => _foodController.text = v,
              decoration: _decoration(
                'Contoh: Nasi Putih, Dada Ayam, Tempe, Sayur Asem...',
              ).copyWith(prefixIcon: const Icon(Icons.search, size: 18)),
            );
          },
        ),
        const SizedBox(height: 12),
        _fieldTitle(Icons.scale_outlined, 'Jumlah & Satuan'),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoration(
                  _unit == 'gram' ? 'Contoh: 100' : 'Contoh: 1',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 4,
              child: DropdownButtonFormField<String>(
                initialValue: _unit,
                decoration: _decoration(''),
                items: ['gram', 'porsi', 'potong', 'butir', 'gelas']
                    .map(
                      (v) => DropdownMenuItem(
                        value: v,
                        child: Text(v, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _unit = v);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _fieldTitle(Icons.restaurant, 'Cara Pengolahan'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _preparation,
          decoration: _decoration('Pilih cara pengolahan'),
          items:
              [
                    'Tanpa tambahan minyak',
                    'Direbus',
                    'Dikukus',
                    'Dipanggang',
                    'Digoreng',
                  ]
                  .map(
                    (v) => DropdownMenuItem(
                      value: v,
                      child: Text(v, style: const TextStyle(fontSize: 12)),
                    ),
                  )
                  .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _preparation = v);
          },
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.calculate_outlined, size: 18),
            label: Text(_isLoading ? 'Menghitung...' : 'Hitung Nilai Gizi'),
            onPressed: _isLoading ? null : _calculate,
          ),
        ),
      ],
    ),
  );

  Widget _buildFoodDirectoryView() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _listSearchController,
          onChanged: (_) => setState(() {}),
          decoration: _decoration('Cari bahan di katalog pangan...').copyWith(
            prefixIcon: const Icon(Icons.search, size: 18),
            suffixIcon: _listSearchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _listSearchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                [
                  'Semua',
                  'Makanan Pokok',
                  'Lauk Pauk',
                  'Sayuran',
                  'Buah',
                  'Camilan & Minuman',
                ].map((cat) {
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSel ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppColors.primaryGreen,
                      backgroundColor: const Color(0xFFF1F5F9),
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Ketuk makanan untuk memilih & menghitung:',
          style: AppTypography.bodySecondary.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredFoods.length,
          separatorBuilder: (_, _) =>
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
          itemBuilder: (context, index) {
            final food = _filteredFoods[index];
            final isCurrent = _hasCalculated && _selected.name == food.name;
            return InkWell(
              onTap: () => _selectFoodFromList(food),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.veryLightGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        food.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: AppTypography.titleCard.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            food.portionDescription,
                            style: AppTypography.bodySecondary.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F3E7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${food.calories} kkal',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreenDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'P: ${food.protein}g \u00b7 K: ${food.carbs}g',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isCurrent ? Icons.check_circle : Icons.chevron_right,
                      size: 18,
                      color: isCurrent
                          ? AppColors.primaryGreen
                          : AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );

  Widget _modeButton(String label, bool selected, VoidCallback onTap) =>
      SizedBox(
        height: 40,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: selected
                ? AppColors.primaryGreen
                : const Color(0xFFE9EAEC),
            foregroundColor: selected ? Colors.white : AppColors.textDark,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(7),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      );

  Widget _fieldTitle(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textDark),
      const SizedBox(width: 6),
      Text(
        text,
        style: AppTypography.titleCard.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE1E5EA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE1E5EA)),
    ),
  );

  Widget _resultCard() {
    final isSweetWarning = _calcSugar >= 12.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insert_chart_outlined,
                color: AppColors.primaryGreenDark,
              ),
              const SizedBox(width: 8),
              Text(
                'Hasil Kandungan Gizi',
                style: AppTypography.titleCard.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_calcWeightGram.toStringAsFixed(0)} gram',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _selected.emoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selected.name,
                        style: AppTypography.titleCard.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Porsi: ${_quantityController.text} $_unit ($_preparation)',
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F3E7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Energi',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryGreenDark,
                        ),
                      ),
                      Text(
                        '$_calcCalories kkal',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _macro(
                'Karbohidrat',
                '${_calcCarbs.toStringAsFixed(1)} g',
                const Color(0xFFFFE5E5),
                Icons.local_fire_department_outlined,
              ),
              _macro(
                'Protein',
                '${_calcProtein.toStringAsFixed(1)} g',
                const Color(0xFFE0F3FF),
                Icons.fitness_center,
              ),
              _macro(
                'Lemak',
                '${_calcFat.toStringAsFixed(1)} g',
                const Color(0xFFFFF1D3),
                Icons.water_drop_outlined,
              ),
              _macro(
                'Serat',
                '${_calcFiber.toStringAsFixed(1)} g',
                const Color(0xFFE4F2E2),
                Icons.grass_outlined,
              ),
            ],
          ),

          if (isSweetWarning) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tinggi Gula (${_calcSugar.toStringAsFixed(1)}g). Batasi konsumsi manis harian untuk mencegah lonjakan gula darah dan risiko diabetes anak.',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF9F1239),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F4E9),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates_outlined,
                  size: 16,
                  color: AppColors.primaryGreenDark,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _calcFiber >= 2.0
                        ? 'Bagus! Kandungan serat pangan membantu memperlambat penyerapan glukosa dan menjaga rasa kenyang lebih lama.'
                        : 'Tips Cehat: Kombinasikan dengan sayur atau buah segar untuk melengkapi kebutuhan serat dan vitamin anak.',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoodDiaryScreen(
                    initialFood:
                        '${_selected.name} (${_quantityController.text} $_unit)',
                  ),
                ),
              ),
              icon: const Icon(Icons.bookmark_add_outlined, size: 18),
              label: const Text(
                'Catat di Diary Makan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _macro(String name, String value, Color color, IconData icon) =>
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: color,
                child: Icon(icon, size: 15, color: AppColors.primaryGreenDark),
              ),
              const SizedBox(height: 4),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 8,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      );
}
