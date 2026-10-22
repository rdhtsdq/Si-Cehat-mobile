import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/avatar_image.dart';
import '../../core/widgets/photo_picker_sheet.dart';
import '../../data/models/child_model.dart';
import '../../providers/app_providers.dart';
import '../tracker/tracker_screen.dart';
import 'edit_profile_screen.dart';
import 'child_manage_sheet.dart';

class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileProv = ref.watch(profileProvider);
    final child = profileProv.activeChild;

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

              // Interactive Avatar with camera edit badge for Child
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6D6D6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: AvatarImage(
                          avatarUrl: child?.avatarUrl,
                          size: 96,
                          fallbackIcon: Icons.face,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: AppColors.primaryGreen,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: child != null
                              ? () => _showAvatarPicker(context, ref, child)
                              : null,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildProfileRow(
                label: 'Nama Anak',
                value: (child?.name.isNotEmpty == true)
                    ? child!.name
                    : 'Belum diisi',
              ),
              const SizedBox(height: 14),
              _buildProfileRow(
                label: 'Tanggal Lahir',
                value: (child?.dateOfBirth.isNotEmpty == true)
                    ? child!.dateOfBirth
                    : 'Belum diisi',
              ),
              const SizedBox(height: 14),
              _buildProfileRow(
                label: 'Riwayat Kesehatan',
                value: child?.healthNotes.isNotEmpty == true
                    ? child!.healthNotes
                    : 'Belum ada catatan khusus',
              ),
              const SizedBox(height: 14),

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    ),
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
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.primaryGreenDark,
                      ),
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
              color: value == 'Belum diisi'
                  ? AppColors.textSecondary
                  : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, WidgetRef ref, ChildModel child) {
    PhotoPickerSheet.show(
      context: context,
      title: 'Pilih Foto Profil Anak',
      presets: const [
        PhotoPickerPreset(
          assetPath: 'assets/dashboard/hello.png',
          label: 'Anak Si Cehat',
        ),
        PhotoPickerPreset(
          assetPath: 'assets/dashboard/activity.png',
          label: 'Aktivitas Anak',
        ),
        PhotoPickerPreset(
          assetPath: 'assets/dashboard/calculator.png',
          label: 'Gizi Cilik',
        ),
      ],
      onSelected: (assetOrBase64) async {
        final isBase64 = assetOrBase64.startsWith('data:');
        await ref.read(profileProvider).updateChildAvatar(
              child.id,
              assetOrBase64,
              isBase64: isBase64,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil anak berhasil diperbarui'),
            ),
          );
        }
      },
      onReset: () async {
        await ref.read(profileProvider).updateChildAvatar(child.id, '');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil anak dikembalikan ke default'),
            ),
          );
        }
      },
    );
  }
}
