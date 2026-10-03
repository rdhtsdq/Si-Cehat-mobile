import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../diary/food_diary_screen.dart';

class _FoodNutrition {
  final String name;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final double fiber;
  const _FoodNutrition(
    this.name,
    this.calories,
    this.carbs,
    this.protein,
    this.fat,
    this.fiber,
  );
}

class NutritionCalculatorScreen extends StatefulWidget {
  const NutritionCalculatorScreen({super.key});

  @override
  State<NutritionCalculatorScreen> createState() =>
      _NutritionCalculatorScreenState();
}

class _NutritionCalculatorScreenState extends State<NutritionCalculatorScreen> {
  static const _foods = [
    _FoodNutrition('Nasi Putih', 175, 39, 3, .3, .4),
    _FoodNutrition('Ayam Dada', 165, 0, 31, 3.6, 0),
    _FoodNutrition('Telur Ayam', 155, 1.1, 13, 11, 0),
    _FoodNutrition('Brokoli', 34, 6.6, 2.8, .4, 2.6),
    _FoodNutrition('Pisang', 89, 22.8, 1.1, .3, 2.6),
  ];
  final _foodController = TextEditingController(text: 'Nasi Putih');
  final _quantityController = TextEditingController(text: '100');
  String _unit = 'gram';
  String _preparation = 'Tanpa tambahan minyak';
  bool _fromList = false;
  _FoodNutrition _selected = _foods.first;
  double _factor = 1;
  bool _hasCalculated = true;

  @override
  void dispose() {
    _foodController.dispose();
    _quantityController.dispose();
    super.dispose();
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
            'Hitung kandungan gizi makanan dengan mudah. Masukkan makanan atau pilih dari daftar.',
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
                  'Dari Daftar Makanan',
                  _fromList,
                  () => setState(() => _fromList = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldTitle(Icons.search, 'Cari Makanan'),
                const SizedBox(height: 7),
                Autocomplete<_FoodNutrition>(
                  initialValue: TextEditingValue(text: _foodController.text),
                  displayStringForOption: (item) => item.name,
                  optionsBuilder: (value) => value.text.isEmpty
                      ? _foods
                      : _foods.where(
                          (food) => food.name.toLowerCase().contains(
                            value.text.toLowerCase(),
                          ),
                        ),
                  onSelected: (food) => setState(() {
                    _selected = food;
                    _foodController.text = food.name;
                    _hasCalculated = false;
                  }),
                  fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                    if (controller.text.isEmpty) {
                      controller.text = _foodController.text;
                    }
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (v) => _foodController.text = v,
                      decoration:
                          _decoration(
                            'Contoh: Nasi putih, Ayam dada, telur, Brokoli...',
                          ).copyWith(
                            prefixIcon: const Icon(Icons.search, size: 18),
                          ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _fieldTitle(Icons.scale_outlined, 'Jumlah'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _decoration('100'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: _decoration(''),
                        items: ['gram', 'porsi']
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _unit = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _fieldTitle(Icons.restaurant, 'Cara Pengolahan (Opsional)'),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _preparation,
                  decoration: _decoration('Pilih cara pengolahan'),
                  items:
                      [
                            'Tanpa tambahan minyak',
                            'Direbus',
                            'Dikukus',
                            'Digoreng',
                          ]
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(
                                v,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _preparation = v!),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.calculate_outlined, size: 17),
                    label: const Text('Hitung Nilai Gizi'),
                    onPressed: _calculate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_hasCalculated) _resultCard(),
        ],
      ),
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
            style: const TextStyle(fontSize: 11),
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
    final quantity =
        double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 100;
    final unitFactor = _unit == 'porsi' ? 1.5 : quantity / 100;
    final factor = unitFactor * _factor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8F2),
        borderRadius: BorderRadius.circular(14),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/figma_features/dish-1.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
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
                        ),
                      ),
                      Text(
                        '${quantity.toStringAsFixed(0)} $_unit (1 porsi)',
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
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
                        '${(_selected.calories * factor).round()} kkal',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
                '${(_selected.carbs * factor).toStringAsFixed(0)} g',
                const Color(0xFFFFE5E5),
                Icons.local_fire_department_outlined,
              ),
              _macro(
                'Protein',
                '${(_selected.protein * factor).toStringAsFixed(0)} g',
                const Color(0xFFE0F3FF),
                Icons.fitness_center,
              ),
              _macro(
                'Lemak',
                '${(_selected.fat * factor).toStringAsFixed(1)} g',
                const Color(0xFFFFF1D3),
                Icons.water_drop_outlined,
              ),
              _macro(
                'Serat',
                '${(_selected.fiber * factor).toStringAsFixed(1)} g',
                const Color(0xFFE4F2E2),
                Icons.grass_outlined,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F4E9),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'Tahukah kamu? Asupan serat yang cukup membantu mendukung pola makan seimbang.',
              style: TextStyle(fontSize: 10, color: AppColors.primaryGreenDark),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FoodDiaryScreen(initialFood: _selected.name),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Catat di Diary Makan'),
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
                style: const TextStyle(fontSize: 8),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );

  void _calculate() {
    final query = _foodController.text.trim().toLowerCase();
    final found = _foods
        .where(
          (food) =>
              food.name.toLowerCase() == query ||
              food.name.toLowerCase().contains(query),
        )
        .firstOrNull;
    if (found == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih makanan dari daftar yang tersedia.'),
        ),
      );
      return;
    }
    setState(() {
      _selected = found;
      _factor = _preparation == 'Digoreng' ? 1.15 : 1;
      _hasCalculated = true;
    });
  }
}
