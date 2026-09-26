import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/profile_provider.dart';
import '../tracker/tracker_screen.dart';
import 'edit_profile_screen.dart';
import 'child_manage_sheet.dart';

class ChildProfileScreen extends StatelessWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final child = profileProv.activeChild;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profil Anak',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: AppColors.textDark),
            tooltip: 'Ganti Anak',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => const ChildManageSheet(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              // Avatar orang generik dalam lingkaran abu
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFD6D6D6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.face,
                  size: 56,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 24),

              // Empat baris sesuai PDF: Nama Anak, Tanggal Lahir, Riwayat Kesehatan, Riwayat Pengukuran
              _buildProfileRow(
                label: 'Nama Anak',
                value: child?.name ?? 'Ahmad',
              ),
              const SizedBox(height: 14),
              _buildProfileRow(
                label: 'Tanggal Lahir',
                value: child?.dateOfBirth ?? '2018-05-14',
              ),
              const SizedBox(height: 14),
              _buildProfileRow(
                label: 'Riwayat Kesehatan',
                value: child?.healthNotes.isNotEmpty == true
                    ? child!.healthNotes
                    : 'Belum ada catatan khusus',
              ),
              const SizedBox(height: 14),

              // Riwayat Pengukuran: tap mengarahkan ke S11 Tracker!
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TrackerScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Riwayat Pengukuran',
                            style: AppTypography.bodySecondary.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lihat Grafik BB/TB di Tracker',
                            style: AppTypography.bodyRegular.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreenDark,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.primaryGreenDark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Edit Data Anak',
                isOutlined: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(isMother: false),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow({required String label, required String value}) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTypography.bodyRegular.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
