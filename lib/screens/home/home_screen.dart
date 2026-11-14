import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/avatar_image.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/app_providers.dart';
import '../consultation/consultation_screen.dart';
import '../consultation/notification_center_screen.dart';
import '../community/community_screen.dart';
import '../menu/menu_catalog_screen.dart';
import '../menu/meal_plan_screen.dart';
import '../nutrition/nutrition_calculator_screen.dart';
import '../nutrition/photo_analysis_flow.dart';
import '../profile/child_manage_sheet.dart';
import '../profile/child_profile_setup_screen.dart';
import '../profile/mother_profile_screen.dart';
import '../reminder/reminder_screen.dart';
import '../screening/screening_step1_screen.dart';
import 'widgets/home_menu_tile.dart';
import 'widgets/nutrition_daily_card.dart';
import 'widgets/risk_meter_card.dart';

class HomeScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final authName = ref.watch(authProvider.select((a) => a.currentUserName));
    final unreadCount = ref.watch(
      notificationProvider.select((p) => p.unreadCount),
    );

    final motherName = (profile.mother?.name.trim().isNotEmpty == true)
        ? profile.mother!.name
        : (authName ?? 'Ibu Rina');
    final activeChild = profile.activeChild;
    final tracker = ref.watch(trackerProvider);
    final latestMeasurement =
        activeChild != null &&
            tracker.latestMeasurement?.childId.toString() ==
                activeChild.id.toString()
        ? tracker.latestMeasurement
        : null;

    final risk = _resolveRisk(activeChild?.latestRiskCategory);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              topCaption: _greetingByHour(),
              title: 'Halo, $motherName!',
              leading: _HeaderAvatar(
                avatarUrl: profile.mother?.avatarUrl,
                onTap: () => _push(context, const MotherProfileScreen()),
              ),
              actions: [
                HeaderIconButton(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Notifikasi',
                  badgeCount: unreadCount,
                  onPressed: () =>
                      _push(context, const NotificationCenterScreen()),
                ),
              ],
              bottomChild: activeChild == null
                  ? null
                  : _ChildSummaryCard(
                      name: activeChild.name,
                      age: _formatAge(activeChild.dateOfBirth),
                      gender: activeChild.gender,
                      weight: latestMeasurement?.formattedWeight,
                      height: latestMeasurement?.formattedHeight,
                      onTap: () => _openChildSwitcher(context),
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageGutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RiskMeterCard(
                    title: risk.title,
                    subtitle: risk.subtitle,
                    tone: risk.tone,
                    onTap: () => _openScreeningFlow(context, ref),
                  ),
                  if (activeChild != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    NutritionDailyCard(
                      childId: activeChild.id?.toString(),
                      onPhoto: () => runPhotoAnalysis(
                        context,
                        ref,
                        childId: activeChild.id?.toString(),
                      ),
                      onDetail: () =>
                          _push(context, const NutritionCalculatorScreen()),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const SectionHeader(
                    title: 'Menu Utama',
                    subtitle: 'Yang paling sering dipakai setiap hari',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildMenuGrid(context, ref),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(
                    title: 'Fitur lainnya',
                    subtitle: 'Bantu susun pola makan sehat keluarga',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppListGroup(
                    children: [
                      AppListTile(
                        icon: Icons.menu_book_outlined,
                        iconBackground: AppColors.primarySoft,
                        iconForeground: AppColors.primary,
                        title: 'Rencana Menu',
                        subtitle: 'Susun menu sehat seminggu',
                        onTap: () => _push(context, const MealPlanScreen()),
                      ),
                      AppListTile(
                        icon: Icons.calculate_outlined,
                        iconBackground: AppColors.chipPeachBg,
                        iconForeground: AppColors.chipPeachFg,
                        title: 'Kalkulator Nutrisi',
                        subtitle: 'Hitung kebutuhan gizi harian anak',
                        onTap: () =>
                            _push(context, const NutritionCalculatorScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAge(String dateOfBirth) {
    final dob = DateTime.tryParse(dateOfBirth);
    if (dob == null) return '';
    final now = DateTime.now();
    var months = (now.year - dob.year) * 12 + now.month - dob.month;
    if (now.day < dob.day) months -= 1;
    if (months < 0) months = 0;
    if (months < 12) return '$months bulan';
    final years = months ~/ 12;
    final rest = months % 12;
    return rest == 0 ? '$years tahun' : '$years tahun $rest bulan';
  }

  ({RiskTone tone, String title, String subtitle}) _resolveRisk(
    String? category,
  ) {
    switch (category?.toUpperCase()) {
      case 'TINGGI':
        return (
          tone: RiskTone.high,
          title: 'Risiko Tinggi',
          subtitle:
              'Disarankan berkonsultasi dengan tenaga kesehatan dan batasi konsumsi gula harian.',
        );
      case 'SEDANG':
        return (
          tone: RiskTone.medium,
          title: 'Risiko Sedang',
          subtitle:
              'Yuk perbaiki pola makan dan aktivitas si Kecil. Lakukan skrining ulang bulan depan.',
        );
      case 'RENDAH':
        return (
          tone: RiskTone.low,
          title: 'Risiko Rendah',
          subtitle: 'Pertahankan pola hidup sehat si Kecil setiap hari.',
        );
      default:
        return (
          tone: RiskTone.unknown,
          title: 'Skrining belum tersedia',
          subtitle:
              'Ketuk di sini untuk melakukan skrining risiko diabetes anak.',
        );
    }
  }

  Widget _buildMenuGrid(BuildContext context, WidgetRef ref) {
    final textScale = MediaQuery.textScalerOf(context).scale(12);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth < 320 || textScale > 16;
        final columns = useTwoColumns ? 2 : 3;
        final tileWidth =
            (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;

        final tiles = <Widget>[
          HomeMenuTile(
            icon: Icons.assignment_outlined,
            label: 'Skrining',
            tint: AppColors.primarySoft,
            iconColor: AppColors.primary,
            onTap: () => _openScreeningFlow(context, ref),
          ),
          HomeMenuTile(
            icon: Icons.restaurant_outlined,
            label: 'Menu',
            tint: AppColors.chipPeachBg,
            iconColor: AppColors.chipPeachFg,
            onTap: () => _push(context, const MenuCatalogScreen()),
          ),
          HomeMenuTile(
            icon: Icons.notifications_none_rounded,
            label: 'Reminder',
            tint: AppColors.chipTealBg,
            iconColor: AppColors.chipTealFg,
            onTap: () => _push(context, const ReminderScreen()),
          ),
          HomeMenuTile(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Konsultasi',
            tint: AppColors.chipRoseBg,
            iconColor: AppColors.chipRoseFg,
            onTap: () => _push(context, const ConsultationScreen()),
          ),
          HomeMenuTile(
            icon: Icons.groups_outlined,
            label: 'Komunitas',
            tint: AppColors.primarySoft,
            iconColor: AppColors.primary,
            onTap: () => _push(context, const CommunityScreen()),
          ),
        ];

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final tile in tiles) SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }

  void _openChildSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ChildManageSheet(),
    );
  }

  void _openScreeningFlow(BuildContext context, WidgetRef ref) {
    final profile = ref.read(profileProvider);
    final activeChild = profile.activeChild;

    if (activeChild == null || !activeChild.isProfileComplete) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChildProfileSetupScreen(
            initialChild: activeChild,
            onCompleted: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const ScreeningStep1Screen()),
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

class _HeaderAvatar extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onTap;

  const _HeaderAvatar({required this.avatarUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buka profil ibu',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: AppSizes.avatarHeader,
            height: AppSizes.avatarHeader,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.onPrimary.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: AvatarImage(
                avatarUrl: avatarUrl,
                size: 40,
                fallbackIcon: Icons.person,
                backgroundColor: AppColors.primarySoft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildSummaryCard extends StatelessWidget {
  final String name;
  final String age;
  final String gender;
  final String? weight;
  final String? height;
  final VoidCallback onTap;

  const _ChildSummaryCard({
    required this.name,
    required this.age,
    required this.gender,
    required this.onTap,
    this.weight,
    this.height,
  });

  String get _meta {
    final parts = [
      if (age.isNotEmpty) age,
      ?weight,
      ?height,
      if (age.isEmpty && weight == null && height == null) gender,
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Profil anak $name. $_meta. Ketuk untuk ganti anak.',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const IconChip(
                  icon: Icons.sentiment_satisfied_alt_rounded,
                  size: 44,
                  background: AppColors.primarySoft,
                  foreground: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_meta.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _meta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption,
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.chevron,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
