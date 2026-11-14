import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/calm_widgets.dart';
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

  RiskLevel get _level {
    switch (category.toUpperCase()) {
      case 'TINGGI':
        return RiskLevel.high;
      case 'SEDANG':
        return RiskLevel.medium;
      case 'RENDAH':
        return RiskLevel.low;
      default:
        return RiskLevel.unknown;
    }
  }

  String get _riskLabel {
    switch (category.toUpperCase()) {
      case 'TINGGI':
        return 'Risiko Tinggi';
      case 'SEDANG':
        return 'Risiko Sedang';
      case 'RENDAH':
        return 'Risiko Rendah';
      default:
        return 'Kategori $category';
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleMessage =
        statusText ??
        (category.toUpperCase() == 'TINGGI'
            ? 'Anak memiliki potensi risiko tinggi terhadap diabetes melitus'
            : category.toUpperCase() == 'RENDAH'
            ? 'Anak memiliki risiko rendah terhadap diabetes melitus'
            : 'Anak memiliki risiko sedang terhadap diabetes melitus');

    final palette = RiskPalette.of(_level);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          AppHeader(
            compact: true,
            title: 'Hasil Skrining',
            onBack: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  SafetyBanner(
                    text: isRealResult
                        ? 'Hasil analisis berdasarkan antropometri & gaya hidup anak.'
                        : 'SIMULASI · 50% hanya contoh desain tampilan, bukan risiko klinis anak.',
                    type: isRealResult
                        ? BannerType.notice
                        : BannerType.simulation,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  ),
                  AppCard(
                    radius: AppRadius.xl,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CustomPaint(
                            painter: _DonutChartPainter(
                              percentage: score.toDouble(),
                              color: palette.foreground,
                              trackColor: AppColors.primarySoft,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$score%',
                                    style: AppTypography.display.copyWith(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: palette.foreground,
                                    ),
                                  ),
                                  Text(
                                    'skor risiko',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        RiskBadge(label: _riskLabel, level: _level),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          titleMessage,
                          textAlign: TextAlign.center,
                          style: AppTypography.h2.copyWith(
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rekomendasi Tindak Lanjut',
                      style: AppTypography.h2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppListGroup(
                    children: [
                      for (final rec in recommendations)
                        AppListTile(
                          icon: Icons.check_circle_outline_rounded,
                          iconBackground: AppColors.primarySoft,
                          iconForeground: AppColors.primary,
                          title: rec,
                          trailing: const SizedBox.shrink(),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
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
                  const SizedBox(height: AppSpacing.xs),
                  GhostButton(
                    label: 'Kembali ke Beranda',
                    height: 48,
                    expanded: true,
                    onPressed: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color trackColor;

  _DonutChartPainter({
    this.percentage = 50.0,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 18.0;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    final sweepAngle = 2 * math.pi * (percentage / 100.0);
    final fillPaint = Paint()
      ..color = color
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
      oldDelegate.percentage != percentage ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor;
}
