import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/safety_banner.dart';
import '../../data/models/reminder_model.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_editor_sheet.dart';
import '../diary/food_diary_screen.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderProv = context.watch<ReminderProvider>();
    final reminders = reminderProv.reminders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reminder',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teks aksi hijau "+ Tambah Reminder" di bawah app bar sesuai PDF S14
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (_) => const ReminderEditorSheet(),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tambah Reminder',
                        style: AppTypography.buttonText.copyWith(
                          color: AppColors.primaryGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const SafetyBanner(
                text:
                    'Jadwal tersimpan di perangkat. Pengingat ini berfungsi sebagai alarm kebiasaan keluarga.',
                type: BannerType.offline,
              ),

              // Empat card putih dengan shadow tipis dan radius sesuai PDF S14
              if (reminders.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'Belum ada jadwal pengingat aktif',
                      style: AppTypography.bodySecondary,
                    ),
                  ),
                )
              else
                ...reminders.map((r) => _buildReminderCard(context, r)),

              const SizedBox(height: 12),
              SizedBox(
                width: 190,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FoodDiaryScreen()),
                  ),
                  child: const Text('Food Diary'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, ReminderModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Jam di kiri sesuai PDF S14
          SizedBox(
            width: 60,
            child: Text(
              item.time,
              style: AppTypography.titleCard.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: item.isEnabled
                    ? AppColors.textDark
                    : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nama kegiatan di tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.bodyRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    color: item.isEnabled
                        ? AppColors.textDark
                        : AppColors.textMuted,
                  ),
                ),
                Text(
                  item.repeatDays,
                  style: AppTypography.bodySecondary.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Switch hijau di kanan
          Switch(
            value: item.isEnabled,
            activeThumbColor: AppColors.primaryGreen,
            activeTrackColor: AppColors.veryLightGreen,
            onChanged: (val) {
              if (item.id != null) {
                context.read<ReminderProvider>().toggleReminder(item.id!, val);
              }
            },
          ),
        ],
      ),
    );
  }
}
