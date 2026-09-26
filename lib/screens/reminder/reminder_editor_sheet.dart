import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/reminder_provider.dart';

class ReminderEditorSheet extends StatefulWidget {
  const ReminderEditorSheet({super.key});

  @override
  State<ReminderEditorSheet> createState() => _ReminderEditorSheetState();
}

class _ReminderEditorSheetState extends State<ReminderEditorSheet> {
  final _titleController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    final formattedTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

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
              Text('Tambah Pengingat Baru', style: AppTypography.titleCard.copyWith(fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 14),

          AppTextField(
            label: 'Nama Kegiatan / Pengingat',
            hintText: 'Contoh: Minum air putih sore',
            controller: _titleController,
          ),
          const SizedBox(height: 16),

          Text('Waktu Pengingat', style: AppTypography.labelInput),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (picked != null) {
                setState(() => _selectedTime = picked);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedTime,
                    style: AppTypography.bodyRegular.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                  const Icon(Icons.access_time, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            text: 'Simpan Pengingat',
            onPressed: () async {
              if (_titleController.text.trim().isEmpty) return;
              await context.read<ReminderProvider>().addReminder(
                    _titleController.text.trim(),
                    formattedTime,
                  );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Jadwal pengingat berhasil disimpan')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
