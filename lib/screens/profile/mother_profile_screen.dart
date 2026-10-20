import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/api/api_constants.dart';
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
                        child: _buildAvatarImage(mother?.avatarUrl),
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
                          onTap: () => _showAvatarPicker(context),
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

  Widget _buildAvatarImage(String? url) {
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('assets/')) {
        return Image.asset(url, fit: BoxFit.cover);
      }
      final fullUrl = url.startsWith('http') ? url : '${ApiConstants.baseUrl}$url';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Icon(
          Icons.person,
          size: 56,
          color: Color(0xFF424242),
        ),
      );
    }
    return const Icon(
      Icons.person,
      size: 56,
      color: Color(0xFF424242),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    final urlController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(bottomSheetCtx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih Foto Profil Ibu',
                    style: AppTypography.headingScreen.copyWith(fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(bottomSheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Pilih dari Karakter Si-Cehat:',
                style: AppTypography.bodySecondary.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPresetAvatarItem(
                    bottomSheetCtx,
                    context,
                    'assets/dashboard/hello.png',
                    'Ibu Si Cehat',
                  ),
                  _buildPresetAvatarItem(
                    bottomSheetCtx,
                    context,
                    'assets/dashboard/consultation.png',
                    'Ibu Konsultasi',
                  ),
                  _buildPresetAvatarItem(
                    bottomSheetCtx,
                    context,
                    'assets/dashboard/screening.png',
                    'Ibu Skrining',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Atau Masukkan URL Gambar:',
                style: AppTypography.bodySecondary.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: 'https://...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final url = urlController.text.trim();
                      if (url.isNotEmpty) {
                        Navigator.of(bottomSheetCtx).pop();
                        await context.read<ProfileProvider>().updateAvatar(url);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    Navigator.of(bottomSheetCtx).pop();
                    await context.read<ProfileProvider>().updateAvatar('');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Foto profil dikembalikan ke default')),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Hapus / Reset Foto', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPresetAvatarItem(
    BuildContext bottomSheetCtx,
    BuildContext parentCtx,
    String assetOrUrl,
    String label,
  ) {
    final isAsset = assetOrUrl.startsWith('assets/');
    return GestureDetector(
      key: Key('preset_$label'),
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        Navigator.of(bottomSheetCtx).pop();
        await parentCtx.read<ProfileProvider>().updateAvatar(assetOrUrl);
        if (parentCtx.mounted) {
          ScaffoldMessenger.of(parentCtx).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui')),
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryGreen, width: 2),
            ),
            child: ClipOval(
              child: isAsset
                  ? Image.asset(assetOrUrl, fit: BoxFit.contain)
                  : Image.network(assetOrUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
