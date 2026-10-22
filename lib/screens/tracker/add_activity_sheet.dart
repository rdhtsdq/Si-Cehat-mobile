import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/activity_log_model.dart';
import '../../providers/app_providers.dart';

class AddActivitySheet extends ConsumerStatefulWidget {
  final dynamic childId;
  final DateTime date;

  const AddActivitySheet({
    super.key,
    required this.childId,
    required this.date,
  });

  static Future<void> show(BuildContext context, {required dynamic childId, required DateTime date}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddActivitySheet(childId: childId, date: date),
    );
  }

  @override
  ConsumerState<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends ConsumerState<AddActivitySheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'Aktivitas Fisik';
  int _selectedDuration = 30;
  String _selectedIntensity = 'Sedang';
  bool _isSaving = false;

  final Map<String, List<String>> _presetsByCategory = {
    'Aktivitas Fisik': [
      'Bermain Sepeda',
      'Lari / Kejar-kejaran',
      'Sepak Bola',
      'Lompat Tali',
      'Berenang',
      'Senam Pagi',
      'Jalan Santai',
    ],
    'Hidrasi Sehat': [
      'Minum Air Putih',
      'Minum Air Hangat Pagi',
      'Infused Water Buah',
    ],
    'Gizi Seimbang': [
      'Makan Sayur Hijau',
      'Makan Buah Potong',
      'Minum Susu Segar',
      'Sarapan Seimbang',
    ],
    'Istirahat': [
      'Tidur Malam Teratur',
      'Tidur Siang Cukup',
      'Istirahat Siang',
    ],
  };

  final List<int> _durations = [15, 30, 45, 60, 90];
  final List<String> _intensities = ['Ringan', 'Sedang', 'Kuat'];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan nama aktivitas terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final dateStr = widget.date.toIso8601String().substring(0, 10);

    final activity = ActivityLogModel(
      childId: widget.childId,
      date: dateStr,
      title: title,
      category: _selectedCategory,
      durationMinutes: _selectedCategory == 'Aktivitas Fisik' ? _selectedDuration : 0,
      intensity: _selectedIntensity,
      notes: _notesController.text.trim(),
    );

    try {
      await ref.read(trackerProvider).addActivity(activity);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aktivitas "$title" berhasil dicatat!'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mencatat: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final presets = _presetsByCategory[_selectedCategory] ?? [];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catat Aktivitas Baru',
                  style: AppTypography.headingScreen.copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Pilihan Kategori
            Text('Kategori Aktivitas', style: AppTypography.bodySecondary.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presetsByCategory.keys.map((cat) {
                  final isSel = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSel,
                      selectedColor: AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedCategory = cat;
                            _titleController.clear();
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Rekomendasi / Preset Cepat
            Text('Rekomendasi Cepat:', style: AppTypography.bodySecondary.copyWith(fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: presets.map((p) {
                final isSelected = _titleController.text == p;
                return ActionChip(
                  label: Text(p, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.primaryGreenDark)),
                  backgroundColor: isSelected ? AppColors.primaryGreen : AppColors.veryLightGreen,
                  onPressed: () => setState(() => _titleController.text = p),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Input Nama Aktivitas
            Text('Nama Aktivitas', style: AppTypography.bodySecondary.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Misal: Bermain Sepeda Sore',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 14),

            // Durasi (khusus Aktivitas Fisik)
            if (_selectedCategory == 'Aktivitas Fisik') ...[
              Text('Durasi Aktivitas (Menit)', style: AppTypography.bodySecondary.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _durations.map((d) {
                  final isSel = d == _selectedDuration;
                  return ChoiceChip(
                    label: Text('$d mnt'),
                    selected: isSel,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedDuration = d);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Intensitas
              Text('Tingkat Intensitas', style: AppTypography.bodySecondary.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: _intensities.map((intensity) {
                  final isSel = intensity == _selectedIntensity;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(intensity),
                      selected: isSel,
                      selectedColor: intensity == 'Kuat' ? Colors.orange[700] : AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedIntensity = intensity);
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],

            // Catatan
            Text('Catatan Tambahan (Opsional)', style: AppTypography.bodySecondary.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Misal: Bersama teman di taman kompleks',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 22),

            PrimaryButton(
              text: _isSaving ? 'Menyimpan...' : 'Simpan Aktivitas',
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
