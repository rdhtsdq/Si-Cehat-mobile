import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/avatar_image.dart';
import '../../core/widgets/photo_picker_sheet.dart';
import '../../providers/app_providers.dart';
import 'edit_profile_screen.dart';

class MotherProfileScreen extends ConsumerWidget {
  const MotherProfileScreen({super.key});

  String _valOrPlaceholder(String? val) {
    if (val == null || val.trim().isEmpty) return 'Belum diisi';
    return val;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileProv = ref.watch(profileProvider);
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

              // Interactive Avatar with camera edit badge
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
                          avatarUrl: mother?.avatarUrl,
                          size: 96,
                          fallbackIcon: Icons.person,
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
                          onTap: () => _showAvatarPicker(context, ref),
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
                label: 'Nama Ibu',
                value: _valOrPlaceholder(mother?.name),
              ),
              const SizedBox(height: 14),
              _buildProfileRow(
                label: 'Nomor Telepon',
                value: _valOrPlaceholder(mother?.phone),
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
                label: 'Alamat Rumah',
                value: _valOrPlaceholder(mother?.address),
              ),
              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Edit Profil',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(isMother: true),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow({required String label, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySecondary.copyWith(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.titleCard.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, WidgetRef ref) {
    PhotoPickerSheet.show(
      context: context,
      title: 'Pilih Foto Profil Ibu',
      presets: const [
        PhotoPickerPreset(
          assetPath: 'assets/dashboard/hello.png',
          label: 'Ibu Si Cehat',
        ),
        PhotoPickerPreset(
          assetPath: 'assets/dashboard/consultation.png',
          label: 'Ibu Konsultasi',
        ),
        PhotoPickerPreset(
          assetPath: 'assets/dashboard/screening.png',
          label: 'Ibu Skrining',
        ),
      ],
      onSelected: (assetOrBase64) async {
        final isBase64 = assetOrBase64.startsWith('data:');
        await ref.read(profileProvider).updateAvatar(
              assetOrBase64,
              isBase64: isBase64,
            );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        }
      },
      onReset: () async {
        await ref.read(profileProvider).updateAvatar('');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil dikembalikan ke default')),
          );
        }
      },
    );
  }
}
