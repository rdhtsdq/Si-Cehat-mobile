import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/avatar_image.dart';
import '../../data/models/child_model.dart';
import '../../providers/app_providers.dart';

class ChildManageSheet extends ConsumerStatefulWidget {
  const ChildManageSheet({super.key});

  @override
  ConsumerState<ChildManageSheet> createState() => _ChildManageSheetState();
}

class _ChildManageSheetState extends ConsumerState<ChildManageSheet> {
  bool _isAdding = false;
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  String _selectedGender = 'Laki-laki';
  final _notesController = TextEditingController();
  String? _nameError;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 6, now.month, now.day),
      firstDate: DateTime(now.year - 18),
      lastDate: now,
    );
    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = ref.watch(profileProvider);
    final children = profileProv.children;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
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
                _isAdding ? 'Tambah Data Anak' : 'Pilih Profil Anak',
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

          if (!_isAdding) ...[
            if (children.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Belum ada profil anak. Tambahkan data anak di bawah ini.',
                  style: AppTypography.bodySecondary,
                ),
              ),
            ...children.map((child) {
              final isSelected = child.isActive;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.paleGreenBg
                      : AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  leading: AvatarImage(
                    avatarUrl: child.avatarUrl,
                    size: 40,
                    fallbackIcon: Icons.face,
                    backgroundColor: isSelected
                        ? AppColors.primaryGreen
                        : Colors.grey[400]!,
                  ),
                  title: Text(
                    child.name,
                    style: AppTypography.titleCard.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    child.dateOfBirth.isNotEmpty
                        ? '${child.gender} \u2022 Usia ${child.ageInYears} tahun'
                        : child.gender,
                    style: AppTypography.bodySecondary,
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryGreen,
                        )
                      : null,
                  onTap: () async {
                    final trackerProv = ref.read(trackerProvider);
                    await profileProv.selectActiveChild(child.id);
                    trackerProv.loadMeasurements(child.id);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              );
            }),
            const SizedBox(height: 12),
            PrimaryButton(
              text: '+ Tambah Anak Baru',
              isOutlined: true,
              onPressed: () {
                setState(() => _isAdding = true);
              },
            ),
          ] else ...[
            AppTextField(
              label: 'Nama Anak',
              hintText: 'Masukkan nama anak',
              controller: _nameController,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) setState(() => _nameError = null);
              },
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickBirthDate,
              child: AbsorbPointer(
                child: AppTextField(
                  label: 'Tanggal Lahir (YYYY-MM-DD)',
                  hintText: 'Ketuk untuk memilih tanggal lahir',
                  controller: _dobController,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Jenis Kelamin', style: AppTypography.labelInput),
            const SizedBox(height: 6),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Laki-laki'),
                  selected: _selectedGender == 'Laki-laki',
                  onSelected: (val) {
                    if (val) setState(() => _selectedGender = 'Laki-laki');
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Perempuan'),
                  selected: _selectedGender == 'Perempuan',
                  onSelected: (val) {
                    if (val) setState(() => _selectedGender = 'Perempuan');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Simpan Anak',
              isLoading: _isSaving,
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) {
                  setState(() => _nameError = 'Nama anak wajib diisi');
                  return;
                }
                setState(() => _isSaving = true);
                final newChild = ChildModel(
                  id: 0,
                  name: _nameController.text.trim(),
                  dateOfBirth: _dobController.text.trim(),
                  gender: _selectedGender,
                  healthNotes: _notesController.text.trim(),
                  isActive: true,
                );
                await profileProv.addChild(newChild);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}
