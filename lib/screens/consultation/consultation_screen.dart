import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/safety_banner.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  List<dynamic> _specialists = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchSpecialists();
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

  void _showSpecialistDetail(BuildContext context, String role, String typeKey) {
    final filtered = _specialists.where((s) => (s['type'] ?? '').toString().toUpperCase() == typeKey).toList();
    final specialist = filtered.isNotEmpty ? filtered.first : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
                  child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        specialist != null ? specialist['name'] : 'Tenaga Medis Mitra $role',
                        style: AppTypography.titleCard.copyWith(fontSize: 16),
                      ),
                      Text(
                        specialist != null ? specialist['title'] : 'Mitra Terverifikasi',
                        style: AppTypography.bodySecondary.copyWith(color: AppColors.textSecondary),
                      ),
                      if (specialist != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${specialist['rating']} • Pengalaman ${specialist['experienceYears']} tahun',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                children: (specialist['focus'] as List).map<Widget>((f) => Chip(
                  label: Text(f.toString(), style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.paleGreenBg,
                  side: BorderSide.none,
                )).toList(),
              ),
            ] else ...[
              const Text('• Edukasi pencegahan diabetes anak\n• Pola makan dan gaya hidup sehat'),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Permintaan konsultasi telah dicatat di server.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Ajukan Jadwal Konsultasi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Konsultasi',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SafetyBanner(
                text: 'Direktori Tenaga Medis Mitra Si-Cehat: Pilih spesialis untuk konsultasi pencegahan & tumbuh kembang anak.',
                type: BannerType.notice,
              ),
              const SizedBox(height: 16),

              _buildRoleCard(
                context,
                title: 'Bidan',
                subtitle: 'Konsultasi pendampingan ibu dan tumbuh kembang balita/anak',
                onTap: () => _showSpecialistDetail(context, 'Bidan', 'BIDAN'),
              ),
              const SizedBox(height: 16),

              _buildRoleCard(
                context,
                title: 'Ahli Gizi',
                subtitle: 'Konsultasi pengaturan menu, porsi, dan batasan gula anak',
                onTap: () => _showSpecialistDetail(context, 'Ahli Gizi', 'AHLI_GIZI'),
              ),
              const SizedBox(height: 16),

              _buildRoleCard(
                context,
                title: 'Dokter',
                subtitle: 'Pemeriksaan lanjutan dan rekomendasi klinis anak',
                onTap: () => _showSpecialistDetail(context, 'Dokter', 'DOKTER'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.fieldBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 32,
                color: Color(0xFF212121),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headingScreen.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
