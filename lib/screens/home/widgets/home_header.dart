import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/avatar_image.dart';

/// Warm, parent-facing header for Beranda.
///
/// Layout: avatar (profile shortcut) + greeting on the left, notification bell
/// on the right. The active-child chip is only shown when there is more than
/// one child so single-child families are not given a dead control.
class HomeHeader extends StatelessWidget {
  final String motherName;
  final String greeting;
  final String? avatarUrl;
  final String? activeChildName;
  final int childCount;
  final int unreadCount;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationTap;
  final VoidCallback? onChildTap;

  const HomeHeader({
    super.key,
    required this.motherName,
    required this.greeting,
    required this.avatarUrl,
    required this.activeChildName,
    required this.childCount,
    required this.unreadCount,
    required this.onAvatarTap,
    required this.onNotificationTap,
    required this.onChildTap,
  });

  bool get _showChildChip => childCount > 1 && activeChildName != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, $motherName!',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headingScreen.copyWith(
                      fontSize: 21,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    greeting,
                    style: AppTypography.bodySecondary.copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            _buildNotificationBell(),
          ],
        ),
        if (_showChildChip) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildChildChip(),
        ],
      ],
    );
  }

  Widget _buildAvatar() {
    return Semantics(
      button: true,
      label: 'Buka profil ibu',
      child: Tooltip(
        message: 'Profil ibu',
        child: Material(
          color: AppColors.veryLightGreen,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAvatarTap,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: AvatarImage(
                  avatarUrl: avatarUrl,
                  size: AppSizes.avatarHeader,
                  fallbackIcon: Icons.person,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    final label = unreadCount > 0
        ? 'Notifikasi, $unreadCount belum dibaca'
        : 'Notifikasi';

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Badge(
        isLabelVisible: unreadCount > 0,
        backgroundColor: AppColors.accentRed,
        textColor: Colors.white,
        label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
        child: IconButton(
          onPressed: onNotificationTap,
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.fieldBackground,
            foregroundColor: AppColors.textDark,
            minimumSize: const Size(
              AppSizes.minTouchTarget,
              AppSizes.minTouchTarget,
            ),
          ),
          icon: const Icon(Icons.notifications_none_rounded, size: 26),
        ),
      ),
    );
  }

  Widget _buildChildChip() {
    final chip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.veryLightGreen,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.child_care_rounded,
            size: 16,
            color: AppColors.primaryGreenDark,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Anak aktif: $activeChildName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyStrong.copyWith(
                fontSize: 12.5,
                color: AppColors.primaryGreenDark,
              ),
            ),
          ),
          if (onChildTap != null) ...[
            const SizedBox(width: 2),
            const Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: AppColors.primaryGreenDark,
            ),
          ],
        ],
      ),
    );

    final message = onChildTap == null
        ? 'Anak aktif: $activeChildName'
        : 'Anak aktif: $activeChildName. Ketuk untuk ganti anak.';

    return Semantics(
      button: onChildTap != null,
      label: message,
      excludeSemantics: true,
      child: Tooltip(
        message: message,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: onChildTap,
            child: chip,
          ),
        ),
      ),
    );
  }
}
