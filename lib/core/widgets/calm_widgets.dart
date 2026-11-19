import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../theme/app_tokens.dart';

/// ---------------------------------------------------------------------------
/// AppHeader — tab-root and compact green header.
/// ---------------------------------------------------------------------------
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? topCaption;
  final bool compact;
  final VoidCallback? onBack;
  final Widget? leading;
  final List<Widget> actions;
  final Widget? illustration;
  final Widget? bottomChild;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.topCaption,
    this.compact = false,
    this.onBack,
    this.leading,
    this.actions = const [],
    this.illustration,
    this.bottomChild,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final extraHeight =
        (textScale - 1).clamp(0.0, 0.6) * (compact ? 32.0 : 72.0);
    final headerHeight = topInset + (compact ? 64.0 : 104.0) + extraHeight;

    final header = Container(
      width: double.infinity,
      height: headerHeight,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        topInset + (compact ? AppSpacing.xs : 14),
        AppSpacing.md,
        compact ? AppSpacing.xs : AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.header,
      ),
      child: compact ? _buildCompact(context) : _buildTab(context),
    );

    if (bottomChild == null) return header;

    // Let the child summary card tuck under the header slightly without
    // covering the greeting text (keeps ~8px clearance above the card).
    return Stack(
      clipBehavior: Clip.none,
      children: [
        header,
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.md,
            headerHeight - 8,
            AppSpacing.md,
            0,
          ),
          child: bottomChild,
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (leading != null) ...[
          Padding(padding: const EdgeInsets.only(bottom: 4), child: leading!),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (topCaption != null) ...[
                Text(
                  topCaption!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.headerSubtitle,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.display.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 22,
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.headerSubtitle,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (illustration != null) ...[
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 76, height: 76, child: illustration),
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.xs),
          Row(mainAxisSize: MainAxisSize.min, children: actions),
        ],
      ],
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          HeaderIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Kembali',
            onPressed: onBack,
          ),
        if (onBack != null) const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title.copyWith(
                color: AppColors.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        ...actions,
      ],
    );
  }
}

/// Circular translucent button used inside the green header.
class HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final int badgeCount;

  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: AppSizes.minTouchTarget,
      height: AppSizes.minTouchTarget,
      child: Center(
        child: Material(
          color: AppColors.onPrimary.withValues(alpha: 0.16),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(icon, size: 20, color: AppColors.onPrimary),
            ),
          ),
        ),
      ),
    );

    final label = badgeCount > 0
        ? '$tooltip, $badgeCount belum dibaca'
        : tooltip;

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            button,
            if (badgeCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.dangerText,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: AppTypography.micro.copyWith(
                        color: AppColors.onPrimary,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// AppBottomNav — white bar, active item becomes a solid primary pill.
/// ---------------------------------------------------------------------------
class AppNavItem {
  final IconData icon;
  final String label;

  const AppNavItem({required this.icon, required this.label});
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTapped;
  final List<AppNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTapped,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: SizedBox(
            height: AppSizes.navBarHeight,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavItem(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTapped(i),
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

class _NavItem extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.onPrimary : AppColors.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.button,
        child: InkWell(
          borderRadius: AppRadius.button,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 14 : 8,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.button,
                ),
                child: selected
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 18, color: color),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.micro.copyWith(
                                color: color,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, size: 22, color: color),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.micro.copyWith(color: color),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Surfaces
/// ---------------------------------------------------------------------------
class MintSection extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const MintSection({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.radius = AppRadius.xl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color? borderColor;
  final bool showShadow;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.sm),
    this.onTap,
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.showShadow = false,
    this.radius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1),
        boxShadow: showShadow ? AppShadows.float : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: content),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Small pieces
/// ---------------------------------------------------------------------------
class IconChip extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;
  final bool circle;

  const IconChip({
    super.key,
    required this.icon,
    this.background = AppColors.primarySoft,
    this.foreground = AppColors.primary,
    this.size = 36,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, size: size * 0.52, color: foreground),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final IconData? icon;
  final bool dense;

  const StatusBadge({
    super.key,
    required this.label,
    this.background = AppColors.surface,
    this.foreground = AppColors.textMuted,
    this.borderColor = AppColors.border,
    this.icon,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 10,
        vertical: dense ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.button,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.micro.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum RiskLevel { low, medium, high, unknown }

class RiskPalette {
  const RiskPalette._();

  static ({Color background, Color foreground, Color border}) of(
    RiskLevel level,
  ) {
    return switch (level) {
      RiskLevel.low => (
        background: AppColors.riskLowBg,
        foreground: AppColors.riskLowFg,
        border: AppColors.riskLowBorder,
      ),
      RiskLevel.medium => (
        background: AppColors.riskMediumBg,
        foreground: AppColors.riskMediumFg,
        border: AppColors.riskMediumBorder,
      ),
      RiskLevel.high => (
        background: AppColors.riskHighBg,
        foreground: AppColors.riskHighFg,
        border: AppColors.riskHighBorder,
      ),
      RiskLevel.unknown => (
        background: AppColors.chipNeutralBg,
        foreground: AppColors.textMuted,
        border: AppColors.border,
      ),
    };
  }

  static IconData iconOf(RiskLevel level) {
    return switch (level) {
      RiskLevel.low => Icons.check_circle_outline_rounded,
      RiskLevel.medium => Icons.error_outline_rounded,
      RiskLevel.high => Icons.warning_amber_rounded,
      RiskLevel.unknown => Icons.help_outline_rounded,
    };
  }
}

class RiskBadge extends StatelessWidget {
  final String label;
  final RiskLevel level;
  final bool showIcon;

  const RiskBadge({
    super.key,
    required this.label,
    required this.level,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = RiskPalette.of(level);
    return StatusBadge(
      label: label,
      background: palette.background,
      foreground: palette.foreground,
      borderColor: palette.border,
      icon: showIcon ? RiskPalette.iconOf(level) : null,
    );
  }
}

class ChoiceChipGroup extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const ChoiceChipGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = options.length <= 3 ? options.length : 2;
        final width =
            (constraints.maxWidth - AppSpacing.xs * (columns - 1)) / columns;

        return Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final option in options)
              SizedBox(
                width: width,
                child: _ChoiceChip(
                  label: option,
                  isSelected: option == selected,
                  onTap: () => onSelected(option),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.button,
        child: InkWell(
          borderRadius: AppRadius.button,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySoft2 : AppColors.surface,
              borderRadius: AppRadius.button,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  height: 1.25,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SegmentedPills extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const SegmentedPills({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: _Segment(
              label: labels[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          ),
        ],
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.button,
        child: InkWell(
          borderRadius: AppRadius.button,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.primarySoft,
              borderRadius: AppRadius.button,
            ),
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: selected ? AppColors.onPrimary : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Buttons
/// ---------------------------------------------------------------------------
enum AppPillVariant { primary, ghost, soft, danger }

class AppPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppPillVariant variant;
  final double height;
  final bool expanded;

  /// Replaces the leading icon with a spinner so an in-flight action is
  /// visually obvious even though the button is disabled.
  final bool isLoading;

  const AppPillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppPillVariant.primary,
    this.height = AppSizes.buttonHeight,
    this.expanded = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (variant) {
      AppPillVariant.primary => (AppColors.primary, AppColors.onPrimary, null),
      AppPillVariant.ghost => (
        AppColors.surface,
        AppColors.primary,
        AppColors.border,
      ),
      AppPillVariant.soft => (AppColors.primarySoft, AppColors.primary, null),
      AppPillVariant.danger => (AppColors.dangerBg, AppColors.dangerText, null),
    };

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: height <= 34 ? 14 : 18,
            height: height <= 34 ? 14 : 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
          ),
          const SizedBox(width: 6),
        ] else if (icon != null) ...[
          Icon(icon, size: height <= 34 ? 14 : 18, color: foreground),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.buttonLabel.copyWith(
              color: foreground,
              fontSize: height <= 34 ? 11 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      child: SizedBox(
        width: expanded ? double.infinity : null,
        height: height,
        child: Material(
          color: background,
          borderRadius: AppRadius.button,
          child: InkWell(
            borderRadius: AppRadius.button,
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: AppRadius.button,
                border: border == null
                    ? null
                    : Border.all(color: border, width: 1),
              ),
              // `widthFactor` keeps a non-expanded pill shrink-wrapped even
              // when the parent hands down a bounded max width (e.g. a
              // ListTile trailing slot), otherwise it would fill the tile.
              child: Center(widthFactor: expanded ? null : 1, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool expanded;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.height = 32,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppPillButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      variant: AppPillVariant.ghost,
      height: height,
      expanded: expanded,
    );
  }
}

class DestructiveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const DestructiveButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon = Icons.logout_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return AppPillButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      variant: AppPillVariant.danger,
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: AppSizes.minTouchTarget,
          height: AppSizes.minTouchTarget,
          child: Center(
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Icon(icon, size: size * 0.5, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Lists
/// ---------------------------------------------------------------------------
class AppListGroup extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const AppListGroup({
    super.key,
    required this.children,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 60,
                endIndent: AppSpacing.sm,
              ),
          ],
        ],
      ),
    );
  }
}

class AppListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color iconBackground;
  final Color iconForeground;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconBackground = AppColors.primarySoft,
    this.iconForeground = AppColors.primary,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: subtitle == null ? title : '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 10,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  IconChip(
                    icon: icon!,
                    size: 36,
                    background: iconBackground,
                    foreground: iconForeground,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                trailing ??
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

/// ---------------------------------------------------------------------------
/// Progress & empty states
/// ---------------------------------------------------------------------------
class StepProgress extends StatelessWidget {
  final int current;
  final int total;
  final String? caption;

  const StepProgress({
    super.key,
    required this.current,
    required this.total,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption ?? 'Langkah $current dari $total',
          style: AppTypography.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            for (var i = 0; i < total; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < current
                        ? AppColors.primary
                        : AppColors.primarySoft,
                    borderRadius: AppRadius.button,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconChip(
              icon: icon,
              size: 56,
              circle: true,
              background: AppColors.primarySoft,
              foreground: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(title, textAlign: TextAlign.center, style: AppTypography.h2),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppPillButton(
                label: actionLabel!,
                onPressed: onAction,
                expanded: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
