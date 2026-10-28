import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/nutrition_model.dart';
import '../../providers/app_providers.dart';

class NutritionCalculatorScreen extends ConsumerStatefulWidget {
  const NutritionCalculatorScreen({super.key});

  @override
  ConsumerState<NutritionCalculatorScreen> createState() =>
      _NutritionCalculatorScreenState();
}

class _NutritionCalculatorScreenState
    extends ConsumerState<NutritionCalculatorScreen> {
  int _tab = 0;
  String _unit = 'gram';
  String _preparation = 'Tanpa tambahan minyak';
  String _mealSlot = 'sarapan';
  DateTime _date = DateTime.now();

  FoodItem? _quickFood;
  NutritionValues? _quickResult;
  double _quickWeightGram = 100;

  final _quickSearchController = TextEditingController();
  final _quickQuantityController = TextEditingController(text: '100');
  final _batchSearchController = TextEditingController();
  final _batchWeightController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadChildData());
  }

  @override
  void dispose() {
    _quickSearchController.dispose();
    _quickQuantityController.dispose();
    _batchSearchController.dispose();
    _batchWeightController.dispose();
    super.dispose();
  }

  String get _dateString => DateFormat('yyyy-MM-dd').format(_date);

  String? get _childId {
    final child = ref.read(profileProvider).activeChild;
    return child?.id?.toString();
  }

  Future<void> _loadChildData() async {
    final childId = _childId;
    if (childId == null || childId.isEmpty) return;
    final provider = ref.read(nutritionProvider);
    await provider.loadTarget(childId);
    await provider.loadSummary(childId, _dateString);
  }

  double _weightFromUnit(double quantity, String unit) {
    switch (unit) {
      case 'porsi':
        return quantity * 150;
      case 'potong':
      case 'butir':
        return quantity * 60;
      case 'gelas':
        return quantity * 200;
      case 'gram':
      default:
        return quantity;
    }
  }

  NutritionValues _applyPreparation(NutritionValues values) {
    if (_preparation == 'Digoreng') {
      return NutritionValues(
        caloriesKkal: (values.caloriesKkal * 1.25).round(),
        carbsGram: values.carbsGram,
        proteinGram: values.proteinGram,
        fatGram: (values.fatGram * 1.4 * 10).round() / 10,
        sugarGram: values.sugarGram,
        fiberGram: values.fiberGram,
      );
    }
    if (_preparation == 'Dipanggang') {
      return NutritionValues(
        caloriesKkal: (values.caloriesKkal * 1.05).round(),
        carbsGram: values.carbsGram,
        proteinGram: values.proteinGram,
        fatGram: values.fatGram,
        sugarGram: values.sugarGram,
        fiberGram: values.fiberGram,
      );
    }
    return values;
  }

  void _calculateQuick(NutritionProvider provider) {
    final query = _quickSearchController.text.trim();
    final food = _quickFood ?? _findFood(provider.foods, query);
    if (food == null) {
      _showSnack('Makanan tidak ditemukan. Pilih dari daftar.');
      return;
    }

    final quantity =
        double.tryParse(_quickQuantityController.text.trim().replaceAll(',', '.')) ??
            100;
    final weight = _weightFromUnit(quantity, _unit);
    if (weight <= 0) {
      _showSnack('Jumlah harus lebih dari 0.');
      return;
    }

    setState(() {
      _quickFood = food;
      _quickWeightGram = weight;
      _quickResult = _applyPreparation(food.per100g.scaled(weight));
    });
  }

  FoodItem? _findFood(List<FoodItem> foods, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final food in foods) {
      if (food.name.toLowerCase() == normalized) return food;
    }
    for (final food in foods) {
      if (food.name.toLowerCase().contains(normalized)) return food;
    }
    return null;
  }

  void _addQuickToDraft(NutritionProvider provider) {
    final food = _quickFood;
    if (food == null || _quickResult == null) return;
    provider.addDraft(
      food,
      weightGram: _quickWeightGram,
      preparedValues: _quickResult,
    );
    setState(() => _tab = 1);
    _showSnack('${food.name} ditambahkan ke asupan.');
  }

  void _addFromBatchPicker(NutritionProvider provider) {
    final query = _batchSearchController.text.trim();
    final food = _findFood(provider.foods, query);
    if (food == null) {
      _showSnack('Pilih makanan dari daftar terlebih dahulu.');
      return;
    }
    final weight =
        double.tryParse(_batchWeightController.text.trim().replaceAll(',', '.')) ??
            100;
    if (weight <= 0) {
      _showSnack('Berat harus lebih dari 0 gram.');
      return;
    }
    provider.addDraft(food, weightGram: weight);
    _batchSearchController.clear();
    _batchWeightController.text = '100';
  }

  Future<void> _saveDraft(NutritionProvider provider) async {
    final childId = _childId;
    if (childId == null || childId.isEmpty) {
      _showSnack('Pilih profil anak terlebih dahulu.');
      return;
    }
    if (provider.draft.isEmpty) {
      _showSnack('Tambahkan makanan terlebih dahulu.');
      return;
    }

    final saved = await provider.saveDraftToDiary(
      childId: childId,
      date: _dateString,
      mealSlot: _mealSlot,
    );

    if (!mounted) return;
    if (saved) {
      _showSnack('Asupan berhasil disimpan ke diary.');
    } else {
      _showSnack('Belum tersinkron. Data disimpan dan akan dicoba lagi.');
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
      await _loadChildData();
    }
  }

  Future<void> _openTargetSheet(NutritionProvider provider) async {
    final childId = _childId;
    if (childId == null || childId.isEmpty) {
      _showSnack('Pilih profil anak terlebih dahulu.');
      return;
    }

    final result = await showModalBottomSheet<NutritionTarget>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _TargetSheet(
        childId: childId,
        initial: provider.target,
      ),
    );
    if (result != null) {
      await provider.saveTarget(childId, result);
      if (mounted) _showSnack('Target harian diperbarui.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(nutritionProvider);

    return Scaffold(
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
          'Nutrisi Anak',
          style: AppTypography.headingScreen.copyWith(
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atur Target',
            onPressed: () => _openTargetSheet(provider),
            icon: const Icon(
              Icons.tune_rounded,
              color: AppColors.primaryGreenDark,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _tabButton(
                      'Hitung Cepat',
                      _tab == 0,
                      () => setState(() => _tab = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _tabButton(
                      'Susun Asupan',
                      _tab == 1,
                      () => setState(() => _tab = 1),
                    ),
                  ),
                ],
              ),
            ),
            if (provider.isOfflineCatalog)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF0C36B)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        size: 16, color: Color(0xFF9A6700)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Katalog memakai data offline.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9A6700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _tab == 0
                  ? _buildQuickTab(provider)
                  : _buildStackTab(provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? AppColors.primaryGreen
                : AppColors.primaryGreen.withValues(alpha: 0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : AppColors.primaryGreenDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTab(NutritionProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        Text(
          'Hitung kandungan gizi satu makanan, lalu tambahkan ke asupan harian.',
          style: AppTypography.bodySecondary.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 12),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel(Icons.search_rounded, 'Cari makanan'),
              const SizedBox(height: 6),
              Autocomplete<FoodItem>(
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return provider.foods.take(8);
                  return provider.foods.where(
                    (food) => food.name.toLowerCase().contains(query),
                  );
                },
                displayStringForOption: (food) => food.name,
                onSelected: (food) {
                  setState(() {
                    _quickFood = food;
                    _quickSearchController.text = food.name;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (value) {
                      _quickSearchController.text = value;
                      _quickFood = null;
                    },
                    decoration: _decoration(
                      'Contoh: Nasi Putih, Tempe Goreng...',
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(Icons.scale_rounded, 'Jumlah'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _quickQuantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: _decoration('100'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel(Icons.straighten_rounded, 'Satuan'),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _unit,
                          isExpanded: true,
                          decoration: _decoration(''),
                          items: const ['gram', 'porsi', 'potong', 'butir', 'gelas']
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _unit = value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _fieldLabel(Icons.restaurant_rounded, 'Cara pengolahan'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _preparation,
                isExpanded: true,
                decoration: _decoration(''),
                items: const [
                  'Tanpa tambahan minyak',
                  'Direbus',
                  'Dikukus',
                  'Dipanggang',
                  'Digoreng',
                ]
                    .map(
                      (prep) => DropdownMenuItem(
                        value: prep,
                        child: Text(prep, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _preparation = value);
                },
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _calculateQuick(provider),
                  icon: const Icon(Icons.calculate_rounded, size: 18),
                  label: const Text('Hitung Nilai Gizi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_quickResult != null && _quickFood != null) ...[
          const SizedBox(height: 12),
          _quickResultCard(_quickFood!, _quickResult!, provider),
        ],
      ],
    );
  }

  Widget _quickResultCard(
    FoodItem food,
    NutritionValues values,
    NutritionProvider provider,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _categoryIcon(food.category, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: AppTypography.titleCard.copyWith(fontSize: 15),
                    ),
                    Text(
                      '${_quickWeightGram.toStringAsFixed(0)} g • ${_preparation.toLowerCase()}',
                      style: AppTypography.bodySecondary.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _nutrientGrid(values),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addQuickToDraft(provider),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tambahkan ke Asupan'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreenDark,
                    side: BorderSide(
                      color: AppColors.primaryGreen.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStackTab(NutritionProvider provider) {
    final totals = provider.batchTotals;
    final target = provider.target.values;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel(Icons.add_circle_outline_rounded,
                  'Tambah makanan ke asupan'),
              const SizedBox(height: 8),
              Autocomplete<FoodItem>(
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return provider.foods.take(8);
                  return provider.foods.where(
                    (food) => food.name.toLowerCase().contains(query),
                  );
                },
                displayStringForOption: (food) => food.name,
                onSelected: (food) {
                  _batchSearchController.text = food.name;
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (value) => _batchSearchController.text = value,
                    decoration: _decoration('Cari makanan...'),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _batchWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _decoration('Berat (gram)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addFromBatchPicker(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(92, 44),
                    ),
                    child: const Text('Tambah'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (provider.draft.isEmpty)
          _emptyDraft()
        else
          _card(
            child: Column(
              children: [
                for (int i = 0; i < provider.draft.length; i++)
                  _DraftRow(
                    key: ValueKey('${provider.draft[i].food.id}-$i'),
                    item: provider.draft[i],
                    onWeightChanged: (weight) =>
                        provider.updateDraftWeight(i, weight),
                    onDelete: () => provider.removeDraft(i),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        _targetProgressCard(totals, target, provider),
        const SizedBox(height: 12),
        _saveCard(provider),
        if (provider.pendingSyncCount > 0) ...[
          const SizedBox(height: 12),
          _pendingCard(provider),
        ],
        if (provider.summary != null) ...[
          const SizedBox(height: 12),
          _dailySummaryCard(provider.summary!),
        ],
      ],
    );
  }

  Widget _emptyDraft() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.restaurant_menu_rounded,
            size: 36,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada makanan',
            style: AppTypography.titleCard.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan makanan untuk melihat total asupan dan target harian.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _targetProgressCard(
    NutritionValues totals,
    NutritionValues target,
    NutritionProvider provider,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total Asupan',
                  style: AppTypography.titleCard.copyWith(fontSize: 15),
                ),
              ),
              TextButton.icon(
                onPressed: () => _openTargetSheet(provider),
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text(
                  'Atur Target',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _progressRow(
            'Kalori',
            totals.caloriesKkal.toDouble(),
            target.caloriesKkal.toDouble(),
            'kkal',
          ),
          _progressRow(
            'Protein',
            totals.proteinGram,
            target.proteinGram,
            'g',
          ),
          _progressRow(
            'Karbohidrat',
            totals.carbsGram,
            target.carbsGram,
            'g',
          ),
          _progressRow('Lemak', totals.fatGram, target.fatGram, 'g'),
          _progressRow('Gula', totals.sugarGram, target.sugarGram, 'g'),
          _progressRow('Serat', totals.fiberGram, target.fiberGram, 'g'),
        ],
      ),
    );
  }

  Widget _progressRow(
    String label,
    double value,
    double target,
    String unit,
  ) {
    final ratio = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                '${_formatNumber(value)} / ${_formatNumber(target)} $unit',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8EEEA),
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio >= 1
                    ? const Color(0xFFD97706)
                    : AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveCard(NutritionProvider provider) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fieldLabel(Icons.event_note_rounded, 'Simpan ke diary'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_rounded, size: 15),
                  label: Text(
                    DateFormat('d MMM yyyy').format(_date),
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreenDark,
                    side: BorderSide(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _mealSlot,
                  isExpanded: true,
                  decoration: _decoration(''),
                  items: const ['sarapan', 'siang', 'camilan', 'malam']
                      .map(
                        (slot) => DropdownMenuItem(
                          value: slot,
                          child: Text(
                            slot,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _mealSlot = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isSaving ? null : () => _saveDraft(provider),
              icon: provider.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_rounded, size: 18),
              label: Text(
                provider.isSaving ? 'Menyimpan...' : 'Simpan ke Diary',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingCard(NutritionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0C36B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_problem_rounded,
              size: 20, color: Color(0xFF9A6700)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${provider.pendingSyncCount} catatan menunggu sinkronisasi.',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9A6700),
              ),
            ),
          ),
          TextButton(
            onPressed: provider.flushPendingBatches,
            child: const Text('Coba Lagi', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _dailySummaryCard(NutritionSummary summary) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.today_rounded,
                size: 18,
                color: AppColors.primaryGreenDark,
              ),
              const SizedBox(width: 6),
              Text(
                'Ringkasan Diary',
                style: AppTypography.titleCard.copyWith(fontSize: 14),
              ),
              const Spacer(),
              Text(
                summary.date,
                style: AppTypography.bodySecondary.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${summary.entries.length} catatan • ${summary.totals.caloriesKkal} kkal',
            style: AppTypography.bodySecondary.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 6),
          _nutrientGrid(summary.totals),
        ],
      ),
    );
  }

  Widget _nutrientGrid(NutritionValues values) {
    final items = [
      ('Kalori', '${values.caloriesKkal}', 'kkal'),
      ('Karbo', _formatNumber(values.carbsGram), 'g'),
      ('Protein', _formatNumber(values.proteinGram), 'g'),
      ('Lemak', _formatNumber(values.fatGram), 'g'),
      ('Gula', _formatNumber(values.sugarGram), 'g'),
      ('Serat', _formatNumber(values.fiberGram), 'g'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              width: 98,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      text: item.$2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreenDark,
                      ),
                      children: [
                        TextSpan(
                          text: ' ${item.$3}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
        ),
      ),
      child: child,
    );
  }

  Widget _fieldLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primaryGreenDark),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _categoryIcon(String category, {double size = 20}) {
    IconData icon;
    Color color;
    switch (category) {
      case 'lauk_pauk':
        icon = Icons.set_meal_rounded;
        color = const Color(0xFFB45309);
        break;
      case 'sayuran':
        icon = Icons.eco_rounded;
        color = AppColors.primaryGreen;
        break;
      case 'buah':
        icon = Icons.apple_rounded;
        color = const Color(0xFFDC2626);
        break;
      case 'minuman_camilan':
        icon = Icons.local_cafe_rounded;
        color = const Color(0xFF7C3AED);
        break;
      case 'makanan_pokok':
      default:
        icon = Icons.rice_bowl_rounded;
        color = const Color(0xFFCA8A04);
        break;
    }
    return Icon(icon, size: size, color: color);
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF4F6F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }
}

class _DraftRow extends StatefulWidget {
  final NutritionDraftItem item;
  final ValueChanged<double> onWeightChanged;
  final VoidCallback onDelete;

  const _DraftRow({
    super.key,
    required this.item,
    required this.onWeightChanged,
    required this.onDelete,
  });

  @override
  State<_DraftRow> createState() => _DraftRowState();
}

class _DraftRowState extends State<_DraftRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.weightGram.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.item.values;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.food.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${values.caloriesKkal} kkal • P ${values.proteinGram}g • K ${values.carbsGram}g',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            child: TextField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                isDense: true,
                suffixText: 'g',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final parsed = double.tryParse(value.replaceAll(',', '.'));
                if (parsed != null) widget.onWeightChanged(parsed);
              },
            ),
          ),
          IconButton(
            onPressed: widget.onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetSheet extends StatefulWidget {
  final String childId;
  final NutritionTarget initial;

  const _TargetSheet({required this.childId, required this.initial});

  @override
  State<_TargetSheet> createState() => _TargetSheetState();
}

class _TargetSheetState extends State<_TargetSheet> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final values = widget.initial.values;
    _controllers = {
      'caloriesKkal': TextEditingController(
        text: values.caloriesKkal.toString(),
      ),
      'carbsGram': TextEditingController(text: _plain(values.carbsGram)),
      'proteinGram': TextEditingController(text: _plain(values.proteinGram)),
      'fatGram': TextEditingController(text: _plain(values.fatGram)),
      'sugarGram': TextEditingController(text: _plain(values.sugarGram)),
      'fiberGram': TextEditingController(text: _plain(values.fiberGram)),
    };
  }

  String _plain(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double? _read(String key) {
    return double.tryParse(
      _controllers[key]!.text.trim().replaceAll(',', '.'),
    );
  }

  void _save() {
    final calories = _read('caloriesKkal');
    final carbs = _read('carbsGram');
    final protein = _read('proteinGram');
    final fat = _read('fatGram');
    final sugar = _read('sugarGram');
    final fiber = _read('fiberGram');

    if ([calories, carbs, protein, fat, sugar, fiber].any((v) => v == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua target harus berupa angka.')),
      );
      return;
    }

    Navigator.of(context).pop(
      NutritionTarget(
        values: NutritionValues(
          caloriesKkal: calories!.round(),
          carbsGram: carbs!,
          proteinGram: protein!,
          fatGram: fat!,
          sugarGram: sugar!,
          fiberGram: fiber!,
        ),
        source: 'MANUAL',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      ('caloriesKkal', 'Kalori', 'kkal'),
      ('carbsGram', 'Karbohidrat', 'g'),
      ('proteinGram', 'Protein', 'g'),
      ('fatGram', 'Lemak', 'g'),
      ('sugarGram', 'Gula', 'g'),
      ('fiberGram', 'Serat', 'g'),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 18,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Target Harian Anak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Angka target bersifat edukatif dan dapat disesuaikan. Konsultasikan dengan tenaga kesehatan.',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            for (final field in fields) ...[
              Text(
                '${field.$2} (${field.$3})',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _controllers[field.$1],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: const Color(0xFFF4F6F8),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Simpan Target'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
