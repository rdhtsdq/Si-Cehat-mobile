import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/safety_banner.dart';
import '../../providers/profile_provider.dart';
import '../screening/screening_step1_screen.dart';
import '../menu/menu_catalog_screen.dart';
import '../reminder/reminder_screen.dart';
import '../consultation/consultation_screen.dart';
import '../community/community_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showFixtureRisk = false;

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi';
    if (hour >= 11 && hour < 15) return 'Selamat Siang';
    if (hour >= 15 && hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final motherName = profileProv.mother?.name ?? 'Ibu Rina';
    final activeChild = profileProv.activeChild;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sapaan "Halo, Ibu Rina!" besar rata kiri & "Selamat Pagi"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, $motherName!',
                          style: AppTypography.headingScreen.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getTimeGreeting(),
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (activeChild != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.veryLightGreen,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.child_care, size: 16, color: AppColors.primaryGreenDark),
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
              const SizedBox(height: 20),

              // CARD ATAS: Diabetes Risk Meter (Latar bidang hijau pucat)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.paleGreenBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Diabetes Risk Meter',
                          style: AppTypography.titleCard.copyWith(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // Tombol simulasi switch untuk reviewer
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showFixtureRisk = !_showFixtureRisk;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Text(
                              _showFixtureRisk ? 'Reset' : 'Simulasi',
                              style: AppTypography.badgeText.copyWith(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (!_showFixtureRisk) ...[
                      // SAFETY DEFAULT: Skrining belum tersedia (karena belum ada data)
                      Text(
                        'Skrining belum tersedia',
                        style: AppTypography.headingScreen.copyWith(
                          fontSize: 22,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mulai skrining awal untuk memantau kebiasaan sehat dan faktor risiko anak.',
                        style: AppTypography.bodySecondary.copyWith(
                          color: AppColors.textDark,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ScreeningStep1Screen()),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'Mulai Skrining Sekarang',
                              style: AppTypography.buttonText.copyWith(
                                color: AppColors.primaryGreenDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppColors.primaryGreenDark,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // FIXTURE VISUAL S1: "Risiko Rendah" dengan badge transparan
                      Row(
                        children: [
                          Text(
                            'Risiko Rendah',
                            style: AppTypography.headingScreen.copyWith(
                              fontSize: 24,
                              color: AppColors.primaryGreenDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentYellow.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Contoh tampilan',
                              style: AppTypography.badgeText.copyWith(
                                fontSize: 9,
                                color: const Color(0xFFB78103),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pertahankan pola hidup sehat anak setiap hari!',
                        style: AppTypography.bodySecondary.copyWith(
                          color: AppColors.textDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // PANEL MENU UTAMA
              Text(
                'Menu Utama',
                style: AppTypography.titleCard.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // GRID MENU SESUAI PDF S05:
              // Baris pertama (3 kolom): Skrining, Menu, Reminder
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      icon: Icons.assignment_outlined,
                      label: 'Skrining',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ScreeningStep1Screen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMenuCard(
                      icon: Icons.restaurant_menu_outlined,
                      label: 'Menu',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const MenuCatalogScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMenuCard(
                      icon: Icons.notifications_none_outlined,
                      label: 'Reminder',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ReminderScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Baris kedua (2 kolom rata kiri dari 3 slot kolom): Konsultasi, Komunitas
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      icon: Icons.chat_bubble_outline_outlined,
                      label: 'Konsultasi',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ConsultationScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildMenuCard(
                      icon: Icons.people_outline,
                      label: 'Komunitas',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CommunityScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Slot kosong kolom ketiga agar rata kiri seimbang
                  const Expanded(child: SizedBox()),
                ],
              ),

              const SizedBox(height: 24),
              const SafetyBanner(
                text: 'DEMO · Data contoh tersimpan secara lokal pada perangkat Anda.',
                type: BannerType.demo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 90),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: AppColors.textDark),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.titleCard.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
