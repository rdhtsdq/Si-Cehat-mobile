import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class PhotoPickerPreset {
  final String assetPath;
  final String label;

  const PhotoPickerPreset({
    required this.assetPath,
    required this.label,
  });
}

class PhotoPickerSheet extends StatelessWidget {
  final String title;
  final List<PhotoPickerPreset> presets;
  final ValueChanged<String> onSelected;
  final VoidCallback onReset;

  const PhotoPickerSheet({
    super.key,
    required this.title,
    required this.presets,
    required this.onSelected,
    required this.onReset,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<PhotoPickerPreset> presets,
    required ValueChanged<String> onSelected,
    required VoidCallback onReset,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PhotoPickerSheet(
        title: title,
        presets: presets,
        onSelected: (val) {
          Navigator.of(ctx).pop();
          onSelected(val);
        },
        onReset: () {
          Navigator.of(ctx).pop();
          onReset();
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        onSelected(base64String);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.headingScreen.copyWith(fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pilihan Media / Foto (Kamera & Galeri)
          Text(
            'Unggah Media / Foto:',
            style: AppTypography.bodySecondary.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMediaOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  sublabel: 'Ambil foto baru',
                  color: AppColors.primaryGreen,
                  onTap: () => _pickImage(context, ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMediaOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: 'Galeri',
                  sublabel: 'Pilih dari album',
                  color: const Color(0xFF2563EB),
                  onTap: () => _pickImage(context, ImageSource.gallery),
                ),
              ),
            ],
          ),

          // Presets Karakter Si-Cehat
          if (presets.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(
              'Pilih dari Karakter Si-Cehat:',
              style: AppTypography.bodySecondary.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: presets.map((preset) {
                return InkWell(
                  key: Key('preset_${preset.label}'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelected(preset.assetPath),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Column(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(preset.assetPath, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          preset.label,
                          style: AppTypography.bodySecondary.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Hapus / Reset Foto',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTypography.titleCard.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: AppTypography.bodySecondary.copyWith(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
