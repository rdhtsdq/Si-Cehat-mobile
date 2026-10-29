import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  List<dynamic> _specialists = [];
  List<dynamic> _myConsultations = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchSpecialists();
    _fetchMyConsultations();
  }

  Future<void> _fetchSpecialists() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get(ApiConstants.specialists);
      if (res.isSuccess && res.data != null) {
        final list = res.data['specialists'] as List<dynamic>?;
        if (list != null) {
          setState(() => _specialists = list);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchMyConsultations() async {
    try {
      final res = await ApiClient.instance.get(ApiConstants.consultations);
      if (res.isSuccess && res.data != null) {
        final list = res.data['consultations'] as List<dynamic>?;
        if (list != null) {
          setState(() => _myConsultations = list);
        }
      }
    } catch (_) {}
  }

  Future<void> _requestConsultation(
    BuildContext sheetCtx,
    String role,
    String typeKey,
    dynamic specialist, [
    String? customTopic,
  ]) async {
    final name = specialist != null ? specialist['name'].toString() : 'Tenaga Medis Mitra $role';
    final topic = (customTopic != null && customTopic.isNotEmpty)
        ? customTopic
        : 'Konsultasi Pola Hidup & Nutrisi Sehat Anak ($role)';

    Navigator.of(sheetCtx).pop();

    final res = await ApiClient.instance.post(
      ApiConstants.consultations,
      body: {
        'specialistType': typeKey,
        'specialistName': name,
        'topic': topic,
        'notes': 'Permintaan diajukan melalui aplikasi Si-Cehat Mobile.',
      },
    );

    if (!mounted) return;

    if (res.isSuccess) {
      ref.read(notificationProvider).loadNotifications();
      _fetchMyConsultations();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permintaan konsultasi dengan $name berhasil dikirim! Notifikasi telah dibuat.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } else {
      // Local fallback
      await ref.read(notificationProvider).addLocalNotification(
        title: 'Permintaan Konsultasi Terkirim',
        message: 'Konsultasi dengan $name mengenai "$topic" telah diajukan.',
        type: 'CONSULTATION',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Jadwal konsultasi dengan $name telah dicatat.'),
        ),
      );
    }
  }

  List<dynamic> _specialistsOfType(String typeKey) {
    return _specialists
        .where((s) => (s['type'] ?? '').toString().toUpperCase() == typeKey)
        .toList();
  }

  void _openSpecialistPicker(
    BuildContext context,
    String role,
    String typeKey,
  ) {
    final specialists = _specialistsOfType(typeKey);

    if (specialists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Belum ada tenaga medis untuk kategori $role.'),
        ),
      );
      return;
    }

    if (specialists.length == 1) {
      _showSpecialistDetail(context, role, typeKey, specialists.first);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih $role',
                style: AppTypography.titleCard.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                '${specialists.length} tenaga medis tersedia untuk wilayah Anda.',
                style: AppTypography.bodySecondary.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: specialists.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final specialist = specialists[index];
                    return _buildSpecialistTile(
                      specialist: specialist,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _showSpecialistDetail(
                          context,
                          role,
                          typeKey,
                          specialist,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialistTile({
    required dynamic specialist,
    required VoidCallback onTap,
  }) {
    final name = specialist['name']?.toString() ?? 'Tenaga Medis';
    final title = (specialist['title'] ??
            specialist['typeLabel'] ??
            'Fasilitas Kesehatan Mitra Si-Cehat')
        .toString();
    final rating = specialist['rating'];
    final experience = specialist['experienceYears'];
    final focus = specialist['focus'];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.titleCard.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                    ),
                    if (rating != null || experience != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (rating != null) ...[
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 14,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '$rating',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (rating != null && experience != null)
                            const SizedBox(width: 10),
                          if (experience != null)
                            Text(
                              '$experience tahun pengalaman',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                    if (focus is List && focus.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: focus.take(3).map<Widget>((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.paleGreenBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryGreenDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpecialistDetail(
    BuildContext context,
    String role,
    String typeKey,
    dynamic specialist,
  ) {
    final specialistName = specialist != null
        ? specialist['name'].toString()
        : 'Tenaga Medis Mitra $role';
    final topicController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 24.0,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryGreen.withValues(
                    alpha: 0.15,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryGreen,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        specialistName,
                        style: AppTypography.titleCard.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        specialist != null
                            ? (specialist['hospital'] ?? specialist['title'] ?? 'Fasilitas Kesehatan Mitra Si-Cehat').toString()
                            : 'Fasilitas Kesehatan Mitra Si-Cehat',
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (specialist != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${specialist['rating']} \u2022 Pengalaman ${specialist['experienceYears']} tahun',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(),
            const SizedBox(height: 12),
            Text('Fokus Konsultasi:', style: AppTypography.labelInput),
            const SizedBox(height: 6),
            if (specialist != null && specialist['focus'] is List) ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: (specialist['focus'] as List)
                    .map<Widget>(
                      (f) => Chip(
                        label: Text(
                          f.toString(),
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: AppColors.paleGreenBg,
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
            ] else ...[
              const Text(
                '\u2022 Edukasi pencegahan diabetes anak\n\u2022 Pola makan dan gaya hidup sehat',
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                labelText: 'Keluhan / Topik Konsultasi',
                hintText: 'Contoh: Konsultasi porsi makan & berat badan anak',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _requestConsultation(ctx, role, typeKey, specialist, topicController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Ajukan Jadwal Konsultasi'),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      topicController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotifs = ref.watch(notificationProvider.select((p) => p.unreadCount));

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
                const Icon(Icons.notifications_outlined, size: 26, color: AppColors.textDark),
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
                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '$unreadNotifs',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          onRefresh: () async {
            await Future.wait([
              _fetchSpecialists(),
              _fetchMyConsultations(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SafetyBanner(
                  text:
                      'Direktori Tenaga Medis Mitra Si-Cehat: Pilih tenaga medis untuk konsultasi pencegahan & tumbuh kembang anak sesuai wilayah Posyandu Anda.',
                  type: BannerType.notice,
                ),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(color: AppColors.primaryGreen),
                  ),

                if (!_loading && _specialists.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Belum ada tenaga medis yang tersedia untuk wilayah Posyandu Anda. Silakan hubungi admin Posyandu atau coba lagi nanti.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                _buildRoleCard(
                  context,
                  title: 'Bidan',
                  subtitle:
                      'Konsultasi pendampingan ibu dan tumbuh kembang balita/anak',
                  count: _specialistsOfType('BIDAN').length,
                  onTap: () => _openSpecialistPicker(context, 'Bidan', 'BIDAN'),
                ),
                const SizedBox(height: 16),

                _buildRoleCard(
                  context,
                  title: 'Ahli Gizi',
                  subtitle:
                      'Konsultasi pengaturan menu, porsi, dan batasan gula anak',
                  count: _specialistsOfType('AHLI_GIZI').length,
                  onTap: () =>
                      _openSpecialistPicker(context, 'Ahli Gizi', 'AHLI_GIZI'),
                ),
                const SizedBox(height: 16),

                _buildRoleCard(
                  context,
                  title: 'Dokter',
                  subtitle: 'Pemeriksaan lanjutan faktor risiko dan rujukan klinis',
                  count: _specialistsOfType('DOKTER').length,
                  onTap: () => _openSpecialistPicker(context, 'Dokter', 'DOKTER'),
                ),
                const SizedBox(height: 24),

                // Riwayat Konsultasi Saya
                if (_myConsultations.isNotEmpty) ...[
                  Text(
                    'Riwayat Konsultasi Saya',
                    style: AppTypography.titleCard.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ..._myConsultations.map((c) => _buildConsultationHistoryCard(c)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: AppTypography.titleCard.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: count > 0
                                  ? AppColors.paleGreenBg
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              count > 0 ? '$count tersedia' : 'Belum tersedia',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: count > 0
                                    ? AppColors.primaryGreenDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodySecondary.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConsultationHistoryCard(dynamic consultation) {
    final status = (consultation['status'] ?? 'PENDING').toString().toUpperCase();
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
              Text(
                consultation['specialistName'] ?? 'Konsultasi Mitra',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            consultation['topic'] ?? 'Konsultasi',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (consultation['notes'] != null && consultation['notes'].toString().isNotEmpty) ...[
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
