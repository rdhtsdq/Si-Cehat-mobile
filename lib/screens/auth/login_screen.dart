import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/safety_banner.dart';
import '../../providers/auth_provider.dart';
import '../shell/main_shell_screen.dart';
import 'register_screen.dart';
import 'forgot_password_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController(text: 'ibu.rina@example.com');
  final _passwordController = TextEditingController(text: 'Password123!');
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    await context.read<AuthProvider>().loginDemo(
          identifier: _identifierController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              // Judul center besar dua baris "Selamat Datang / Kembali!"
              Text(
                'Selamat Datang\nKembali!',
                textAlign: TextAlign.center,
                style: AppTypography.headingLogin,
              ),
              const SizedBox(height: 24),

              // Banner Demo Transparan
              const SafetyBanner(
                text: 'Mode demo · tidak terhubung ke akun nyata. Masuk langsung menggunakan akun fiktif.',
                type: BannerType.demo,
              ),
              const SizedBox(height: 12),

              // Field "Email / No. HP"
              AppTextField(
                hintText: 'Email / No. HP',
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Field "Password"
              AppTextField(
                hintText: 'Password',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 24),

              // Tombol hijau lebar "Masuk"
              PrimaryButton(
                text: 'Masuk',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 12),

              // Teks "Lupa Password?" rata kanan
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => const ForgotPasswordSheet(),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Lupa Password?',
                    style: AppTypography.bodySecondary.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Bagian bawah: "Belum punya akun? Daftar"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun? ',
                    style: AppTypography.bodySecondary.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      'Daftar',
                      style: AppTypography.bodySecondary.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
