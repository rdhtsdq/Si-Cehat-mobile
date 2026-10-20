import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/reminder_model.dart';
import '../../providers/reminder_provider.dart';

class ReminderEditorSheet extends StatefulWidget {
  final ReminderModel? reminder;

  const ReminderEditorSheet({super.key, this.reminder});

  @override
  State<ReminderEditorSheet> createState() => _ReminderEditorSheetState();
}

class _ReminderEditorSheetState extends State<ReminderEditorSheet> {
  late TextEditingController _titleController;
  late TimeOfDay _selectedTime;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder?.title ?? '');

    if (widget.reminder != null) {
      final parts = widget.reminder!.time.split(':');
      final h = int.tryParse(parts[0]) ?? 7;
      final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      _selectedTime = TimeOfDay(hour: h, minute: m);
      _selectedCategory = widget.reminder!.category;
    } else {
      _selectedTime = const TimeOfDay(hour: 7, minute: 0);
      _selectedCategory = 'umum';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;
    final formattedTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final categories = ['makan', 'minum', 'aktivitas', 'tidur', 'umum'];

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
                isEditing ? 'Edit Pengingat' : 'Tambah Pengingat Baru',
                style: AppTypography.titleCard.copyWith(fontSize: 18),
              ),
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
          const SizedBox(height: 16),

          Text('Kategori Pengingat', style: AppTypography.labelInput),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      cat[0].toUpperCase() + cat.substring(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textDark,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor: AppColors.fieldBackground,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            text: isEditing ? 'Perbarui Pengingat' : 'Simpan Pengingat',
            onPressed: () async {
              final title = _titleController.text.trim();
              if (title.isEmpty) return;

              final prov = context.read<ReminderProvider>();
              if (isEditing) {
                await prov.updateReminder(
                  widget.reminder!.id,
                  title: title,
                  time: formattedTime,
                  category: _selectedCategory,
                  repeatDays: widget.reminder!.repeatDays,
                  isEnabled: widget.reminder!.isEnabled,
                );
              } else {
                await prov.addReminder(
                  title,
                  formattedTime,
                  category: _selectedCategory,
                );
              }

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing
                        ? 'Jadwal pengingat berhasil diperbarui'
                        : 'Jadwal pengingat berhasil disimpan'),
                  ),
                );
              }
            },
          ),

          if (isEditing) ...[
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus Pengingat Ini'),
                onPressed: () async {
                  await context.read<ReminderProvider>().deleteReminder(widget.reminder!.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pengingat telah dihapus')),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
