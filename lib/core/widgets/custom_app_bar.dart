import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../theme/app_tokens.dart';

/// Compact green app bar used by pushed detail screens.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leadingWidth: 60,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs),
              child: Center(
                child: Material(
                  color: AppColors.onPrimary.withValues(alpha: 0.16),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onBackPressed ??
                        () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.title.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
      actions: [
        if (actions != null) ...[
          ...actions!,
          const SizedBox(width: AppSpacing.xxs),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
