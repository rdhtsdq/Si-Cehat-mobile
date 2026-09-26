import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';

class ScreeningDemoDialog extends StatelessWidget {
  final VoidCallback onProceedToExample;

  const ScreeningDemoDialog({super.key, required this.onProceedToExample});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFFE65100),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Transparansi Skrining',
              style: AppTypography.titleCard.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Instrumen skrining klinis resmi untuk anak 6-12 tahun sedang dalam proses peninjauan ahli.\n\nData yang Anda masukkan saat ini tidak menghasilkan penilaian risiko medis riil.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary.copyWith(
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Lihat Contoh Hasil (Simulasi)',
              onPressed: () {
                Navigator.of(context).pop();
                onProceedToExample();
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Kembali ke Form',
                style: AppTypography.bodySecondary.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
