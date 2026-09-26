import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';

class HabitLogView extends StatefulWidget {
  const HabitLogView({super.key});

  @override
  State<HabitLogView> createState() => _HabitLogViewState();
}

class _HabitLogViewState extends State<HabitLogView> {
  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Bermain Sepeda Sore',
      'duration': '45 menit',
      'category': 'Aktivitas Fisik',
      'icon': Icons.pedal_bike,
    },
    {
      'title': 'Minum Air Putih',
      'duration': '5 Gelas (1.250 ml)',
      'category': 'Hidrasi Sehat',
      'icon': Icons.water_drop_outlined,
    },
    {
      'title': 'Makan Sayur Asem & Tempe',
      'duration': 'Porsi Sedang',
      'category': 'Gizi Seimbang',
      'icon': Icons.restaurant,
    },
    {
      'title': 'Tidur Malam Nyenyak',
      'duration': '9 Jam (21:00 - 06:00)',
      'category': 'Istirahat',
      'icon': Icons.bedtime_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Catatan Kebiasaan Hari Ini',
          style: AppTypography.titleCard.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          'Catatan pola aktivitas dan kebiasaan sehat harian anak.',
          style: AppTypography.bodySecondary.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 16),

        ..._activities.map((act) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8E8E8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.veryLightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(act['icon'] as IconData, color: AppColors.primaryGreenDark, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act['title'] as String,
                          style: AppTypography.bodyRegular.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${act['category']} • ${act['duration']}',
                          style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_outline, color: AppColors.primaryGreen, size: 20),
                ],
              ),
            )),

        const SizedBox(height: 16),
        PrimaryButton(
          text: '+ Catat Aktivitas Baru',
          isOutlined: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Form pencatatan aktivitas tersimpan secara lokal')),
            );
          },
        ),
      ],
    );
  }
}
