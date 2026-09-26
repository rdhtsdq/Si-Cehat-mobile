import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/safety_banner.dart';
import '../menu/menu_catalog_screen.dart';

class ScreeningResultScreen extends StatelessWidget {
  const ScreeningResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // SAFETY BADGE PERMANEN SESUAI SPEC S10
              const SafetyBanner(
                text: 'SIMULASI · 50% hanya contoh desain tampilan, bukan risiko klinis anak.',
                type: BannerType.simulation,
              ),
              const SizedBox(height: 16),

              // Donut chart separuh hijau pekat (#4CAF50) dan separuh hijau muda (#8BC34A)
              Center(
                child: SizedBox(
                  width: 170,
                  height: 170,
                  child: CustomPaint(
                    painter: _DonutChartPainter(),
                    child: Center(
                      child: Text(
                        '50%',
                        style: AppTypography.headingScreen.copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Teks center: "Anda memiliki risiko sedang terhadap diabetes melitus"
              Text(
                'Anda memiliki risiko sedang\nterhadap diabetes melitus',
                textAlign: TextAlign.center,
                style: AppTypography.titleCard.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 32),

              // Heading kiri bold "Rekomendasi untuk Anda"
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rekomendasi untuk Anda',
                  style: AppTypography.titleCard.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Tiga baris rekomendasi dengan penanda panah/chevron sesuai PDF S10
              _buildRecommendationItem(
                text: 'Perbanyak sayur & buah',
                icon: Icons.eco_outlined,
              ),
              const SizedBox(height: 10),
              _buildRecommendationItem(
                text: 'Batasi minuman manis',
                icon: Icons.no_drinks_outlined,
              ),
              const SizedBox(height: 10),
              _buildRecommendationItem(
                text: 'Ajak anak aktif bergerak',
                icon: Icons.directions_run_outlined,
              ),

              const SizedBox(height: 36),

              // Tombol hijau "Selanjutnya" menuju Menu Tradisional (S12)
              PrimaryButton(
                text: 'Selanjutnya',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MenuCatalogScreen()),
                  );
                },
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primaryGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyRegular.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 26.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paintGreenDark = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintGreenLight = Paint()
      ..color = AppColors.lightGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Separuh atas/kiri hijau tua (#4CAF50)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi,
      false,
      paintGreenDark,
    );

    // Separuh bawah/kanan hijau muda (#8BC34A)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi / 2,
      math.pi,
      false,
      paintGreenLight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
