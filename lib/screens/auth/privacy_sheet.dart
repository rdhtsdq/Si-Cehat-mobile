import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/safety_banner.dart';

class PrivacyConsentSheet extends StatelessWidget {
  const PrivacyConsentSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Privasi & Transparansi Data',
                style: AppTypography.titleCard.copyWith(fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          const SafetyBanner(
            text: 'Prinsip Perlindungan Data Anak: Seluruh data kesehatan pada tahap demo tersimpan secara lokal pada perangkat Anda.',
            type: BannerType.offline,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Tujuan Pengumpulan Data', style: AppTypography.titleCard),
                  const SizedBox(height: 4),
                  Text(
                    'Data profil anak (nama, tanggal lahir, dan catatan pengukuran BB/TB) digunakan semata-mata untuk simulasi pelacakan pertumbuhan dan edukasi pencegahan diabetes melitus.',
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: 14),
                  Text('2. Tidak Ada Diagnosis Medis', style: AppTypography.titleCard),
                  const SizedBox(height: 4),
                  Text(
                    'Aplikasi ini adalah media edukasi dan pendamping kebiasaan keluarga, bukan perangkat diagnostik medis dan tidak menggantikan pemeriksaan dokter spesialis anak atau tenaga gizi.',
                    style: AppTypography.bodySecondary,
                  ),
                  const SizedBox(height: 14),
                  Text('3. Penyimpanan & Keamanan', style: AppTypography.titleCard),
                  const SizedBox(height: 4),
                  Text(
                    'Data Anda tidak dijual atau dikirim ke pihak ketiga tanpa persetujuan etik penelitian resmi.',
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Saya Memahami',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
