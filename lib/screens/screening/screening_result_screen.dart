import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/safety_banner.dart';
import '../menu/menu_catalog_screen.dart';

class ScreeningResultScreen extends StatelessWidget {
  final int score;
  final String category;
  final String? statusText;
  final List<String> recommendations;
  final bool isRealResult;

  const ScreeningResultScreen({
    super.key,
    this.score = 50,
    this.category = 'SEDANG',
    this.statusText,
    this.recommendations = const [
      'Perbanyak sayur & buah harian',
      'Batasi minuman berpemanis dan boba',
      'Aktivitas fisik aktif minimal 60 menit sehari',
    ],
    this.isRealResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleMessage =
        statusText ??
        (category.toUpperCase() == 'TINGGI'
            ? 'Anak memiliki potensi risiko tinggi\nterhadap diabetes melitus'
            : category.toUpperCase() == 'RENDAH'
            ? 'Anak memiliki risiko rendah\nterhadap diabetes melitus'
            : 'Anak memiliki risiko sedang\nterhadap diabetes melitus');

    Color categoryColor = AppColors.primaryGreen;
    if (category.toUpperCase() == 'TINGGI') {
      categoryColor = Colors.orange[800]!;
    } else if (category.toUpperCase() == 'SEDANG') {
      categoryColor = const Color(0xFFE6A23C);
    }

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
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text(
          'Hasil Skrining',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SafetyBanner(
                text: isRealResult
                    ? 'Hasil analisis berdasarkan antropometri & gaya hidup anak.'
                    : 'SIMULASI \u00b7 50% hanya contoh desain tampilan, bukan risiko klinis anak.',
                type: isRealResult ? BannerType.notice : BannerType.simulation,
              ),
              const SizedBox(height: 16),

              Center(
                child: SizedBox(
                  width: 170,
                  height: 170,
                  child: CustomPaint(
                    painter: _DonutChartPainter(percentage: score.toDouble()),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$score%',
                            style: AppTypography.headingScreen.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: categoryColor,
                            ),
                          ),
                          Text(
                            'Kategori $category',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: categoryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                titleMessage,
                textAlign: TextAlign.center,
                style: AppTypography.titleCard.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 32),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rekomendasi Tindak Lanjut',
                  style: AppTypography.titleCard.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              ...recommendations.map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRecommendationItem(
                    text: rec,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Selanjutnya',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MenuCatalogScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationItem({
    required String text,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyRegular.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double percentage;
  _DonutChartPainter({this.percentage = 50.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 18.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFE8F5E9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final sweepAngle = 2 * math.pi * (percentage / 100.0);
    final fillPaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.percentage != percentage;
}
