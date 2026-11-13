import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/nutrition_model.dart';
import '../../providers/app_providers.dart';

/// Simplified child nutrition view: a daily diary summary card on top, and a
/// scrollable list of logged food entries below that can be deleted.
///
/// `initialFood` and `initialMeal` are kept for backward compatibility with
/// older "add to diary" callers; adding food now happens via the photo flow.
class FoodDiaryScreen extends ConsumerStatefulWidget {
  final String? initialFood;
  final String? initialMeal;

  const FoodDiaryScreen({super.key, this.initialFood, this.initialMeal});

  @override
  ConsumerState<FoodDiaryScreen> createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends ConsumerState<FoodDiaryScreen> {
  DateTime _date = DateTime.now();
  bool _deleting = false;

  String? get _childId {
    final child = ref.read(profileProvider).activeChild;
    return child?.id?.toString();
  }

  String get _dateString => DateFormat('yyyy-MM-dd').format(_date);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final childId = _childId;
    if (childId == null || childId.isEmpty) return;
    Future.microtask(
      () => ref.read(nutritionProvider).loadSummary(childId, _dateString),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null && picked != _date) {
      setState(() => _date = picked);
      _load();
    }
  }

  Future<void> _confirmDelete(NutritionEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('Hapus "${entry.foodName}" dari diary hari ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final childId = _childId;
    if (childId == null || childId.isEmpty) return;

    setState(() => _deleting = true);
    final provider = ref.read(nutritionProvider);
    final ok = await provider.deleteEntry(
      childId: childId,
      entryId: entry.id,
      date: _dateString,
    );
    if (!mounted) return;
    setState(() => _deleting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? '${entry.foodName} dihapus dari diary.'
              : 'Gagal menghapus catatan.',
        ),
      ),
    );
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

  ({IconData icon, String label}) _mealMeta(String slot) {
    switch (slot.toLowerCase()) {
      case 'sarapan':
        return (icon: Icons.wb_sunny_outlined, label: 'Sarapan');
      case 'siang':
      case 'makan_siang':
        return (icon: Icons.lunch_dining_outlined, label: 'Makan Siang');
      case 'malam':
      case 'makan_malam':
        return (icon: Icons.dinner_dining_outlined, label: 'Makan Malam');
      case 'camilan':
      default:
        return (icon: Icons.cookie_outlined, label: 'Camilan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = ref.watch(nutritionProvider);
    final summary = nutrition.summary;

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
          'Diary Makan',
          style: AppTypography.headingScreen.copyWith(
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async => _load(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _datePicker(),
              const SizedBox(height: 14),
              _summaryCard(summary),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat',
                    style: AppTypography.titleCard.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (summary != null)
                    Text(
                      '${summary.entries.length} catatan',
                      style: AppTypography.bodySecondary.copyWith(fontSize: 11),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _entriesList(summary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datePicker() => InkWell(
    borderRadius: BorderRadius.circular(8),
    onTap: _pickDate,
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

  Widget _summaryCard(NutritionSummary? summary) {
    final totalCal = summary?.totals.caloriesKkal ?? 0;
    final targetCal =
        summary?.target.caloriesKkal ??
        ref.read(nutritionProvider).target.values.caloriesKkal;
    final ratio = targetCal <= 0 ? 0.0 : (totalCal / targetCal).clamp(0.0, 1.0);
    final remaining = targetCal - totalCal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            children: [
              const Icon(
                Icons.restaurant_menu_rounded,
                size: 18,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 6),
              Text(
                'Ringkasan Diary',
                style: AppTypography.titleCard.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalCal',
                style: AppTypography.titleCard.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ $targetCal kkal',
                  style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8EEEA),
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio >= 1 ? const Color(0xFFD97706) : AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            remaining >= 0
                ? 'Sisa $remaining kkal hari ini'
                : 'Melebihi target ${-remaining} kkal',
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 11,
              color: remaining >= 0
                  ? AppColors.textSecondary
                  : const Color(0xFFD97706),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entriesList(NutritionSummary? summary) {
    final entries = summary?.entries ?? const <NutritionEntry>[];

    if (summary == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: Text(
          'Memuat riwayat...',
          style: AppTypography.bodySecondary.copyWith(fontSize: 12),
        ),
      );
    }

    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.fastfood_outlined,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada catatan asupan pada tanggal ini.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(children: [for (final entry in entries) _entryCard(entry)]);
  }

  Widget _entryCard(NutritionEntry entry) {
    final meta = _mealMeta(entry.mealSlot);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.veryLightGreen,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(meta.icon, size: 18, color: AppColors.primaryGreenDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.foodName,
                  style: AppTypography.titleCard.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${meta.label} • ${entry.portion}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySecondary.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.values.caloriesKkal} kkal',
            style: AppTypography.titleCard.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreenDark,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: Colors.redAccent,
            ),
            tooltip: 'Hapus catatan',
            onPressed: _deleting ? null : () => _confirmDelete(entry),
          ),
        ],
      ),
    );
  }
}
