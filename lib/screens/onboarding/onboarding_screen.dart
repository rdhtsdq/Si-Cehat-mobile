import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Headline hitam besar, bold, center dengan tiga baris sesuai PDF
              Text(
                'Jaga Anak,\nCegah Diabetes\nSejak Dini',
                textAlign: TextAlign.center,
                style: AppTypography.headingScreen.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              // Catatan tujuan keselamatan
              Text(
                'Pendamping edukasi dan kebiasaan sehat keluarga.\nBukan alat diagnosis medis.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 3),
              // Tombol aksesibel Lanjut di bagian bawah
              PrimaryButton(
                text: 'Lanjut',
                onPressed: () {
                  context.read<AuthProvider>().completeOnboarding();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
