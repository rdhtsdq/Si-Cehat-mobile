import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/api/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/notification_provider.dart';
import '../consultation/consultation_screen.dart';
import '../consultation/notification_center_screen.dart';
import '../community/community_screen.dart';
import '../education/pustaka_edukasi_screen.dart';
import '../menu/menu_catalog_screen.dart';
import '../menu/meal_plan_screen.dart';
import '../nutrition/nutrition_calculator_screen.dart';
import '../profile/child_profile_setup_screen.dart';
import '../profile/mother_profile_screen.dart';
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
    final notificationProv = context.watch<NotificationProvider>();
    final motherName = (profile.mother?.name.isNotEmpty == true)
        ? profile.mother!.name
        : (auth.currentUserName ?? 'Ibu Rina');
    final activeChild = profile.activeChild;
    final unreadCount = notificationProv.unreadCount;

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
      riskTitle = 'Skrining belum tersedia';
      riskSubtitle =
          'Ketuk di sini untuk melakukan skrining risiko diabetes anak.';
      riskColor = AppColors.primaryGreen;
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar thumbnail
                  GestureDetector(
                    onTap: () => _push(context, const MotherProfileScreen()),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D6D6),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGreen, width: 2),
                      ),
                      child: ClipOval(
                        child: _buildAvatarThumbnail(profile.mother?.avatarUrl),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $motherName!',
                          style: AppTypography.headingScreen.copyWith(
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _greetingByHour(),
                          style: AppTypography.bodySecondary.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell with unread badge
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 28, color: AppColors.textDark),
                        onPressed: () => _push(context, const NotificationCenterScreen()),
                        tooltip: 'Notifikasi',
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              if (activeChild != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
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
                      const SizedBox(width: 6),
                      Text(
                        'Anak Aktif: ${activeChild.name}',
                        style: AppTypography.badgeText.copyWith(
                          color: AppColors.primaryGreenDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
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
              const SizedBox(height: 24),
              Text(
                'Menu Utama',
                style: AppTypography.titleCard.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildMenuCard(
                    'screening.png',
                    'Skrining',
                    () => _openScreeningFlow(context),
                  ),
                  const SizedBox(width: 12),
                  _buildMenuCard(
                    'menu.png',
                    'Menu',
                    () => _push(context, const MenuCatalogScreen()),
                  ),
                  const SizedBox(width: 12),
                  _buildMenuCard(
                    'reminder.png',
                    'Reminder',
                    () => _push(context, const ReminderScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMenuCard(
                    'consultation.png',
                    'Konsultasi',
                    () => _push(context, const ConsultationScreen()),
                  ),
                  const SizedBox(width: 12),
                  _buildMenuCard(
                    'activity.png',
                    'Komunitas',
                    () => _push(context, const CommunityScreen()),
                  ),
                  const SizedBox(width: 12),
                  _buildMenuCard(
                    'meal-plan.png',
                    'Rencana Menu',
                    () => _push(context, const MealPlanScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMenuCard(
                    'calculator.png',
                    'Kalkulator Nutrisi',
                    () => _push(context, const NutritionCalculatorScreen()),
                  ),
                  const SizedBox(width: 12),
                  _buildMenuCard(
                    'hello.png',
                    'Pustaka Edukasi',
                    () => _push(context, const PustakaEdukasiScreen()),
                  ),
                  const SizedBox(width: 12),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarThumbnail(String? url) {
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return Image.asset(url, fit: BoxFit.cover);
      }
      final fullUrl = url.startsWith('http') ? url : '${ApiConstants.baseUrl}$url';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Icon(
          Icons.person,
          size: 28,
          color: Color(0xFF424242),
        ),
      );
    }
    return const Icon(
      Icons.person,
      size: 28,
      color: Color(0xFF424242),
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
              constraints: const BoxConstraints(minHeight: 92),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 42,
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
