import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

enum BannerType { demo, simulation, offline, notice }

class SafetyBanner extends StatelessWidget {
  final String text;
  final BannerType type;
  final IconData? customIcon;
  final EdgeInsetsGeometry margin;

  const SafetyBanner({
    super.key,
    required this.text,
    this.type = BannerType.demo,
    this.customIcon,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textColor;
    IconData icon;

    switch (type) {
      case BannerType.simulation:
        bg = const Color(0xFFFFF8E1);
        border = const Color(0xFFFFD54F);
        textColor = const Color(0xFFF57F17);
        icon = Icons.info_outline;
        break;
      case BannerType.offline:
        bg = const Color(0xFFE8F5E9);
        border = const Color(0xFFA5D6A7);
        textColor = AppColors.primaryGreenDark;
        icon = Icons.cloud_off_outlined;
        break;
      case BannerType.notice:
        bg = const Color(0xFFF5F5F5);
        border = const Color(0xFFE0E0E0);
        textColor = AppColors.textSecondary;
        icon = Icons.help_outline;
        break;
      case BannerType.demo:
        bg = const Color(0xFFFFF3E0);
        border = const Color(0xFFFFCC80);
        textColor = const Color(0xFFE65100);
        icon = Icons.flag_outlined;
        break;
    }

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(customIcon ?? icon, size: 18, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.badgeText.copyWith(
                color: textColor,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
