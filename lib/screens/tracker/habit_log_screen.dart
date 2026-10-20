import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/activity_log_model.dart';
import '../../providers/profile_provider.dart';
import '../../providers/tracker_provider.dart';
import 'add_activity_sheet.dart';

class HabitLogView extends StatefulWidget {
  const HabitLogView({super.key});

  @override
  State<HabitLogView> createState() => _HabitLogViewState();
}

class _HabitLogViewState extends State<HabitLogView> {
  DateTime _currentDate = DateTime.now();
  dynamic _lastChildId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final child = context.watch<ProfileProvider>().activeChild;
    if (child != null && child.id != _lastChildId) {
      _lastChildId = child.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  void _loadData() {
    final child = context.read<ProfileProvider>().activeChild;
    if (child != null) {
      context.read<TrackerProvider>().loadActivities(child.id, date: _currentDate);
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
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
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
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;

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
        return Icons.restaurant;
      case 'Istirahat':
        return Icons.bedtime_outlined;
      default:
        return Icons.directions_run;
    }
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'Hidrasi Sehat':
        return const Color(0xFF0284C7);
      case 'Gizi Seimbang':
        return const Color(0xFFD97706);
      case 'Istirahat':
        return const Color(0xFF7C3AED);
      default:
        return AppColors.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackerProv = context.watch<TrackerProvider>();
    final profileProv = context.watch<ProfileProvider>();
    final child = profileProv.activeChild;

    final activities = trackerProv.activities;
    final totalMins = trackerProv.totalActiveMinutes;
    final percentage = trackerProv.activityPercentage;
    final waterGlasses = trackerProv.waterGlasses;
    final status = trackerProv.activityStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Pemilih Tanggal
        _buildDateNavigator(),
        const SizedBox(height: 14),

        // 2. Kartu Target Aktivitas Harian (60 Menit)
        _buildTargetSummaryCard(totalMins, percentage, status),
        const SizedBox(height: 14),

        // 3. Kartu Hidrasi (Gelas Air Putih) Cepat
        if (child != null) _buildWaterTrackerCard(child.id, waterGlasses, trackerProv),
        const SizedBox(height: 18),

        // 4. Header Daftar Aktivitas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Tercatat (${activities.length})',
              style: AppTypography.titleCard.copyWith(fontSize: 16),
            ),
            if (activities.isNotEmpty)
              Text(
                'Total $totalMins mnt aktif',
                style: AppTypography.bodySecondary.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreenDark,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // 5. Daftar Aktivitas
        if (trackerProv.isLoadingActivities)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          )
        else if (activities.isEmpty)
          _buildEmptyCard()
        else
          ...activities.map((act) => _buildActivityTile(act, trackerProv, child?.id)),

        const SizedBox(height: 18),

        // 6. Tombol Tambah Aktivitas
        PrimaryButton(
          text: '+ Catat Aktivitas Baru',
          isOutlined: true,
          onPressed: child != null
              ? () => AddActivitySheet.show(context, childId: child.id, date: _currentDate)
              : null,
        ),
      ],
    );
  }

  Widget _buildDateNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textDark),
            onPressed: () => _changeDate(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Hari Sebelumnya',
          ),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  Text(
                    _formatDateLabel(_currentDate),
                    style: AppTypography.titleCard.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textDark),
            onPressed: () => _changeDate(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Hari Berikutnya',
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSummaryCard(int totalMins, double percentage, String status) {
    final isTargetReached = totalMins >= 60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTargetReached
              ? [const Color(0xFF2E7D32), const Color(0xFF43A047)]
              : [const Color(0xFF1E293B), const Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isTargetReached ? Icons.emoji_events : Icons.directions_run,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Target Aktivitas Fisik',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isTargetReached
                      ? Colors.amber[300]
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isTargetReached ? const Color(0xFF1E293B) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$totalMins',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(width: 4),
              const Text(
                '/ 60 menit',
                style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isTargetReached ? Colors.amberAccent : AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            isTargetReached
                ? 'Luar biasa! Target 60 menit bermain aktif hari ini sudah tercapai.'
                : 'Anjuran Kemenkes: Minimal 60 menit aktivitas fisik setiap hari untuk cegah obesitas.',
            style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTrackerCard(dynamic childId, int glasses, TrackerProvider prov) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF0284C7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Konsumsi Air Putih',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0369A1)),
                ),
                const SizedBox(height: 2),
                Text(
                  '$glasses dari 8 Gelas (~${glasses * 250} ml)',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => prov.decrementWater(childId, date: _currentDate),
            icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF0284C7)),
            tooltip: 'Kurangi 1 Gelas',
          ),
          IconButton(
            onPressed: () => prov.incrementWater(childId, date: _currentDate),
            icon: const Icon(Icons.add_circle, color: Color(0xFF0284C7), size: 28),
            tooltip: 'Tambah 1 Gelas',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_bike_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Belum Ada Aktivitas Dicatat',
            style: AppTypography.titleCard.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajak anak bersepeda, bermain aktif, atau olahraga lalu catat di sini!',
            textAlign: TextAlign.center,
            style: AppTypography.bodySecondary.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(ActivityLogModel act, TrackerProvider prov, dynamic childId) {
    final catColor = _colorForCategory(act.category);
    final catIcon = _iconForCategory(act.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(catIcon, color: catColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  act.title,
                  style: AppTypography.bodyRegular.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    if (act.durationMinutes > 0) ...[
                      Text(
                        '${act.durationMinutes} menit',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                      const SizedBox(width: 6),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      act.category,
                      style: TextStyle(fontSize: 11, color: catColor, fontWeight: FontWeight.w600),
                    ),
                    if (act.intensity.isNotEmpty && act.category == 'Aktivitas Fisik') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          act.intensity,
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ],
                ),
                if (act.notes.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    act.notes,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
            tooltip: 'Hapus Aktivitas',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Aktivitas?'),
                  content: Text('Apakah Anda yakin ingin menghapus catatan "${act.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
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
    );
  }
}
