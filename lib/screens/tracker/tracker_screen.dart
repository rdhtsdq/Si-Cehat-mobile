import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/measurement_model.dart';
import '../../providers/app_providers.dart';
import 'add_measurement_sheet.dart';
import 'habit_log_screen.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  final bool showBackButton;

  const TrackerScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  int _selectedTab = 0; // 0: Tumbuh Kembang, 1: Aktivitas

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
      final prov = ref.read(trackerProvider);
      prov.loadMeasurements(child.id);
      prov.loadActivities(child.id);
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
    final measurements = trackerProv.measurements;
    final latest = trackerProv.latestMeasurement;

    final lastWeight = latest != null ? latest.formattedWeight : '- kg';
    final lastHeight = latest != null ? latest.formattedHeight : '- cm';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showBackButton)
              AppHeader(
                compact: true,
                title: 'Tracker',
                onBack: () => Navigator.of(context).maybePop(),
              )
            else
              const AppHeader(
                title: 'Tracker',
                subtitle: 'Pantau tumbuh kembang anak',
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                96,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedPills(
                    labels: const ['Tumbuh Kembang', 'Aktivitas'],
                    selectedIndex: _selectedTab,
                    onSelected: (index) =>
                        setState(() => _selectedTab = index),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (_selectedTab == 0)
                    _buildGrowthSection(measurements, lastWeight, lastHeight)
                  else
                    const HabitLogView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthSection(
    List<MeasurementModel> measurements,
    String lastWeight,
    String lastHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Grafik BB (Kg)',
          subtitle: measurements.isEmpty
              ? 'Belum ada pengukuran'
              : '${measurements.length} pengukuran tercatat',
        ),
        const SizedBox(height: AppSpacing.sm),
        MintSection(
          child: AppCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: measurements.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const IconChip(
                                icon: Icons.insights_rounded,
                                size: 40,
                                circle: true,
                                background: AppColors.primarySoft,
                                foreground: AppColors.primary,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Belum ada data berat.\n'
                                'Tambah pengukuran untuk melihat grafik.',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : CustomPaint(
                          painter: _GrowthChartPainter(
                            measurements: measurements,
                          ),
                        ),
                ),
                if (measurements.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: measurements
                          .skip(
                            measurements.length > 5
                                ? measurements.length - 5
                                : 0,
                          )
                          .map(
                            (m) => Text(
                              m.date.length >= 10
                                  ? m.date.substring(5, 10)
                                  : m.date,
                              style: AppTypography.micro.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _LatestStat(
                icon: Icons.monitor_weight_outlined,
                label: 'Berat Badan Terakhir',
                value: lastWeight,
                iconBackground: AppColors.primarySoft,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _LatestStat(
                icon: Icons.height_rounded,
                label: 'Tinggi Badan Terakhir',
                value: lastHeight,
                iconBackground: AppColors.chipPeachBg,
                iconColor: AppColors.chipPeachFg,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          text: 'Tambah Pengukuran',
          icon: const Icon(Icons.add_rounded),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => const AddMeasurementSheet(),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionHeader(
          title: 'Riwayat Pengukuran',
          subtitle: '${measurements.length} catatan',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (measurements.isEmpty)
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text(
                'Belum ada data pengukuran.',
                style: AppTypography.caption,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: measurements.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final m = measurements[measurements.length - 1 - index];
              return _buildMeasurementHistoryTile(context, m);
            },
          ),
      ],
    );
  }

  Widget _buildMeasurementHistoryTile(
    BuildContext context,
    MeasurementModel m,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          const IconChip(
            icon: Icons.calendar_today_rounded,
            size: 40,
            background: AppColors.primarySoft,
            foreground: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        m.date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (m.source.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      StatusBadge(
                        label: m.source,
                        background: AppColors.primarySoft,
                        foreground: AppColors.primary,
                        borderColor: null,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'BB: ${m.formattedWeight} · TB: ${m.formattedHeight}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
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
            tooltip: 'Hapus pengukuran',
            onPressed: () => _confirmDeleteMeasurement(context, m),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteMeasurement(BuildContext context, MeasurementModel m) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Pengukuran?'),
        content: Text(
          'Hapus catatan pengukuran tanggal ${m.date}? '
          'Tindakan ini tidak dapat dibatalkan.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              if (m.id != null) {
                await ref.read(trackerProvider).deleteMeasurement(m.id);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dangerText,
              minimumSize: const Size(0, 40),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _LatestStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconBackground;
  final Color iconColor;

  const _LatestStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconChip(
            icon: icon,
            size: 32,
            background: iconBackground,
            foreground: iconColor,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.hero.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<MeasurementModel> measurements;

  _GrowthChartPainter({required this.measurements});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 4.0);
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (measurements.isEmpty) return;

    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotRing = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotFill = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;

    List<Offset> points = [];

    if (measurements.length >= 2) {
      final weights = measurements.map((m) => m.weight).toList();
      double minW = weights.reduce((a, b) => a < b ? a : b);
      double maxW = weights.reduce((a, b) => a > b ? a : b);
      if ((maxW - minW).abs() < 0.1) {
        maxW += 1.0;
        minW = (minW - 1.0).clamp(0.0, double.infinity);
      }
      final padding = (maxW - minW) * 0.2;
      final graphMin = (minW - padding).clamp(0.0, double.infinity);
      final graphMax = maxW + padding;
      final range = graphMax - graphMin;

      for (int i = 0; i < measurements.length; i++) {
        final double x =
            size.width * (0.06 + (0.88 * (i / (measurements.length - 1))));
        final double normalizedY =
            1.0 - ((measurements[i].weight - graphMin) / range).clamp(0.08, 0.92);
        final double y = size.height * normalizedY;
        points.add(Offset(x, y));
      }
    } else if (measurements.length == 1) {
      points = [Offset(size.width * 0.5, size.height * 0.5)];
    }

    if (points.length >= 2) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (final p in points) {
      canvas.drawCircle(p, 5, dotFill);
      canvas.drawCircle(p, 5, dotRing);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 4.0;
    const gap = 4.0;
    final distance = (end - start).distance;
    final direction = (end - start) / distance;
    var travelled = 0.0;
    while (travelled < distance) {
      final segmentEnd = (travelled + dash).clamp(0.0, distance);
      canvas.drawLine(
        start + direction * travelled,
        start + direction * segmentEnd,
        paint,
      );
      travelled += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) =>
      oldDelegate.measurements != measurements;
}
