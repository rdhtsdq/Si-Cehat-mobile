import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/avatar_image.dart';
import '../../core/widgets/section_header.dart';
import '../../providers/app_providers.dart';
import '../auth/login_screen.dart';
import '../auth/privacy_sheet.dart';
import 'child_manage_sheet.dart';
import 'child_profile_screen.dart';
import 'mother_profile_screen.dart';

class ProfileSelectScreen extends ConsumerWidget {
  const ProfileSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mother = ref.watch(profileProvider.select((p) => p.mother));
    final motherName = mother?.name ?? 'Ibu';
    final initial = motherName.trim().isEmpty
        ? 'I'
        : motherName.trim().substring(0, 1).toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppHeader(
              title: 'Profil Saya',
              subtitle: 'Kelola data ibu dan anak dalam satu tempat',
              illustration: Container(
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.family_restroom_rounded,
                  size: 38,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                96,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MintSection(
                    radius: AppRadius.xl,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: mother?.avatarUrl != null &&
                                      mother!.avatarUrl!.trim().isNotEmpty
                                  ? ClipOval(
                                      child: AvatarImage(
                                        avatarUrl: mother.avatarUrl,
                                        size: 52,
                                        fallbackIcon: Icons.person,
                                        backgroundColor:
                                            AppColors.primarySoft,
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        initial,
                                        style: AppTypography.hero.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 11,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                motherName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.title.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (mother?.email.trim().isNotEmpty == true)
                                Text(
                                  mother!.email,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption,
                                ),
                              if (mother?.phone.trim().isNotEmpty == true)
                                Text(
                                  mother!.phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption,
                                ),
                              Text(
                                'ID: ${mother?.id ?? '-'}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RoundIconButton(
                          icon: Icons.edit_outlined,
                          tooltip: 'Ubah profil ibu',
                          onPressed: () =>
                              _push(context, const MotherProfileScreen()),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionTitle(
                    title: 'Data Saya',
                    subtitle: 'Profil ibu dan anak',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppListGroup(
                    children: [
                      AppListTile(
                        icon: Icons.person_outline_rounded,
                        iconBackground: AppColors.chipPeachBg,
                        iconForeground: AppColors.chipPeachFg,
                        title: 'Profil Ibu',
                        subtitle: 'Data pribadi & demografi orang tua',
                        onTap: () =>
                            _push(context, const MotherProfileScreen()),
                      ),
                      AppListTile(
                        icon: Icons.sentiment_satisfied_alt_rounded,
                        iconBackground: AppColors.chipTealBg,
                        iconForeground: AppColors.chipTealFg,
                        title: 'Profil Anak',
                        subtitle: 'Riwayat & pemantauan pertumbuhan anak',
                        onTap: () =>
                            _push(context, const ChildProfileScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const SectionTitle(title: 'Pengaturan'),
                  const SizedBox(height: AppSpacing.xs),
                  AppListGroup(
                    children: [
                      AppListTile(
                        icon: Icons.group_add_outlined,
                        title: 'Ganti / Tambah Anak',
                        onTap: () => _openChildManage(context),
                      ),
                      AppListTile(
                        icon: Icons.shield_outlined,
                        title: 'Informasi Privasi & Data',
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          showDragHandle: true,
                          builder: (_) => const PrivacyConsentSheet(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  DestructiveButton(
                    label: 'Keluar Akun',
                    onPressed: () => _confirmLogout(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: Text(
                      'Si Cehat v1.0.0',
                      style: AppTypography.micro,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _openChildManage(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const ChildManageSheet(),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: Text(
          'Data yang tersimpan di perangkat tetap ada dan bisa dibuka lagi '
          'setelah masuk.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerText,
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    final authProv = ref.read(authProvider);
    final profileProv = ref.read(profileProvider);
    await authProv.logout();
    profileProv.clearSession();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
