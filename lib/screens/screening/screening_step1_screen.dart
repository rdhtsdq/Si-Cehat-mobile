import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/profile_provider.dart';
import '../../providers/tracker_provider.dart';
import 'screening_result_screen.dart';

class ScreeningStep1Screen extends StatefulWidget {
  final bool isPostRegistration;

  const ScreeningStep1Screen({super.key, this.isPostRegistration = false});

  @override
  State<ScreeningStep1Screen> createState() => _ScreeningStep1ScreenState();
}

class _ScreeningStep1ScreenState extends State<ScreeningStep1Screen> {
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
    final child = context.read<ProfileProvider>().activeChild;
    if (child != null && child.dateOfBirth.isNotEmpty) {
      _selectedAge = child.ageInYears.clamp(1, 18);
    }
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTypography.titleCard),
              const SizedBox(height: 16),
              Text(
                '${tempVal.toStringAsFixed(unit == 'Tahun' ? 0 : 1)} $unit',
                style: AppTypography.headingScreen.copyWith(
                  color: AppColors.primaryGreenDark,
                  fontSize: 30,
                ),
              ),
              Slider(
                value: tempVal,
                min: min,
                max: max,
                divisions: (max - min).toInt() * (unit == 'Tahun' ? 1 : 2),
                activeColor: AppColors.primaryGreen,
                onChanged: (val) {
                  setModalState(() => tempVal = val);
                },
              ),
              const SizedBox(height: 16),
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final profileProv = context.read<ProfileProvider>();
    var child = profileProv.activeChild;
    if (child == null) {
      await profileProv.loadProfiles();
      child = profileProv.activeChild;
    }

    if (child == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Data profil anak belum ditemukan. Silakan tambahkan data anak di menu Profil.';
      });
      return;
    }

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
        context.read<TrackerProvider>().loadMeasurements(child.id);

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
    final activeChild = context.watch<ProfileProvider>().activeChild;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Skrining Risiko Diabetes',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isPostRegistration) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.veryLightGreen,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.celebration_outlined,
                        color: AppColors.primaryGreenDark,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Akun berhasil dibuat! Mari lakukan skrining awal untuk ${activeChild?.name ?? "anak Anda"} agar rekomendasi gizi lebih akurat.',
                          style: AppTypography.bodyRegular.copyWith(
                            fontSize: 13,
                            color: AppColors.primaryGreenDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              Text(
                activeChild != null
                    ? 'Data Awal Anak (${activeChild.name})'
                    : 'Data Awal Anak',
                style: AppTypography.titleCard.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Masukkan usia, berat badan, tinggi badan, dan kebiasaan harian anak untuk analisis risiko.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[800], fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
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
              const SizedBox(height: 16),

              _buildSelectorRow(
                label: 'Berat Badan (Kg)',
                value: '${_selectedWeight.toStringAsFixed(1)} Kg',
                onTap: () {
                  _showNumericPicker(
                    title: 'Pilih Berat Badan Anak',
                    initialValue: _selectedWeight,
                    min: 8,
                    max: 90,
                    unit: 'Kg',
                    onSelected: (val) => setState(() => _selectedWeight = val),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildSelectorRow(
                label: 'Tinggi Badan (Cm)',
                value: '${_selectedHeight.toStringAsFixed(0)} Cm',
                onTap: () {
                  _showNumericPicker(
                    title: 'Pilih Tinggi Badan Anak',
                    initialValue: _selectedHeight,
                    min: 60,
                    max: 185,
                    unit: 'Cm',
                    onSelected: (val) => setState(() => _selectedHeight = val),
                  );
                },
              ),
              const SizedBox(height: 20),

              Text(
                'Riwayat Diabetes Keluarga',
                style: AppTypography.labelInput.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const SizedBox(
                        width: double.infinity,
                        child: Text('Tidak Ada', textAlign: TextAlign.center),
                      ),
                      selected: !_familyHistory,
                      selectedColor: AppColors.veryLightGreen,
                      onSelected: (_) => setState(() => _familyHistory = false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const SizedBox(
                        width: double.infinity,
                        child: Text('Ada Riwayat', textAlign: TextAlign.center),
                      ),
                      selected: _familyHistory,
                      selectedColor: AppColors.veryLightGreen,
                      onSelected: (_) => setState(() => _familyHistory = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Frekuensi Minuman Manis / Kemasan',
                style: AppTypography.labelInput.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final entry in const [
                    ('jarang', 'Jarang'),
                    ('kadang', 'Kadang'),
                    ('sering', 'Sering'),
                  ])
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: entry.$1 == 'sering' ? 0 : 8,
                        ),
                        child: ChoiceChip(
                          label: SizedBox(
                            width: double.infinity,
                            child: Text(entry.$2, textAlign: TextAlign.center),
                          ),
                          selected: _sweetDrinkFrequency == entry.$1,
                          selectedColor: AppColors.veryLightGreen,
                          onSelected: (_) =>
                              setState(() => _sweetDrinkFrequency = entry.$1),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Aktivitas Fisik / Bermain Aktif Harian',
                style: AppTypography.labelInput.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const SizedBox(
                        width: double.infinity,
                        child: Text('< 45 Menit', textAlign: TextAlign.center),
                      ),
                      selected: _physicalActivityHours < 0.75,
                      selectedColor: AppColors.veryLightGreen,
                      onSelected: (_) =>
                          setState(() => _physicalActivityHours = 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const SizedBox(
                        width: double.infinity,
                        child: Text('≥ 60 Menit', textAlign: TextAlign.center),
                      ),
                      selected: _physicalActivityHours >= 0.75,
                      selectedColor: AppColors.veryLightGreen,
                      onSelected: (_) =>
                          setState(() => _physicalActivityHours = 1.0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              PrimaryButton(
                text: 'Analisis Risiko Diabetes',
                isLoading: _isLoading,
                onPressed: _handleCalculate,
              ),
              const SizedBox(height: 16),
            ],
          ),
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
        Text(label, style: AppTypography.labelInput.copyWith(fontSize: 14)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: AppTypography.bodyRegular.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
