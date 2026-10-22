import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isMother;

  const EditProfileScreen({super.key, required this.isMother});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _field1Controller;
  late TextEditingController _field2Controller;
  late TextEditingController _field3Controller;
  late TextEditingController _field4Controller;

  @override
  void initState() {
    super.initState();
    final profileProv = context.read<ProfileProvider>();
    if (widget.isMother) {
      final mother = profileProv.mother;
      _field1Controller = TextEditingController(text: mother?.name ?? '');
      _field2Controller = TextEditingController(text: mother?.education ?? '');
      _field3Controller = TextEditingController(text: mother?.occupation ?? '');
      _field4Controller = TextEditingController(text: mother?.address ?? '');
    } else {
      final child = profileProv.activeChild;
      _field1Controller = TextEditingController(text: child?.name ?? '');
      _field2Controller = TextEditingController(text: child?.dateOfBirth ?? '');
      _field3Controller = TextEditingController(text: child?.healthNotes ?? '');
      _field4Controller = TextEditingController(text: child?.gender ?? '');
    }
  }

  @override
  void dispose() {
    _field1Controller.dispose();
    _field2Controller.dispose();
    _field3Controller.dispose();
    _field4Controller.dispose();
    super.dispose();
  }

  void _save() async {
    final profileProv = context.read<ProfileProvider>();
    if (widget.isMother && profileProv.mother != null) {
      final updated = profileProv.mother!.copyWith(
        name: _field1Controller.text.trim(),
        education: _field2Controller.text.trim(),
        occupation: _field3Controller.text.trim(),
        address: _field4Controller.text.trim(),
      );
      await profileProv.updateMother(updated);
    } else if (!widget.isMother && profileProv.activeChild != null) {
      final updated = profileProv.activeChild!.copyWith(
        name: _field1Controller.text.trim(),
        dateOfBirth: _field2Controller.text.trim(),
        healthNotes: _field3Controller.text.trim(),
        gender: _field4Controller.text.trim(),
      );
      await profileProv.updateChild(updated);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perubahan profil berhasil disimpan'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isMother ? 'Edit Profil Ibu' : 'Edit Profil Anak';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              AppTextField(
                label: widget.isMother ? 'Nama Ibu' : 'Nama Anak',
                hintText: 'Masukkan nama',
                controller: _field1Controller,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: widget.isMother ? 'Pendidikan' : 'Tanggal Lahir (YYYY-MM-DD)',
                hintText: widget.isMother ? 'Pendidikan terakhir' : '2018-05-14',
                controller: _field2Controller,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: widget.isMother ? 'Pekerjaan' : 'Riwayat Kesehatan',
                hintText: widget.isMother ? 'Pekerjaan' : 'Catatan kesehatan',
                controller: _field3Controller,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: widget.isMother ? 'Alamat' : 'Jenis Kelamin',
                hintText: widget.isMother ? 'Alamat domisili' : 'Laki-laki / Perempuan',
                controller: _field4Controller,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Simpan Perubahan',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
