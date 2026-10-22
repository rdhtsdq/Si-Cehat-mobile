import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/child_model.dart';
import '../../providers/app_providers.dart';
import '../screening/screening_step1_screen.dart';

class ChildProfileSetupScreen extends ConsumerStatefulWidget {
  final bool isPostRegistration;
  final VoidCallback? onCompleted;
  final ChildModel? initialChild;

  const ChildProfileSetupScreen({
    super.key,
    this.isPostRegistration = false,
    this.onCompleted,
    this.initialChild,
  });

  @override
  ConsumerState<ChildProfileSetupScreen> createState() =>
      _ChildProfileSetupScreenState();
}

class _ChildProfileSetupScreenState extends ConsumerState<ChildProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedGender = 'Laki-laki';

  String? _nameError;
  String? _dobError;
  bool _isSaving = false;
  int? _calculatedAge;

  @override
  void initState() {
    super.initState();
    final profileProv = ref.read(profileProvider);
    final targetChild = widget.initialChild ?? profileProv.activeChild;

    if (targetChild != null) {
      _nameController.text = targetChild.name;
      _dobController.text = targetChild.dateOfBirth;
      _selectedGender = targetChild.gender.isNotEmpty
          ? targetChild.gender
          : 'Laki-laki';
      _notesController.text = targetChild.healthNotes;
      if (targetChild.dateOfBirth.isNotEmpty) {
        _updateCalculatedAge(targetChild.dateOfBirth);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateCalculatedAge(String dobStr) {
    try {
      final dob = DateTime.parse(dobStr);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      setState(() {
        _calculatedAge = age.clamp(1, 18);
      });
    } catch (_) {
      setState(() {
        _calculatedAge = null;
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    DateTime initialDate = DateTime(now.year - 7, now.month, now.day);
    if (_dobController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_dobController.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 18),
      lastDate: now,
      helpText: 'PILIH TANGGAL LAHIR ANAK',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _dobController.text = formatted;
        _dobError = null;
      });
      _updateCalculatedAge(formatted);
    }
  }

  void _addQuickNote(String note) {
    final current = _notesController.text.trim();
    if (current.isEmpty) {
      _notesController.text = note;
    } else if (!current.contains(note)) {
      _notesController.text = '$current, $note';
    }
  }

  Future<void> _handleSaveAndProceed() async {
    final name = _nameController.text.trim();
    final dob = _dobController.text.trim();
    final notes = _notesController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'Nama anak wajib diisi' : null;
      _dobError = dob.isEmpty ? 'Tanggal lahir anak wajib diisi' : null;
    });

    if (_nameError != null || _dobError != null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final profileProv = ref.read(profileProvider);
      final existingChild = widget.initialChild ?? profileProv.activeChild;

      final hasExistingId = existingChild != null &&
          existingChild.id != null &&
          existingChild.id != 0 &&
          existingChild.id.toString() != '0' &&
          existingChild.id.toString().isNotEmpty;

      if (hasExistingId) {
        final updated = existingChild.copyWith(
          name: name,
          dateOfBirth: dob,
          gender: _selectedGender,
          healthNotes: notes,
        );
        await profileProv.updateChild(updated);
      } else {
        final newChild = ChildModel(
          id: 0,
          name: name,
          dateOfBirth: dob,
          gender: _selectedGender,
          healthNotes: notes,
          isActive: true,
        );
        await profileProv.addChild(newChild);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil anak berhasil disimpan! Melanjutkan ke skrining...'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.primaryGreenDark,
        ),
      );

      if (widget.onCompleted != null) {
        widget.onCompleted!();
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ScreeningStep1Screen(
              isPostRegistration: widget.isPostRegistration,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.chevron_left,
                  size: 28,
                  color: AppColors.textDark,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          'Lengkapi Profil Anak',
          style: AppTypography.headingScreen.copyWith(fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step Progress Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.veryLightGreen,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.assignment_ind,
                      size: 16,
                      color: AppColors.primaryGreenDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Langkah 1 dari 2: Profil & Riwayat Anak',
                      style: AppTypography.badgeText.copyWith(
                        color: AppColors.primaryGreenDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Data Anak Sebelum Skrining',
                style: AppTypography.headingScreen.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Data tanggal lahir & jenis kelamin sangat penting agar acuan kurva gizi WHO dan analisis risiko diabetes anak Anda akurat.',
                style: AppTypography.bodySecondary.copyWith(height: 1.4),
              ),
              const SizedBox(height: 24),

              // Form: Nama Anak
              AppTextField(
                label: 'Nama Lengkap Anak *',
                hintText: 'cth: Ahmad Farhan',
                controller: _nameController,
                errorText: _nameError,
              ),
              const SizedBox(height: 18),

              // Form: Jenis Kelamin
              Text(
                'Jenis Kelamin *',
                style: AppTypography.titleCard.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderCard(
                      label: 'Laki-laki',
                      icon: Icons.male,
                      isSelected: _selectedGender == 'Laki-laki',
                      onTap: () {
                        setState(() => _selectedGender = 'Laki-laki');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderCard(
                      label: 'Perempuan',
                      icon: Icons.female,
                      isSelected: _selectedGender == 'Perempuan',
                      onTap: () {
                        setState(() => _selectedGender = 'Perempuan');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Form: Tanggal Lahir
              Text(
                'Tanggal Lahir Anak *',
                style: AppTypography.titleCard.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickBirthDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _dobError != null
                          ? Colors.red
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dobController.text.isNotEmpty
                              ? _dobController.text
                              : 'Pilih tanggal lahir (YYYY-MM-DD)',
                          style: TextStyle(
                            fontSize: 14,
                            color: _dobController.text.isNotEmpty
                                ? AppColors.textDark
                                : AppColors.textSecondary,
                            fontWeight: _dobController.text.isNotEmpty
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (_calculatedAge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.veryLightGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$_calculatedAge Tahun',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreenDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_dobError != null) ...[
                const SizedBox(height: 4),
                Text(
                  _dobError!,
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                ),
              ],
              const SizedBox(height: 18),

              // Form: Riwayat Kesehatan / Catatan
              Text(
                'Riwayat Kesehatan / Penyakit Keluarga',
                style: AppTypography.titleCard.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Opsional. Tuliskan jika ada riwayat diabetes pada orang tua/kakek, alergi, atau riwayat kelahiran.',
                style: AppTypography.bodySecondary.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'cth: Riwayat diabetes tipe-2 pada kakek pihak ibu',
                  hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  filled: true,
                  fillColor: AppColors.fieldBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Quick suggestion chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildQuickChip('Riwayat diabetes keluarga'),
                  _buildQuickChip('Alergi makanan / susu'),
                  _buildQuickChip('Lahir prematur'),
                  _buildQuickChip('Tidak ada riwayat khusus'),
                ],
              ),
              const SizedBox(height: 32),

              // CTA Submit Button
              PrimaryButton(
                text: 'Simpan & Lanjut ke Skrining',
                isLoading: _isSaving,
                icon: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                onPressed: _isSaving ? null : _handleSaveAndProceed,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.veryLightGreen : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primaryGreenDark : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primaryGreenDark : AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return ActionChip(
      label: Text(
        '+ $label',
        style: const TextStyle(fontSize: 11, color: AppColors.primaryGreenDark),
      ),
      backgroundColor: AppColors.veryLightGreen,
      side: BorderSide(color: AppColors.lightGreen.withValues(alpha: 0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      onPressed: () => _addQuickNote(label),
    );
  }
}
