import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/reminder_provider.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../shell/main_shell_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final auth = context.read<AuthProvider>();
    await Future.wait([
      auth.ensureInitialized(),
      Future.delayed(const Duration(milliseconds: 1000)),
    ]);
    if (!mounted) return;

    if (!auth.hasSeenOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    if (!auth.isLoggedIn) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    await context.read<ProfileProvider>().loadProfiles();
    if (!mounted) return;
    await context.read<ReminderProvider>().loadReminders();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Si Cehat',
                  textAlign: TextAlign.center,
                  style: AppTypography.headingSplash,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sistem Cerdas Anak Sehat\nAnti Diabetes',
                  textAlign: TextAlign.center,
                  style: AppTypography.headingScreen.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
