import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/measurement_model.dart';
import '../../providers/profile_provider.dart';
import '../../providers/tracker_provider.dart';

class AddMeasurementSheet extends StatefulWidget {
  const AddMeasurementSheet({super.key});

  @override
  State<AddMeasurementSheet> createState() => _AddMeasurementSheetState();
}

class _AddMeasurementSheetState extends State<AddMeasurementSheet> {
  final _dateController = TextEditingController(
    text: DateTime.now().toString().substring(0, 10),
  );
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();
  String _source = 'Mandiri';
  String? _weightError;
  String? _heightError;
  bool _isSaving = false;

  @override
  void dispose() {
    _dateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeChild = context.watch<ProfileProvider>().activeChild;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tambah Pengukuran BB & TB',
                style: AppTypography.titleCard.copyWith(fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: _pickDate,
            child: AbsorbPointer(
              child: AppTextField(
                label: 'Tanggal Pengukuran (YYYY-MM-DD)',
                hintText: 'Pilih tanggal pengukuran',
                controller: _dateController,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Berat Badan (Kg)',
                  hintText: 'Masukkan BB (kg)',
                  controller: _weightController,
                  errorText: _weightError,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    if (_weightError != null) {
                      setState(() => _weightError = null);
                    }
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: AppTextField(
                  label: 'Tinggi Badan (Cm)',
                  hintText: 'Masukkan TB (cm)',
                  controller: _heightController,
                  errorText: _heightError,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    if (_heightError != null) {
                      setState(() => _heightError = null);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Sumber Pengukuran', style: AppTypography.labelInput),
          const SizedBox(height: 6),
          Row(
            children: ['Mandiri', 'Posyandu', 'Puskesmas'].map((src) {
              final isSel = _source == src;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(src),
                  selected: isSel,
                  onSelected: (val) {
                    if (val) setState(() => _source = src);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Catatan Tambahan (Opsional)',
            hintText: 'Misal: Kondisi sehat setelah sarapan',
            controller: _notesController,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Simpan Pengukuran',
            isLoading: _isSaving,
            onPressed: () async {
              if (activeChild == null) return;
              final weight = double.tryParse(
                _weightController.text.trim().replaceAll(',', '.'),
              );
              final height = double.tryParse(
                _heightController.text.trim().replaceAll(',', '.'),
              );

              setState(() {
                _weightError = (weight == null || weight < 3 || weight > 150)
                    ? 'BB tidak valid (3-150 kg)'
                    : null;
                _heightError = (height == null || height < 40 || height > 220)
                    ? 'TB tidak valid (40-220 cm)'
                    : null;
              });

              if (_weightError != null || _heightError != null) return;

              setState(() => _isSaving = true);

              final measurement = MeasurementModel(
                childId: activeChild.id,
                date: _dateController.text.trim(),
                weight: weight!,
                height: height!,
                source: _source,
                notes: _notesController.text.trim(),
              );

              await context.read<TrackerProvider>().addMeasurement(measurement);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data pengukuran berhasil ditambahkan'),
                  ),
                );
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
