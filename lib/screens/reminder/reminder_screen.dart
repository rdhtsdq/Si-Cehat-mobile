import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/services/local_notification_service.dart';
import '../../core/widgets/safety_banner.dart';
import '../../data/models/reminder_model.dart';
import '../../providers/app_providers.dart';
import 'reminder_editor_sheet.dart';
import '../diary/food_diary_screen.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final granted =
          await LocalNotificationService.instance.requestPermission();
      if (!granted && mounted) {
        setState(() => _permissionDenied = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reminderProv = ref.watch(reminderProvider);
    final reminders = reminderProv.reminders;
    final completedCount = reminderProv.completedTodayCount;
    final totalCount = reminders.length;

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
              if (_permissionDenied) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF0C36B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.notifications_off_rounded,
                        size: 18,
                        color: Color(0xFF9A6700),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Izin notifikasi belum aktif. Pengingat tidak akan muncul di luar aplikasi.',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9A6700),
                            height: 1.35,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final granted = await LocalNotificationService.instance
                              .requestPermission();
                          if (granted && mounted) {
                            setState(() => _permissionDenied = false);
                          }
                        },
                        child: const Text(
                          'Aktifkan',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Header aksi "+ Tambah Reminder"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => const ReminderEditorSheet(),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
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
                  if (totalCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.veryLightGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$completedCount/$totalCount Selesai',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreenDark,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress tracking bar
              if (totalCount > 0) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalCount > 0 ? (completedCount / totalCount) : 0,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const SafetyBanner(
                text: 'Jadwal tersimpan di perangkat dan disinkronkan ke akun keluarga. Pengingat ini memandu rutinitas hidup sehat anak.',
                type: BannerType.offline,
              ),
              const SizedBox(height: 12),

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
                ...reminders.map((r) => _buildReminderCard(context, ref, r)),

              const SizedBox(height: 16),
              SizedBox(
                width: 190,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FoodDiaryScreen()),
                  ),
                  icon: const Icon(Icons.book_outlined, size: 18),
                  label: const Text('Food Diary'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, WidgetRef ref, ReminderModel item) {
    final isDone = item.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFFF9FBF9) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDone ? AppColors.lightGreen : const Color(0xFFEEEEEE),
        ),
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
          // Checkbox complete button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? AppColors.primaryGreen : AppColors.textMuted,
              size: 24,
            ),
            onPressed: () {
              if (item.id != null) {
                ref.read(reminderProvider).toggleCompleteReminder(item.id);
              }
            },
          ),
          const SizedBox(width: 8),

          // Jam
          SizedBox(
            width: 55,
            child: Text(
              item.time,
              style: AppTypography.titleCard.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: item.isEnabled ? AppColors.textDark : AppColors.textMuted,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Judul & Kategori
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTypography.bodyRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: item.isEnabled ? AppColors.textDark : AppColors.textMuted,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.fieldBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.repeatDays,
                      style: AppTypography.bodySecondary.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tombol Edit
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.textSecondary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => ReminderEditorSheet(reminder: item),
              );
            },
          ),

          // Switch on/off
          Switch(
            value: item.isEnabled,
            activeThumbColor: AppColors.primaryGreen,
            activeTrackColor: AppColors.veryLightGreen,
            onChanged: (val) {
              if (item.id != null) {
                ref.read(reminderProvider).toggleReminder(item.id!, val);
              }
            },
          ),
        ],
      ),
    );
  }
}
