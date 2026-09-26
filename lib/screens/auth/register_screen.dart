import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/safety_banner.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../shell/main_shell_screen.dart';
import 'privacy_sheet.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController(text: 'Ibu Rina');
  final _phoneController = TextEditingController(text: '081234567890');
  final _emailController = TextEditingController(text: 'rina@example.com');
  final _passwordController = TextEditingController(text: 'Password123!');

  String? _nameError;

  void _handleRegister() {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _nameError = 'Nama ibu wajib diisi';
      });
      return;
    }

    final profileProv = context.read<ProfileProvider>();
    if (profileProv.mother != null) {
      profileProv.updateMother(
        profileProv.mother!.copyWith(name: _nameController.text.trim()),
      );
    }

    context.read<AuthProvider>().loginDemo(
          identifier: _emailController.text,
          password: _passwordController.text,
        );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Judul center "Daftar Akun"
              Text(
                'Daftar Akun',
                textAlign: TextAlign.center,
                style: AppTypography.headingLogin.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 6),
              // Subjudul "Isi data berikut"
              Text(
                'Isi data berikut',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),

              const SafetyBanner(
                text: 'Mode Demo: Pendaftaran akun disimulasikan secara lokal untuk kemudahan eksplorasi.',
                type: BannerType.demo,
              ),

              // 4 Field berurutan sesuai PDF
              AppTextField(
                hintText: 'Nama Ibu',
                controller: _nameController,
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                hintText: 'No. HP',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                hintText: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AppTextField(
                hintText: 'Password',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              // Tautan Privasi & Kebijakan
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (_) => const PrivacyConsentSheet(),
                  );
                },
                child: Text(
                  'Dengan mendaftar, Anda menyetujui Kebijakan Privasi & Ketentuan Layanan',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary.copyWith(
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Tombol hijau "Daftar"
              PrimaryButton(
                text: 'Daftar',
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
