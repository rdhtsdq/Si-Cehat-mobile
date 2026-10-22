import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
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

    final String lastWeight = latest != null ? latest.formattedWeight : '- kg';
    final String lastHeight = latest != null ? latest.formattedHeight : '- cm';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: AppColors.textDark,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(
          'Tracker',
          style: AppTypography.headingScreen.copyWith(fontSize: 24),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: 'Tumbuh Kembang',
                      isActive: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Aktivitas',
                      isActive: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_selectedTab == 0) ...[
                Text(
                  'Grafik BB (Kg)',
                  style: AppTypography.titleCard.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: measurements.isEmpty
                            ? Center(
                                child: Text(
                                  'Belum ada riwayat pengukuran.\nTambahkan pengukuran atau lakukan skrining.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodySecondary.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : CustomPaint(
                                painter: _GrowthChartPainter(
                                  measurements: measurements,
                                ),
                              ),
                      ),
                      if (measurements.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
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
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Berat Badan Terakhir',
                              style: AppTypography.bodySecondary.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastWeight,
                              style: AppTypography.titleCard.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.fieldBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tinggi Badan Terakhir',
                              style: AppTypography.bodySecondary.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lastHeight,
                              style: AppTypography.titleCard.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                PrimaryButton(
                  text: '+ Tambah Pengukuran',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) => const AddMeasurementSheet(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Riwayat Pengukuran
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Pengukuran',
                      style: AppTypography.titleCard.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${measurements.length} Catatan',
                      style: AppTypography.bodySecondary.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (measurements.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: Center(
                      child: Text(
                        'Belum ada data pengukuran.',
                        style: AppTypography.bodySecondary,
                      ),
                    ),
                  )
                else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: measurements.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final m = measurements[measurements.length - 1 - index];
                        return _buildMeasurementHistoryTile(context, m);
                      },
                    ),
                ] else ...[
                  // Tab Aktivitas (E07)
                  const HabitLogView(),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildMeasurementHistoryTile(BuildContext context, MeasurementModel m) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.veryLightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_today, size: 20, color: AppColors.primaryGreenDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        m.date,
                        style: AppTypography.titleCard.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (m.source.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            m.source,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ],
                ),
                const SizedBox(height: 4),
                Text(
                  'BB: ${m.formattedWeight}  •  TB: ${m.formattedHeight}',
                  style: AppTypography.bodySecondary.copyWith(
                    fontSize: 13,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
            tooltip: 'Hapus Pengukuran',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('Hapus Pengukuran?'),
                  content: Text('Hapus catatan pengukuran tanggal ${m.date}? Tindakan ini tidak dapat dibatalkan.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(dialogCtx).pop();
                        if (m.id != null) {
                          await ref.read(trackerProvider).deleteMeasurement(m.id);
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primaryGreen : AppColors.fieldBackground,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Text(
            title,
            style: AppTypography.buttonText.copyWith(
              color: isActive ? Colors.white : AppColors.textDark,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
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
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (measurements.isEmpty) return;

    const toscaColor = Color(0xFF009688);
    final linePaint = Paint()
      ..color = toscaColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = toscaColor
      ..style = PaintingStyle.fill;

    final dotInner = Paint()
      ..color = Colors.white
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
        final double x = size.width * (0.06 + (0.88 * (i / (measurements.length - 1))));
        final double normalizedY = 1.0 - ((measurements[i].weight - graphMin) / range).clamp(0.08, 0.92);
        final double y = size.height * normalizedY;
        points.add(Offset(x, y));
      }
    } else if (measurements.length == 1) {
      points = [Offset(size.width * 0.5, size.height * 0.5)];
    } else {
      // Nilai fallback BB (19.0 sampai 20.5 kg)
      points = <Offset>[
        Offset(size.width * 0.05, size.height * 0.85),
        Offset(size.width * 0.28, size.height * 0.65),
        Offset(size.width * 0.50, size.height * 0.50),
        Offset(size.width * 0.73, size.height * 0.35),
        Offset(size.width * 0.95, size.height * 0.15),
      ];
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
      canvas.drawCircle(p, 6.0, dotPaint);
      canvas.drawCircle(p, 3.0, dotInner);
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) =>
      oldDelegate.measurements != measurements;
}
