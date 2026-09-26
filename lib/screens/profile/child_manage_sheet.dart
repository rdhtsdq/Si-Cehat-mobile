import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/child_model.dart';
import '../../providers/profile_provider.dart';

class ChildManageSheet extends StatefulWidget {
  const ChildManageSheet({super.key});

  @override
  State<ChildManageSheet> createState() => _ChildManageSheetState();
}

class _ChildManageSheetState extends State<ChildManageSheet> {
  bool _isAdding = false;
  final _nameController = TextEditingController();
  final _dobController = TextEditingController(text: '2018-05-14');
  String _selectedGender = 'Laki-laki';
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
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
            ...children.map((child) {
              final isSelected = child.isActive;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.paleGreenBg : AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected ? AppColors.primaryGreen : Colors.grey[400],
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    child.name,
                    style: AppTypography.titleCard.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${child.gender} • Usia ${child.ageInYears} tahun',
                    style: AppTypography.bodySecondary,
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
                      : null,
                  onTap: () async {
                    await profileProv.selectActiveChild(child.id);
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
            ),
            const SizedBox(height: 12),
            AppTextField(
              label: 'Tanggal Lahir (YYYY-MM-DD)',
              hintText: 'Contoh: 2018-05-14',
              controller: _dobController,
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
              onPressed: () async {
                if (_nameController.text.trim().isEmpty) return;
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
