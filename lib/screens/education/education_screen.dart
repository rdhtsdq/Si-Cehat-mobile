import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../data/models/education_model.dart';
import '../../providers/education_provider.dart';
import 'education_detail_screen.dart';
import 'quiz_screen.dart';

class EducationScreen extends StatefulWidget {
  final bool showBackButton;

  const EducationScreen({super.key, this.showBackButton = false});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int _selectedTab = 0; // 0: Video, 1: Podcast, 2: Quiz

  @override
  Widget build(BuildContext context) {
    final eduProv = context.watch<EducationProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          'Edukasi',
          style: AppTypography.headingScreen.copyWith(fontSize: 24),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiga tab: Video aktif hijau, Podcast, Quiz abu muda sesuai PDF S15
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: 'Video',
                      isActive: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Podcast',
                      isActive: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Quiz',
                      isActive: _selectedTab == 2,
                      onTap: () => setState(() => _selectedTab = 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Daftar konten edukasi
              Expanded(
                child: _selectedTab == 2
                    ? _buildQuizPromptCard(context)
                    : _buildMediaList(
                        context,
                        _selectedTab == 0 ? eduProv.getVideos() : eduProv.getPodcasts(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primaryGreen : AppColors.fieldBackground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 42,
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.buttonText.copyWith(
              color: isActive ? Colors.white : AppColors.textDark,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaList(BuildContext context, List<EducationModel> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = items[index];
        final isVideo = item.type == 'video';

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EducationDetailScreen(item: item),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Row(
                children: [
                  // Thumbnail kiri sesuai PDF
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.paleGreenBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        isVideo ? Icons.play_circle_outline : Icons.headphones_outlined,
                        size: 36,
                        color: AppColors.primaryGreenDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Judul bold kanan, durasi abu di bawah
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTypography.titleCard.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              item.duration,
                              style: AppTypography.bodySecondary.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuizPromptCard(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.paleGreenBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.quiz_outlined, size: 64, color: AppColors.primaryGreenDark),
            const SizedBox(height: 16),
            Text(
              'Uji Pemahaman Hidup Sehat',
              style: AppTypography.titleCard.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Cek pemahaman Anda mengenai batas gula harian, bekal sehat, dan kebiasaan gerak aktif anak.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Mulai Kuis Sekarang',
                style: AppTypography.buttonText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
