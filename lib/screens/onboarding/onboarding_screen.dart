import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../providers/app_providers.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageGutter,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.veryLightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 42,
                  color: AppColors.primaryGreenDark,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Jaga Anak,\nCegah Diabetes\nSejak Dini',
                textAlign: TextAlign.center,
                style: AppTypography.headingScreen.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.28,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Pendamping edukasi dan kebiasaan sehat keluarga. '
                'Bukan alat diagnosis medis.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(fontSize: 15),
              ),
              const Spacer(flex: 3),
              FilledButton(
                onPressed: () {
                  ref.read(authProvider).completeOnboarding();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text('Lanjut'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Untuk orang tua & pendamping anak usia 6–12 tahun',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
