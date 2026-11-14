import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/calm_widgets.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/activity_log_model.dart';
import '../../providers/app_providers.dart';
import 'add_activity_sheet.dart';

class HabitLogView extends ConsumerStatefulWidget {
  const HabitLogView({super.key});

  @override
  ConsumerState<HabitLogView> createState() => _HabitLogViewState();
}

class _HabitLogViewState extends ConsumerState<HabitLogView> {
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final child = ref.read(profileProvider).activeChild;
    if (child != null) {
      ref.read(trackerProvider).loadActivities(child.id, date: _currentDate);
    }
  }

  void _changeDate(int offsetDays) {
    setState(() {
      _currentDate = _currentDate.add(Duration(days: offsetDays));
    });
    _loadData();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _currentDate) {
      setState(() => _currentDate = picked);
      _loadData();
    }
  }

  String _formatDateLabel(DateTime dt) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;

    final dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    if (isToday) return 'Hari Ini ($dateStr)';
    if (isYesterday) return 'Kemarin ($dateStr)';
    return dateStr;
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Hidrasi Sehat':
        return Icons.water_drop_outlined;
      case 'Gizi Seimbang':
        return Icons.restaurant_outlined;
      case 'Istirahat':
        return Icons.bedtime_outlined;
      default:
        return Icons.directions_run_rounded;
    }
  }

  ({Color background, Color foreground}) _colorsForCategory(String category) {
    switch (category) {
      case 'Hidrasi Sehat':
        return (
          background: AppColors.chipTealBg,
          foreground: AppColors.chipTealFg,
        );
      case 'Gizi Seimbang':
        return (
          background: AppColors.chipPeachBg,
          foreground: AppColors.chipPeachFg,
        );
      case 'Istirahat':
        return (
          background: AppColors.primarySoft,
          foreground: AppColors.primary,
        );
      default:
        return (
          background: AppColors.chipNeutralBg,
          foreground: AppColors.textMuted,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(profileProvider.select((p) => p.activeChild?.id), (prev, next) {
      if (next != null && next != prev) {
        _loadData();
      }
    });

    final trackerProv = ref.watch(trackerProvider);
    final profileProv = ref.watch(profileProvider);
    final child = profileProv.activeChild;

    final activities = trackerProv.activities;
    final totalMins = trackerProv.totalActiveMinutes;
    final percentage = trackerProv.activityPercentage;
    final waterGlasses = trackerProv.waterGlasses;
    final status = trackerProv.activityStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateNavigator(),
        const SizedBox(height: AppSpacing.sm),
        _buildTargetSummaryCard(totalMins, percentage, status),
        if (child != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _buildWaterTrackerCard(child.id, waterGlasses, trackerProv),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Tercatat (${activities.length})',
              style: AppTypography.h2,
            ),
            if (activities.isNotEmpty)
              Text(
                'Total $totalMins mnt aktif',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (trackerProv.isLoadingActivities)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (activities.isEmpty)
          AppCard(
            child: EmptyState(
              icon: Icons.directions_bike_outlined,
              title: 'Belum Ada Aktivitas',
              message:
                  'Ajak anak bermain aktif atau olahraga, lalu catat di sini.',
            ),
          )
        else
          ...activities.map(
            (act) => _buildActivityTile(act, trackerProv, child?.id),
          ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          text: 'Catat Aktivitas Baru',
          icon: const Icon(Icons.add_rounded),
          isOutlined: true,
          onPressed: child != null
              ? () => AddActivitySheet.show(
                    context,
                    childId: child.id,
                    date: _currentDate,
                  )
              : null,
        ),
      ],
    );
  }

  Widget _buildDateNavigator() {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Hari sebelumnya',
            size: 32,
            onPressed: () => _changeDate(-1),
          ),
          Expanded(
            child: InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _formatDateLabel(_currentDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          RoundIconButton(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Hari berikutnya',
            size: 32,
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSummaryCard(
    int totalMins,
    double percentage,
    String status,
  ) {
    final isTargetReached = totalMins >= 60;
    return AppCard(
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconChip(
                icon: isTargetReached
                    ? Icons.emoji_events_outlined
                    : Icons.directions_run_rounded,
                size: 36,
                background: isTargetReached
                    ? AppColors.warningBg
                    : AppColors.primarySoft,
                foreground: isTargetReached
                    ? AppColors.chipPeachFg
                    : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Target Aktivitas Fisik',
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusBadge(
                label: status,
                background: isTargetReached
                    ? AppColors.warningBg
                    : AppColors.primarySoft,
                foreground: isTargetReached
                    ? AppColors.chipPeachFg
                    : AppColors.primary,
                borderColor: null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalMins',
                style: AppTypography.display.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ 60 menit',
                style: AppTypography.body.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadius.button,
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: AppColors.primarySoft,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isTargetReached
                ? 'Luar biasa! Target 60 menit bermain aktif hari ini sudah tercapai.'
                : 'Anjuran Kemenkes: minimal 60 menit aktivitas fisik setiap hari untuk cegah obesitas.',
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTrackerCard(
    dynamic childId,
    int glasses,
    TrackerProvider prov,
  ) {
    return AppCard(
      child: Row(
        children: [
          const IconChip(
            icon: Icons.water_drop_outlined,
            size: 40,
            background: AppColors.chipTealBg,
            foreground: AppColors.chipTealFg,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Konsumsi Air Putih',
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$glasses dari 8 gelas (~${glasses * 250} ml)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.chipTealFg,
                  ),
                ),
              ],
            ),
          ),
          RoundIconButton(
            icon: Icons.remove_rounded,
            tooltip: 'Kurangi 1 gelas',
            size: 32,
            onPressed: () => prov.decrementWater(childId, date: _currentDate),
          ),
          const SizedBox(width: 2),
          RoundIconButton(
            icon: Icons.add_rounded,
            tooltip: 'Tambah 1 gelas',
            size: 32,
            onPressed: () => prov.incrementWater(childId, date: _currentDate),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(
    ActivityLogModel act,
    TrackerProvider prov,
    dynamic childId,
  ) {
    final colors = _colorsForCategory(act.category);
    final catIcon = _iconForCategory(act.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AppCard(
        child: Row(
          children: [
            IconChip(
              icon: catIcon,
              size: 40,
              background: colors.background,
              foreground: colors.foreground,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    act.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (act.durationMinutes > 0)
                        Text(
                          '${act.durationMinutes} menit',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        act.category,
                        style: AppTypography.caption.copyWith(
                          color: colors.foreground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (act.intensity.isNotEmpty &&
                          act.category == 'Aktivitas Fisik')
                        StatusBadge(
                          label: act.intensity,
                          background: AppColors.chipNeutralBg,
                          foreground: AppColors.textMuted,
                          borderColor: null,
                        ),
                    ],
                  ),
                  if (act.notes.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      act.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: AppColors.dangerText,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.dangerBg,
                minimumSize: const Size(36, 36),
                fixedSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
              tooltip: 'Hapus aktivitas',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Aktivitas?'),
                    content: Text(
                      'Apakah Anda yakin ingin menghapus catatan "${act.title}"?',
                      style: AppTypography.body,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.dangerText,
                        ),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && act.id != null) {
                  await prov.deleteActivity(act.id, childId: childId);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
