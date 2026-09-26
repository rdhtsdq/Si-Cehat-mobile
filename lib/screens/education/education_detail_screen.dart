import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/safety_banner.dart';
import '../../data/models/education_model.dart';

class EducationDetailScreen extends StatelessWidget {
  final EducationModel item;

  const EducationDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isVideo = item.type == 'video';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          item.title,
          style: AppTypography.headingScreen.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Player Placeholder Box
              Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isVideo ? Icons.play_circle_fill : Icons.podcasts,
                        size: 56,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pratinjau Materi Lokal (${item.duration})',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const SafetyBanner(
                text: 'Pratinjau materi · media remote memerlukan koneksi internet aktif pada rilis pilot.',
                type: BannerType.offline,
              ),
              const SizedBox(height: 10),

              Text(
                item.title,
                style: AppTypography.headingScreen.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    item.speakerOrSource,
                    style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    item.duration,
                    style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              Text(
                'Ringkasan Materi:',
                style: AppTypography.titleCard.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                item.summary,
                style: AppTypography.bodyRegular.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreenDark,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                item.contentBody,
                style: AppTypography.bodyRegular.copyWith(
                  height: 1.5,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
