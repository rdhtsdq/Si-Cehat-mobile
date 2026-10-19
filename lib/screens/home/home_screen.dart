import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../consultation/consultation_screen.dart';
import '../menu/menu_catalog_screen.dart';
import '../menu/meal_plan_screen.dart';
import '../nutrition/nutrition_calculator_screen.dart';
import '../profile/child_profile_setup_screen.dart';
import '../reminder/reminder_screen.dart';
import '../screening/screening_step1_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  String _greetingByHour() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final motherName = (profile.mother?.name.isNotEmpty == true)
        ? profile.mother!.name
        : (auth.currentUserName ?? 'Ibu');
    final activeChild = profile.activeChild;

    final riskCat = activeChild?.latestRiskCategory?.toUpperCase();
    final String riskTitle;
    final String riskSubtitle;
    final Color riskColor;

    if (riskCat == 'TINGGI') {
      riskTitle = 'Risiko Tinggi';
      riskSubtitle =
          'Disarankan konsultasi gizi dan batasi konsumsi gula harian.';
      riskColor = Colors.orange[800]!;
    } else if (riskCat == 'SEDANG') {
      riskTitle = 'Risiko Sedang';
      riskSubtitle =
          'Perhatikan porsi makan seimbang dan aktivitas fisik harian anak.';
      riskColor = const Color(0xFFE6A23C);
    } else if (riskCat == 'RENDAH') {
      riskTitle = 'Risiko Rendah';
      riskSubtitle = 'Pertahankan pola hidup sehat anak setiap hari!';
      riskColor = AppColors.primaryGreen;
    } else {
      riskTitle = 'Belum Skrining';
      riskSubtitle =
          'Ketuk di sini untuk melakukan skrining risiko diabetes anak.';
      riskColor = AppColors.primaryGreenDark;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $motherName!',
                          style: AppTypography.headingScreen.copyWith(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _greetingByHour(),
                          style: AppTypography.bodySecondary.copyWith(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/dashboard/hello.png',
                        width: 72,
                        height: 72,
                        fit: BoxFit.contain,
                      ),
                      if (activeChild != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.veryLightGreen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.child_care,
                                size: 16,
                                color: AppColors.primaryGreenDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                activeChild.name,
                                style: AppTypography.badgeText.copyWith(
                                  color: AppColors.primaryGreenDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _openScreeningFlow(context),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.paleGreenBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diabetes Risk Meter',
                          style: AppTypography.titleCard.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          riskTitle,
                          style: AppTypography.headingScreen.copyWith(
                            fontSize: 24,
                            color: riskColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          riskSubtitle,
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.textDark,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Menu Utama',
                style: AppTypography.titleCard.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildMenuCard(
                    'screening.png',
                    'Skrining',
                    () => _openScreeningFlow(context),
                  ),
                  const SizedBox(width: 14),
                  _buildMenuCard(
                    'menu.png',
                    'Menu',
                    () => _push(context, const MenuCatalogScreen()),
                  ),
                  const SizedBox(width: 14),
                  _buildMenuCard(
                    'reminder.png',
                    'Pengingat',
                    () => _push(context, const ReminderScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildMenuCard(
                    'consultation.png',
                    'Konsultasi',
                    () => _push(context, const ConsultationScreen()),
                  ),
                  const SizedBox(width: 14),
                  _buildMenuCard(
                    'meal-plan.png',
                    'Rencana Menu',
                    () => _push(context, const MealPlanScreen()),
                  ),
                  const SizedBox(width: 14),
                  _buildMenuCard(
                    'calculator.png',
                    'Kalkulator Nutrisi',
                    () => _push(context, const NutritionCalculatorScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(String asset, String label, VoidCallback onTap) =>
      Expanded(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 1,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(minHeight: 90),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 44,
                    child: Image.asset(
                      'assets/dashboard/$asset',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: AppTypography.titleCard.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _openScreeningFlow(BuildContext context) {
    final profile = context.read<ProfileProvider>();
    final activeChild = profile.activeChild;

    // Before screening, ensure child profile is fulfilled
    if (activeChild == null || !activeChild.isProfileComplete) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChildProfileSetupScreen(
            initialChild: activeChild,
            onCompleted: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const ScreeningStep1Screen(),
                ),
              );
            },
          ),
        ),
      );
    } else {
      _push(context, const ScreeningStep1Screen());
    }
  }

  void _push(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}
