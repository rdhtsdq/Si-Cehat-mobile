import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../auth/login_screen.dart';
import '../auth/privacy_sheet.dart';
import 'mother_profile_screen.dart';
import 'child_profile_screen.dart';
import 'child_manage_sheet.dart';

class ProfileSelectScreen extends StatelessWidget {
  const ProfileSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Ilustrasi siluet ibu menggendong anak berwarna hitam di tengah area atas sesuai PDF
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.family_restroom,
                      size: 80,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Dua bidang abu muda lebar: Profil Ibu, kemudian Profil Anak sesuai PDF
              _buildProfileOption(
                context,
                title: 'Profil Ibu',
                subtitle: 'Data pribadi & demografi orang tua',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MotherProfileScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildProfileOption(
                context,
                title: 'Profil Anak',
                subtitle: 'Riwayat & pemantauan pertumbuhan anak',
                icon: Icons.child_care,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChildProfileScreen()),
                  );
                },
              ),

              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 16),

              // Tambahan operasional usulan spec
              Text(
                'Pengaturan Sesi Demo',
                style: AppTypography.titleCard.copyWith(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.people_outline, color: AppColors.textDark),
                title: Text('Ganti / Tambah Anak', style: AppTypography.bodyRegular),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
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
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.textDark),
                title: Text('Informasi Privasi & Data', style: AppTypography.bodyRegular),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => const PrivacyConsentSheet(),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restore, color: AppColors.accentOrange),
                title: Text(
                  'Reset Data Demo ke Awal',
                  style: AppTypography.bodyRegular.copyWith(color: AppColors.accentOrange),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset Data Demo?'),
                      content: const Text(
                        'Semua perubahan data lokal, pengukuran, dan catatan akan dikembalikan ke data awal.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
                          child: const Text('Reset', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<ProfileProvider>().resetAllData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Data demo berhasil direset ke awal')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: AppColors.accentRed),
                title: Text(
                  'Keluar Sesi Demo',
                  style: AppTypography.bodyRegular.copyWith(color: AppColors.accentRed),
                ),
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.fieldBackground,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 28, color: AppColors.textDark),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headingScreen.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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
