import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/measurement_model.dart';
import '../../providers/profile_provider.dart';
import '../../providers/tracker_provider.dart';
import 'add_measurement_sheet.dart';
import 'habit_log_screen.dart';

class TrackerScreen extends StatefulWidget {
  final bool showBackButton;

  const TrackerScreen({super.key, this.showBackButton = true});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  int _selectedTab = 0; // 0: Tumbuh Kembang, 1: Aktivitas

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final child = context.read<ProfileProvider>().activeChild;
      if (child != null) {
        context.read<TrackerProvider>().loadMeasurements(child.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackerProv = context.watch<TrackerProvider>();
    final measurements = trackerProv.measurements;
    final latest = trackerProv.latestMeasurement;

    final String lastWeight = latest != null ? latest.formattedWeight : '20,5 kg';
    final String lastHeight = latest != null ? latest.formattedHeight : '118 cm';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
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
              // Dua tab horizontal: "Tumbuh Kembang" & "Aktivitas" sesuai PDF S11
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
                // Heading "Grafik BB (Kg)"
                Text(
                  'Grafik BB (Kg)',
                  style: AppTypography.titleCard.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                // Kartu Grafik Berbayang Putih
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
                        child: CustomPaint(
                          painter: _GrowthChartPainter(measurements: measurements),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Sumbu bulan Jan - Mei
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Jan', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('Feb', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('Mar', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('Apr', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          Text('Mei', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Bagian bawah kartu informasi ringkasan:
                // "Berat Badan Terakhir" (20,5 kg) dan "Tinggi Badan Terakhir" (118 cm)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

                // Tombol "Tambah Pengukuran" membuka E06
                PrimaryButton(
                  text: '+ Tambah Pengukuran',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => const AddMeasurementSheet(),
                    );
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
    // Sumbu horizontal & grid halus
    final gridPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 4.0);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Warna garis toska sesuai PDF S11
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

    // Nilai BB (19.0 sampai 20.5 kg)
    final points = <Offset>[
      Offset(size.width * 0.05, size.height * 0.85),
      Offset(size.width * 0.28, size.height * 0.65),
      Offset(size.width * 0.50, size.height * 0.50),
      Offset(size.width * 0.73, size.height * 0.35),
      Offset(size.width * 0.95, size.height * 0.15),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Titik bulat pada garis
    for (final p in points) {
      canvas.drawCircle(p, 6.0, dotPaint);
      canvas.drawCircle(p, 3.0, dotInner);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
