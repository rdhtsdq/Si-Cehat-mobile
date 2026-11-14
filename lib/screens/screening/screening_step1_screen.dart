import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/calm_widgets.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/app_providers.dart';
import '../profile/child_profile_setup_screen.dart';
import 'screening_result_screen.dart';

class ScreeningStep1Screen extends ConsumerStatefulWidget {
  final bool isPostRegistration;

  const ScreeningStep1Screen({super.key, this.isPostRegistration = false});

  @override
  ConsumerState<ScreeningStep1Screen> createState() =>
      _ScreeningStep1ScreenState();
}

class _ScreeningStep1ScreenState extends ConsumerState<ScreeningStep1Screen> {
  int _selectedAge = 7;
  double _selectedWeight = 22.0;
  double _selectedHeight = 120.0;
  bool _familyHistory = false;
  String _sweetDrinkFrequency = 'jarang'; // jarang, kadang, sering
  double _physicalActivityHours = 1.0;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final child = ref.read(profileProvider).activeChild;
    if (child != null && child.dateOfBirth.isNotEmpty) {
      _selectedAge = child.ageInYears.clamp(1, 18);
    }
  }

  String _formatValue(double value, String unit) {
    final text = unit == 'Tahun'
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1).replaceAll('.', ',');
    return '$text $unit';
  }

  void _showNumericPicker({
    required String title,
    required double initialValue,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onSelected,
  }) {
    double tempVal = initialValue.clamp(min, max);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.lg + bottomInset,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.title.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _formatValue(tempVal, unit),
                style: AppTypography.display.copyWith(
                  fontSize: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Slider(
                value: tempVal,
                min: min,
                max: max,
                divisions:
                    (max - min).toInt() * (unit == 'Tahun' ? 1 : 2),
                onChanged: (val) => setModalState(() => tempVal = val),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatValue(min, unit),
                      style: AppTypography.caption,
                    ),
                    Text(
                      _formatValue(max, unit),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                text: 'Pilih Nilai Ini',
                onPressed: () {
                  onSelected(tempVal);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCalculate() async {
    final profileProv = ref.read(profileProvider);
    var child = profileProv.activeChild;
    if (child == null) {
      await profileProv.loadProfiles();
      child = profileProv.activeChild;
    }

    if (child == null || !child.isProfileComplete) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi profil anak terlebih dahulu.'),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChildProfileSetupScreen(
            isPostRegistration: widget.isPostRegistration,
            initialChild: child,
            onCompleted: () {
              setState(() {
                final updated = ref.read(profileProvider).activeChild;
                if (updated != null && updated.dateOfBirth.isNotEmpty) {
                  _selectedAge = updated.ageInYears.clamp(1, 18);
                }
              });
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiClient.instance.post(
        ApiConstants.screening,
        body: {
          'childId': child.id.toString(),
          'ageYears': _selectedAge,
          'weightKg': _selectedWeight,
          'heightCm': _selectedHeight,
          'familyHistory': _familyHistory,
          'sweetDrinkFrequency': _sweetDrinkFrequency,
          'physicalActivityHours': _physicalActivityHours,
        },
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (res.isSuccess && res.data != null) {
        final d = res.data as Map<String, dynamic>;
        final score = (d['riskScore'] as num?)?.toInt() ?? 20;
        final cat = d['riskCategory'] as String? ?? 'RENDAH';
        final title = d['title'] as String?;
        final recs =
            (d['recommendations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        profileProv.updateLatestScreening(category: cat, score: score);
        ref.read(trackerProvider).loadMeasurements(child.id);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ScreeningResultScreen(
              score: score,
              category: cat,
              statusText: title,
              recommendations: recs,
              isRealResult: true,
            ),
          ),
        );
        return;
      } else {
        setState(() {
          _errorMessage =
              res.errorMessage ?? 'Gagal memproses skrining ke server.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan jaringan saat memproses skrining.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeChild = ref.watch(profileProvider).activeChild;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          AppHeader(
            compact: true,
            title: 'Skrining Risiko Diabetes',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                AppSpacing.md,
                AppSpacing.pageGutter,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StepProgress(current: 1, total: 3),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    activeChild != null
                        ? 'Data Awal Anak (${activeChild.name})'
                        : 'Data Awal Anak',
                    style: AppTypography.h2,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Masukkan usia, berat badan, tinggi badan, dan kebiasaan harian anak untuk analisis risiko.',
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (widget.isPostRegistration) ...[
                    MintSection(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const IconChip(
                            icon: Icons.celebration_outlined,
                            size: 32,
                            circle: true,
                            background: AppColors.surface,
                            foreground: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'Akun berhasil dibuat! Mari lakukan skrining awal untuk ${activeChild?.name ?? "anak Anda"} agar rekomendasi gizi lebih akurat.',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (activeChild == null ||
                      !activeChild.isProfileComplete) ...[
                    AppCard(
                      color: AppColors.warningBg,
                      borderColor: AppColors.warning,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const IconChip(
                                icon: Icons.info_outline_rounded,
                                size: 32,
                                circle: true,
                                background: AppColors.surface,
                                foreground: AppColors.chipPeachFg,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Profil Anak Belum Lengkap',
                                  style: AppTypography.title.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Lengkapi tanggal lahir dan jenis kelamin anak agar skrining dan kurva pertumbuhan akurat.',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppPillButton(
                            label: 'Lengkapi Profil Sekarang',
                            icon: Icons.edit_note_rounded,
                            height: 40,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChildProfileSetupScreen(
                                    isPostRegistration:
                                        widget.isPostRegistration,
                                    initialChild: activeChild,
                                    onCompleted: () {
                                      setState(() {
                                        final updated = ref
                                            .read(profileProvider)
                                            .activeChild;
                                        if (updated != null &&
                                            updated.dateOfBirth.isNotEmpty) {
                                          _selectedAge = updated.ageInYears
                                              .clamp(1, 18);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (_errorMessage != null) ...[
                    AppCard(
                      color: AppColors.dangerBg,
                      borderColor: AppColors.riskHighBorder,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: AppColors.dangerText,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.dangerText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  _buildSelectorRow(
                    label: 'Usia Anak (Tahun)',
                    value: '$_selectedAge Tahun',
                    onTap: () {
                      _showNumericPicker(
                        title: 'Pilih Usia Anak',
                        initialValue: _selectedAge.toDouble(),
                        min: 1,
                        max: 18,
                        unit: 'Tahun',
                        onSelected: (val) =>
                            setState(() => _selectedAge = val.toInt()),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSelectorRow(
                    label: 'Berat Badan (Kg)',
                    value: _formatValue(_selectedWeight, 'Kg'),
                    onTap: () {
                      _showNumericPicker(
                        title: 'Pilih Berat Badan Anak',
                        initialValue: _selectedWeight,
                        min: 8,
                        max: 90,
                        unit: 'Kg',
                        onSelected: (val) =>
                            setState(() => _selectedWeight = val),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildSelectorRow(
                    label: 'Tinggi Badan (Cm)',
                    value: _formatValue(_selectedHeight, 'Cm'),
                    onTap: () {
                      _showNumericPicker(
                        title: 'Pilih Tinggi Badan Anak',
                        initialValue: _selectedHeight,
                        min: 60,
                        max: 185,
                        unit: 'Cm',
                        onSelected: (val) =>
                            setState(() => _selectedHeight = val),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Riwayat Diabetes Keluarga',
                    style: AppTypography.formLabel.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ChoiceChipGroup(
                    options: const ['Tidak Ada', 'Ada Riwayat'],
                    selected: _familyHistory ? 'Ada Riwayat' : 'Tidak Ada',
                    onSelected: (value) => setState(
                      () => _familyHistory = value == 'Ada Riwayat',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Frekuensi Minuman Manis / Kemasan',
                    style: AppTypography.formLabel.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ChoiceChipGroup(
                    options: const ['Jarang', 'Kadang', 'Sering'],
                    selected: switch (_sweetDrinkFrequency) {
                      'sering' => 'Sering',
                      'kadang' => 'Kadang',
                      _ => 'Jarang',
                    },
                    onSelected: (value) => setState(
                      () => _sweetDrinkFrequency = switch (value) {
                        'Sering' => 'sering',
                        'Kadang' => 'kadang',
                        _ => 'jarang',
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Aktivitas Fisik / Bermain Aktif Harian',
                    style: AppTypography.formLabel.copyWith(
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ChoiceChipGroup(
                    options: const ['< 45 Menit', '≥ 60 Menit'],
                    selected: _physicalActivityHours < 0.75
                        ? '< 45 Menit'
                        : '≥ 60 Menit',
                    onSelected: (value) => setState(
                      () => _physicalActivityHours =
                          value == '< 45 Menit' ? 0.5 : 1.0,
                    ),
                  ),
                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: AppColors.bg,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.xs,
          AppSpacing.pageGutter,
          AppSpacing.sm + MediaQuery.paddingOf(context).bottom,
        ),
        child: PrimaryButton(
          text: 'Analisis Risiko Diabetes',
          isLoading: _isLoading,
          onPressed: _handleCalculate,
        ),
      ),
    );
  }

  Widget _buildSelectorRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.formLabel.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 6),
        Semantics(
          button: true,
          label: '$label, $value',
          excludeSemantics: true,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.input,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(
                minHeight: AppSizes.fieldHeight,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.input,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.textInput.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.chevron,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
