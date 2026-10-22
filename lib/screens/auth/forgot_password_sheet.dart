import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/safety_banner.dart';

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _identifierController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
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
                'Pemulihan Password',
                style: AppTypography.titleCard.copyWith(fontSize: 18),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SafetyBanner(
            text: 'Pada mode demo, pemulihan akun disimulasikan secara lokal tanpa pengiriman SMS/Email.',
            type: BannerType.demo,
          ),
          if (!_submitted) ...[
            Text(
              'Masukkan email atau nomor HP yang terdaftar untuk menerima instruksi pemulihan kata sandi.',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 16),
            AppTextField(
              hintText: 'Email / No. HP',
              controller: _identifierController,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Kirim Instruksi',
              onPressed: () {
                setState(() {
                  _submitted = true;
                });
              },
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.veryLightGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Instruksi Terkirim (Simulasi)',
                    style: AppTypography.titleCard.copyWith(color: AppColors.primaryGreenDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Jika akun terdaftar, petunjuk pengaturan ulang kata sandi telah dikirimkan.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Selesai',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ],
      ),
    );
  }
}
