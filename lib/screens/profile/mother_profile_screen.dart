import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/profile_provider.dart';
import 'edit_profile_screen.dart';

class MotherProfileScreen extends StatelessWidget {
  const MotherProfileScreen({super.key});

  String _valOrPlaceholder(String? val) {
    if (val == null || val.trim().isEmpty) return 'Belum diisi';
    return val;
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final mother = profileProv.mother;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profil Ibu',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFD6D6D6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 56,
                  color: Color(0xFF424242),
                ),
              ),
              const SizedBox(height: 24),

              _buildProfileRow(
                label: 'Nama Ibu',
                value: _valOrPlaceholder(mother?.name),
              ),
              const SizedBox(height: 14),
              _buildProfileRow(
                label: 'Pendidikan',
                value: _valOrPlaceholder(mother?.education),
              ),
              const SizedBox(height: 14),
              _buildProfileRow(
                label: 'Pekerjaan',
                value: _valOrPlaceholder(mother?.occupation),
              ),
              const SizedBox(height: 14),
              _buildProfileRow(
                label: 'Alamat',
                value: _valOrPlaceholder(mother?.address),
              ),

              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Edit Profil',
                isOutlined: true,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(isMother: true),
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
              color: value == 'Belum diisi'
                  ? AppColors.textSecondary
                  : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
