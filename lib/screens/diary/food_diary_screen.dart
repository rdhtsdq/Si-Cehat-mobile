import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../providers/profile_provider.dart';

class FoodDiaryScreen extends StatefulWidget {
  final String? initialFood;
  final String? initialMeal;

  const FoodDiaryScreen({super.key, this.initialFood, this.initialMeal});

  @override
  State<FoodDiaryScreen> createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends State<FoodDiaryScreen> {
  final _foodController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  String _meal = 'Sarapan';
  String _foodType = 'Makanan';
  String _portion = '1 porsi';
  String _addedSugar = 'Tidak';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _foodController.text = widget.initialFood ?? '';
    _meal = widget.initialMeal ?? 'Sarapan';
  }

  @override
  void dispose() {
    _foodController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _mapMealSlot(String mealLabel) {
    switch (mealLabel) {
      case 'Sarapan':
        return 'sarapan';
      case 'Makan Siang':
        return 'siang';
      case 'Makan Malam':
        return 'malam';
      case 'Camilan Pagi':
      case 'Camilan Sore':
      default:
        return 'camilan';
    }
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
        'Diary Makan',
        style: AppTypography.headingScreen.copyWith(
          fontSize: 20,
          color: AppColors.textDark,
        ),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              children: [
                _datePicker(),
                const SizedBox(height: 12),
                _mealSelector(),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        Icons.restaurant,
                        'Tambah Makanan / Minuman',
                      ),
                      const SizedBox(height: 12),
                      _label('Waktu makan'),
                      _dropdown(_meal, [
                        'Sarapan',
                        'Camilan Pagi',
                        'Makan Siang',
                        'Camilan Sore',
                        'Makan Malam',
                      ], (v) => setState(() => _meal = v!)),
                      const SizedBox(height: 10),
                      _label('Jenis makanan / minuman'),
                      _dropdown(_foodType, [
                        'Makanan',
                        'Minuman',
                        'Camilan',
                      ], (v) => setState(() => _foodType = v!)),
                      const SizedBox(height: 10),
                      _label('Porsi'),
                      _dropdown(_portion, [
                        '\u00bd porsi',
                        '1 porsi',
                        '1\u00bd porsi',
                        '2 porsi',
                        '100 gram',
                      ], (v) => setState(() => _portion = v!)),
                      const SizedBox(height: 10),
                      _label('Nama makanan'),
                      _input(
                        _foodController,
                        'Pilih / tulis makanan yang dikonsumsi',
                      ),
                      const SizedBox(height: 12),
                      _sectionTitle(
                        Icons.question_mark,
                        'Apakah mengandung gula tambahan?',
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: ['Tidak tahu', 'Tidak', 'Ya']
                            .map(
                              (item) => ChoiceChip(
                                label: Text(
                                  item,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                selected: _addedSugar == item,
                                selectedColor: AppColors.veryLightGreen,
                                onSelected: (_) =>
                                    setState(() => _addedSugar = item),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      _label('Catatan (Opsional)'),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: _decoration('Tambahkan catatan...'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan +'),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _datePicker() => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: () async {
      final selected = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (selected != null) setState(() => _date = selected);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, size: 16),
          const SizedBox(width: 8),
          Text(
            DateFormat('dd MMMM yyyy', 'id_ID').format(_date),
            style: AppTypography.bodySecondary.copyWith(fontSize: 12),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    ),
  );

  Widget _mealSelector() => Row(
    children:
        [
          'Sarapan',
          'Camilan Pagi',
          'Makan Siang',
          'Camilan Sore',
          'Makan Malam',
        ].map((item) {
          final selected = item == _meal;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: () => setState(() => _meal = item),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryGreen
                        : const Color(0xFFF3F4F5),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _mealIcon(item),
                        size: 15,
                        color: selected ? Colors.white : AppColors.textDark,
                      ),
                      Text(
                        item,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 8,
                          color: selected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
  );

  Widget _sectionTitle(IconData icon, String title) => Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textDark),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          title,
          style: AppTypography.titleCard.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text,
      style: AppTypography.bodyRegular.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  Widget _dropdown(
    String value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    isDense: true,
    decoration: _decoration('Pilih...'),
    icon: const Icon(Icons.keyboard_arrow_down, size: 18),
    items: values
        .map(
          (v) => DropdownMenuItem(
            value: v,
            child: Text(v, style: const TextStyle(fontSize: 12)),
          ),
        )
        .toList(),
    onChanged: onChanged,
  );
  Widget _input(TextEditingController controller, String hint) =>
      TextField(controller: controller, decoration: _decoration(hint));
  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
    filled: true,
    fillColor: const Color(0xFFF8F9FA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE6E8EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE6E8EB)),
    ),
  );
  IconData _mealIcon(String meal) => switch (meal) {
    'Sarapan' => Icons.wb_sunny_outlined,
    'Camilan Pagi' => Icons.cookie_outlined,
    'Makan Siang' => Icons.lunch_dining_outlined,
    'Camilan Sore' => Icons.bakery_dining_outlined,
    _ => Icons.dinner_dining_outlined,
  };

  Future<void> _save() async {
    if (_foodController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama makanan terlebih dahulu.')),
      );
      return;
    }
    setState(() => _saving = true);

    final dateStr = DateFormat('yyyy-MM-dd').format(_date);
    final foodName = _foodController.text.trim();
    final notes = _notesController.text.trim();
    final activeChild = context.read<ProfileProvider>().activeChild;

    // 1. Post to Backend API if authenticated and childId is available
    try {
      final token = await ApiClient.instance.getToken();
      if (token != null && token.isNotEmpty && activeChild != null) {
        await ApiClient.instance.post(
          ApiConstants.foodDiary,
          body: {
            'childId': activeChild.id.toString(),
            'date': dateStr,
            'mealSlot': _mapMealSlot(_meal),
            'foodName': foodName,
            'portion': notes.isNotEmpty ? '$_portion ($notes)' : _portion,
          },
        );
      }
    } catch (_) {}

    // 2. Local persistence in SharedPreferences
    final preferences = await SharedPreferences.getInstance();
    final entries = preferences.getStringList('food_diary_entries') ?? [];
    entries.add(
      jsonEncode({
        'date': dateStr,
        'meal': _meal,
        'type': _foodType,
        'portion': _portion,
        'food': foodName,
        'addedSugar': _addedSugar,
        'notes': notes,
      }),
    );
    await preferences.setStringList('food_diary_entries', entries);

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Catatan makan berhasil disimpan.')),
    );
    Navigator.of(context).pop();
  }
}
