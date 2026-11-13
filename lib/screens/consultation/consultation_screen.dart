import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/safety_banner.dart';
import '../../providers/app_providers.dart';
import 'notification_center_screen.dart';

class ConsultationScreen extends ConsumerStatefulWidget {
  const ConsultationScreen({super.key});

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> {
  List<dynamic> _myConsultations = [];
  bool _submitting = false;

  final _topicController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _fetchMyConsultations();
  }

  @override
  void dispose() {
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyConsultations() async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.consultations);
      if (res.isSuccess && res.data != null) {
        final list = res.data['consultations'] as List<dynamic>?;
        if (list != null && mounted) {
          setState(() => _myConsultations = list);
        }
      }
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submitConsultation() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      _showSnack('Topik konsultasi wajib diisi.');
      return;
    }
    final scheduledDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    setState(() => _submitting = true);

    final res = await ApiClient.instance.post(
      ApiConstants.consultations,
      body: {
        'topic': topic,
        'scheduledDate': scheduledDate,
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res.isSuccess) {
      ref.read(notificationProvider).loadNotifications();
      _fetchMyConsultations();
      _topicController.clear();
      _notesController.clear();
      _showSnack('Permintaan konsultasi berhasil dikirim.');
    } else {
      // Local fallback
      await ref
          .read(notificationProvider)
          .addLocalNotification(
            title: 'Permintaan Konsultasi Terkirim',
            message: 'Konsultasi "$topic" pada $scheduledDate telah diajukan.',
            type: 'CONSULTATION',
          );
      if (!mounted) return;
      _showSnack('Jadwal konsultasi telah dicatat (offline).');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotifs = ref.watch(
      notificationProvider.select((p) => p.unreadCount),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Konsultasi',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  size: 26,
                  color: AppColors.textDark,
                ),
                if (unreadNotifs > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$unreadNotifs',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationCenterScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async => _fetchMyConsultations(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SafetyBanner(
                  text:
                      'Ajukan permintaan konsultasi untuk ditindaklanjuti kader/tenaga kesehatan Posyandu Anda. Konsultasi ini bukan layanan medis darurat.',
                  type: BannerType.notice,
                ),
                const SizedBox(height: 16),
                _buildFormCard(),
                const SizedBox(height: 24),
                if (_myConsultations.isNotEmpty) ...[
                  Text(
                    'Riwayat Konsultasi Saya',
                    style: AppTypography.titleCard.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._myConsultations.map((c) => _buildHistoryCard(c)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajukan Konsultasi',
            style: AppTypography.titleCard.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _topicController,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: 'Topik / Keluhan Konsultasi',
              hintText: 'Contoh: Konsultasi porsi makan & berat badan anak',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Tanggal Konsultasi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.primaryGreenDark,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('d MMMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Catatan (opsional)',
              hintText: 'Kondisi anak yang ingin disampaikan',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitConsultation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Ajukan Konsultasi'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(dynamic consultation) {
    final status = (consultation['status'] ?? 'PENDING')
        .toString()
        .toUpperCase();
    Color statusBg = Colors.amber.shade50;
    Color statusText = Colors.amber.shade800;
    String statusLabel = 'Menunggu';

    if (status == 'ACTIVE') {
      statusBg = const Color(0xFFF0FDF4);
      statusText = AppColors.primaryGreenDark;
      statusLabel = 'Aktif';
    } else if (status == 'COMPLETED') {
      statusBg = const Color(0xFFEFF6FF);
      statusText = const Color(0xFF1D4ED8);
      statusLabel = 'Selesai';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  consultation['topic'] ?? 'Konsultasi',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (consultation['scheduledDate'] != null &&
              consultation['scheduledDate'].toString().isNotEmpty)
            Row(
              children: [
                const Icon(
                  Icons.event_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Jadwal: ${consultation['scheduledDate']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          if (consultation['notes'] != null &&
              consultation['notes'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Catatan: ${consultation['notes']}',
                style: const TextStyle(fontSize: 11, color: AppColors.textDark),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
