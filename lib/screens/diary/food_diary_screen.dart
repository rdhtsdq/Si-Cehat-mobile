import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../providers/app_providers.dart';

class FoodDiaryScreen extends ConsumerStatefulWidget {
  final String? initialFood;
  final String? initialMeal;

  const FoodDiaryScreen({super.key, this.initialFood, this.initialMeal});

  @override
  ConsumerState<FoodDiaryScreen> createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends ConsumerState<FoodDiaryScreen> {
  final _foodController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  String _meal = 'Sarapan';
  String _foodType = 'Makanan';
  String _portion = '1 porsi';
  String _addedSugar = 'Tidak';
  bool _saving = false;
  bool _loadingEntries = false;
  List<Map<String, dynamic>> _allEntriesForDate = [];

  @override
  void initState() {
    super.initState();
    _foodController.text = widget.initialFood ?? '';
    _meal = widget.initialMeal ?? 'Sarapan';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadEntriesForDate();
      }
    });
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
        return 'camilan';
      default:
        return 'camilan';
    }
  }

  String _slotKeyToMealLabel(String key) {
    switch (key.toLowerCase()) {
      case 'sarapan':
        return 'Sarapan';
      case 'siang':
      case 'makan_siang':
        return 'Makan Siang';
      case 'malam':
      case 'makan_malam':
        return 'Makan Malam';
      case 'camilan_pagi':
        return 'Camilan Pagi';
      case 'camilan_sore':
        return 'Camilan Sore';
      case 'camilan':
      default:
        return 'Camilan Pagi';
    }
  }

  String _formatDisplayDate(DateTime dt) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
  }

  Future<void> _loadEntriesForDate() async {
    final activeChild = mounted ? ref.read(profileProvider).activeChild : null;
    setState(() => _loadingEntries = true);
    final dateStr = _date.toIso8601String().substring(0, 10);
    final List<Map<String, dynamic>> result = [];

    // 1. Ambil dari penyimpanan lokal (SharedPreferences)
    try {
      final preferences = await SharedPreferences.getInstance();
      final rawList = preferences.getStringList('food_diary_entries') ?? [];
      for (final item in rawList) {
        try {
          final decoded = jsonDecode(item) as Map<String, dynamic>;
          if (decoded['date'] == dateStr) {
            result.add(decoded);
          }
        } catch (_) {}
      }
    } catch (_) {}

    // 2. Ambil dari Backend API (sinkronisasi cloud)
    if (activeChild != null) {
      try {
        final res = await ApiClient.instance.get(
          ApiConstants.foodDiary,
          queryParams: {
            'childId': activeChild.id.toString(),
            'date': dateStr,
          },
        );
        if (res.isSuccess && res.data != null) {
          final slots = res.data['slots'] as Map<String, dynamic>?;
          if (slots != null) {
            slots.forEach((slotKey, list) {
              if (list is List) {
                for (final item in list) {
                  if (item is Map) {
                    final mealLabel = _slotKeyToMealLabel(slotKey);
                    final foodName = item['foodName']?.toString() ?? '';
                    final alreadyExists = result.any(
                      (r) => r['food'] == foodName && r['meal'] == mealLabel,
                    );
                    if (!alreadyExists && foodName.isNotEmpty) {
                      result.add({
                        'date': dateStr,
                        'meal': mealLabel,
                        'type': item['foodType'] ?? 'Makanan',
                        'portion': item['portion'] ?? '1 porsi',
                        'food': foodName,
                        'addedSugar':
                            item['sugarGram'] != null &&
                                    (item['sugarGram'] as num) > 5
                                ? 'Ya'
                                : 'Tidak',
                        'notes': item['notes'] ?? '',
                        'id': item['id'],
                      });
                    }
                  }
                }
              }
            });
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _allEntriesForDate = result;
        _loadingEntries = false;
      });
    }
  }

  Future<void> _deleteEntry(Map<String, dynamic> entry) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final rawList = preferences.getStringList('food_diary_entries') ?? [];
      final updatedList = <String>[];

      bool removed = false;
      for (final raw in rawList) {
        try {
          final decoded = jsonDecode(raw) as Map<String, dynamic>;
          if (!removed &&
              decoded['date'] == entry['date'] &&
              decoded['meal'] == entry['meal'] &&
              decoded['food'] == entry['food']) {
            removed = true;
            continue;
          }
          updatedList.add(raw);
        } catch (_) {
          updatedList.add(raw);
        }
      }
      await preferences.setStringList('food_diary_entries', updatedList);
    } catch (_) {}

    await _loadEntriesForDate();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${entry['food']} dihapus dari diary.'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  bool _hasEntriesForMeal(String mealName) {
    return _allEntriesForDate.any((e) => e['meal'] == mealName);
  }

  List<Map<String, dynamic>> get _currentSlotEntries {
    return _allEntriesForDate.where((e) => e['meal'] == _meal).toList();
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

                // Bagian: Makanan Tersimpan di Waktu Makan Terpilih
                _savedEntriesCard(),
                const SizedBox(height: 14),

                // Bagian: Formulir Tambah Makanan
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        Icons.add_circle_outline,
                        'Tambah ke $_meal',
                      ),
                      const SizedBox(height: 12),
                      _label('Waktu makan'),
                      _dropdown(_meal, [
                        'Sarapan',
                        'Camilan Pagi',
                        'Makan Siang',
                        'Camilan Sore',
                        'Makan Malam',
                      ], (v) {
                        setState(() => _meal = v!);
                      }),
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
                      _label('Nama makanan / minuman'),
                      _input(
                        _foodController,
                        'Contoh: Bubur ayam, Nasi sop, Susu UHT...',
                      ),
                      const SizedBox(height: 12),
                      _sectionTitle(
                        Icons.help_outline,
                        'Apakah mengandung gula tambahan?',
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: ['Tidak tahu', 'Tidak', 'Ya']
                            .map(
                              (item) => ChoiceChip(
                                label: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: _addedSugar == item
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                    color: _addedSugar == item
                                        ? AppColors.primaryGreenDark
                                        : AppColors.textDark,
                                  ),
                                ),
                                selected: _addedSugar == item,
                                selectedColor: AppColors.veryLightGreen,
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: BorderSide(
                                  color: _addedSugar == item
                                      ? AppColors.primaryGreen
                                      : Colors.transparent,
                                ),
                                onSelected: (_) =>
                                    setState(() => _addedSugar = item),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      _label('Catatan (Opsional)'),
                      TextField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: _decoration('Tambahkan detail atau catatan porsi...'),
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
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(
                  _saving ? 'Menyimpan...' : 'Simpan ke $_meal +',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _savedEntriesCard() {
    final entries = _currentSlotEntries;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_mealIcon(_meal), size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  Text(
                    'Makanan Tercatat di $_meal',
                    style: AppTypography.titleCard.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: entries.isNotEmpty
                      ? AppColors.veryLightGreen
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${entries.length} Catatan',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: entries.isNotEmpty
                        ? AppColors.primaryGreenDark
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loadingEntries)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (entries.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.fastfood_outlined,
                    size: 28,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Belum ada makanan dicatat untuk $_meal pada tanggal ini.',
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 12, color: Color(0xFFF1F5F9)),
              itemBuilder: (context, idx) {
                final item = entries[idx];
                final foodName = item['food']?.toString() ?? 'Makanan';
                final portion = item['portion']?.toString() ?? '1 porsi';
                final hasSugar = item['addedSugar'] == 'Ya';
                final notes = item['notes']?.toString() ?? '';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: hasSugar
                            ? const Color(0xFFFFF3E0)
                            : AppColors.veryLightGreen,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        item['type'] == 'Minuman'
                            ? Icons.local_cafe_outlined
                            : Icons.restaurant_outlined,
                        size: 16,
                        color: hasSugar
                            ? Colors.orange[800]
                            : AppColors.primaryGreenDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodName,
                            style: AppTypography.titleCard.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'Porsi: $portion',
                                style: AppTypography.bodySecondary.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: hasSugar
                                      ? const Color(0xFFFFEBEE)
                                      : const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  hasSugar ? 'Ada Gula' : 'Tanpa Gula',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: hasSugar
                                        ? Colors.red[800]
                                        : Colors.green[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (notes.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              notes,
                              style: AppTypography.bodySecondary.copyWith(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Hapus Catatan',
                      onPressed: () => _deleteEntry(item),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _datePicker() => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: () async {
      final selected = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 30)),
      );
      if (selected != null) {
        setState(() => _date = selected);
        _loadEntriesForDate();
      }
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
            _formatDisplayDate(_date),
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
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
          final hasData = _hasEntriesForMeal(item);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(7),
                onTap: () {
                  setState(() => _meal = item);
                },
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryGreen
                        : const Color(0xFFF3F4F5),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryGreenDark
                          : (hasData
                              ? AppColors.primaryGreen.withValues(alpha: 0.5)
                              : Colors.transparent),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _mealIcon(item),
                            size: 15,
                            color: selected ? Colors.white : AppColors.textDark,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                              color: selected ? Colors.white : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      if (hasData)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : AppColors.primaryGreen,
                              shape: BoxShape.circle,
                            ),
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
    isExpanded: true,
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

    final dateStr = _date.toIso8601String().substring(0, 10);
    final foodName = _foodController.text.trim();
    final notes = _notesController.text.trim();
    final activeChild = ref.read(profileProvider).activeChild;

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

    // 2. Simpan di SharedPreferences lokal
    try {
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
    } catch (_) {}

    // 3. Muat ulang daftar item dan reset input form
    _foodController.clear();
    _notesController.clear();
    await _loadEntriesForDate();

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$foodName berhasil dicatat ke $_meal!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }
}
