import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/profile_provider.dart';
import 'screening_demo_dialog.dart';
import 'screening_result_screen.dart';

class ScreeningStep1Screen extends StatefulWidget {
  const ScreeningStep1Screen({super.key});

  @override
  State<ScreeningStep1Screen> createState() => _ScreeningStep1ScreenState();
}

class _ScreeningStep1ScreenState extends State<ScreeningStep1Screen> {
  int _selectedAge = 8;
  double _selectedWeight = 25.0;
  double _selectedHeight = 120.0;

  @override
  void initState() {
    super.initState();
    final child = context.read<ProfileProvider>().activeChild;
    if (child != null) {
      _selectedAge = child.ageInYears;
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
    double tempVal = initialValue;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Skrining Risiko Diabetes',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teks kecil "Langkah 1 dari 3" sesuai PDF
              Text(
                'Langkah 1 dari 3',
                style: AppTypography.bodySecondary.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Kontrol dropdown / picker Usia Anak (Tahun)
              _buildSelectorRow(
                label: 'Usia Anak (Tahun)',
                value: '$_selectedAge',
                onTap: () {
                  _showNumericPicker(
                    title: 'Pilih Usia Anak',
                    initialValue: _selectedAge.toDouble(),
                    min: 5,
                    max: 15,
                    unit: 'Tahun',
                    onSelected: (val) => setState(() => _selectedAge = val.toInt()),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Kontrol dropdown / picker Berat Badan (Kg)
              _buildSelectorRow(
                label: 'Berat Badan (Kg)',
                value: _selectedWeight.toStringAsFixed(0),
                onTap: () {
                  _showNumericPicker(
                    title: 'Pilih Berat Badan Anak',
                    initialValue: _selectedWeight,
                    min: 15,
                    max: 60,
                    unit: 'Kg',
                    onSelected: (val) => setState(() => _selectedWeight = val),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Kontrol dropdown / picker Tinggi Badan (Cm)
              _buildSelectorRow(
                label: 'Tinggi Badan (Cm)',
                value: _selectedHeight.toStringAsFixed(0),
                onTap: () {
                  _showNumericPicker(
                    title: 'Pilih Tinggi Badan Anak',
                    initialValue: _selectedHeight,
                    min: 90,
                    max: 160,
                    unit: 'Cm',
                    onSelected: (val) => setState(() => _selectedHeight = val),
                  );
                },
              ),

              const Spacer(),

              // Tombol hijau lebar "Selanjutnya"
              PrimaryButton(
                text: 'Selanjutnya',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ScreeningDemoDialog(
                      onProceedToExample: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ScreeningResultScreen()),
                        );
                      },
                    ),
                  );
                },
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
        Text(
          label,
          style: AppTypography.labelInput.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 56),
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
                const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
