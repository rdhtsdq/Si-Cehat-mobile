import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/safety_banner.dart';

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  void _showUnavailableNotice(BuildContext context, String role) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.accentOrange),
            const SizedBox(width: 8),
            Text('Konsultasi $role', style: AppTypography.titleCard),
          ],
        ),
        content: Text(
          'Layanan konsultasi belum aktif pada prototipe ini.\n\nUntuk kondisi darurat atau pemeriksaan klinis anak, silakan kunjungi Puskesmas atau fasilitas kesehatan terdekat.',
          style: AppTypography.bodySecondary.copyWith(
            color: AppColors.textDark,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
          ),
        ],
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
                text: 'Fitur Informasi & Kemitraan: Konsultasi medis interaktif dijadwalkan pada tahap lanjutan setelah integrasi faskes terverifikasi.',
                type: BannerType.notice,
              ),
              const SizedBox(height: 16),

              // Tiga card abu muda besar tersusun vertikal sesuai PDF S16:
              // Tiap card berikon gelembung chat hitam di kiri dan teks bold: Bidan, Ahli Gizi, Dokter
              _buildRoleCard(
                context,
                title: 'Bidan',
                subtitle: 'Konsultasi pendampingan ibu dan tumbuh kembang balita/anak',
                onTap: () => _showUnavailableNotice(context, 'Bidan'),
              ),
              const SizedBox(height: 16),

              _buildRoleCard(
                context,
                title: 'Ahli Gizi',
                subtitle: 'Konsultasi pengaturan menu, porsi, dan batasan gula anak',
                onTap: () => _showUnavailableNotice(context, 'Ahli Gizi'),
              ),
              const SizedBox(height: 16),

              _buildRoleCard(
                context,
                title: 'Dokter',
                subtitle: 'Pemeriksaan lanjutan dan rekomendasi klinis anak',
                onTap: () => _showUnavailableNotice(context, 'Dokter'),
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
              // Ikon gelembung chat hitam di kiri sesuai PDF S16
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
