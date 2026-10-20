import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../data/models/playlab_score_model.dart';

class PlayLabScoreDialog extends StatelessWidget {
  final PlayLabScoreResult result;
  final VoidCallback onDismiss;
  final VoidCallback? onPlayAgain;

  const PlayLabScoreDialog({
    super.key,
    required this.result,
    required this.onDismiss,
    this.onPlayAgain,
  });

  static Future<void> show(
    BuildContext context, {
    required PlayLabScoreResult result,
    VoidCallback? onPlayAgain,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlayLabScoreDialog(
        result: result,
        onDismiss: () => Navigator.of(ctx).pop(),
        onPlayAgain: onPlayAgain != null
            ? () {
                Navigator.of(ctx).pop();
                onPlayAgain();
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childDisplayName = result.childName != null && result.childName!.isNotEmpty
        ? result.childName!
        : 'Teman Sehat';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Stars Header Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E9),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF173D31).withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (idx) {
                  final isEarned = idx < result.starsEarned;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      isEarned ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isEarned ? const Color(0xFFF59E0B) : Colors.grey.shade400,
                      size: 38,
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // Title
            Text(
              'Hebat Sekali, $childDisplayName!',
              textAlign: TextAlign.center,
              style: AppTypography.headingScreen.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(
              result.feedbackSummary.isNotEmpty
                  ? result.feedbackSummary
                  : 'Piring makanmu berhasil tersusun dengan gizi seimbang sesuai pedoman Isi Piringku!',
              textAlign: TextAlign.center,
              style: AppTypography.bodySecondary.copyWith(
                fontSize: 12,
                color: const Color(0xFF285648),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),

            // XP Reward Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFF15803D), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+${result.xpAwarded} XP Edukasi Berhasil Diraih',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Score Breakdown Cards
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF173D31).withValues(alpha: 0.12)),
              ),
              child: Column(
                children: [
                  // Gameplay Score
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 16,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Praktik Piring Sehat:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF173D31),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${result.gameplayScore} / 100',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Knowledge Score
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Kuis Evaluasi Gizi:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF173D31),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${result.knowledgeScore} / 100',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Total Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Skor Keseluruhan:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF173D31),
                        ),
                      ),
                      Text(
                        '${result.totalScore} / 100',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF247A4D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onDismiss,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                label: const Text(
                  'Kembali ke Si-Cehat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                ),
              ),
            ),
            if (onPlayAgain != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: onPlayAgain,
                  icon: const Icon(Icons.refresh, color: Color(0xFF247A4D), size: 18),
                  label: const Text(
                    'Susun Piring Lainnya',
                    style: TextStyle(
                      color: Color(0xFF247A4D),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
