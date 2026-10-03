import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/safety_banner.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/reminder_provider.dart';
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
  final _passwordController = TextEditingController(text: 'PasswordSehat123!');
  bool _isLoading = false;
  String? _errorMessage;

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProv = context.read<AuthProvider>();
    final result = await authProv.login(
      identifier: _identifierController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      await context.read<ProfileProvider>().loadProfiles();
      if (!mounted) return;
      await context.read<ReminderProvider>().loadReminders();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] as String? ?? 'Gagal masuk. Periksa email & password Anda.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: Colors.red[700],
          action: SnackBarAction(
            label: 'Mode Demo',
            textColor: Colors.white,
            onPressed: _handleDemoLogin,
          ),
        ),
      );
    }
  }

  void _handleDemoLogin() async {
    setState(() => _isLoading = true);
    await context.read<AuthProvider>().loginDemo(
          identifier: _identifierController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    await context.read<ProfileProvider>().loadProfiles();
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

              // Banner Status Integrasi
              const SafetyBanner(
                text: 'Terhubung ke Backend Si-Cehat API. Masuk dengan akun terdaftar atau gunakan mode demo.',
                type: BannerType.demo,
              ),
              const SizedBox(height: 12),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[800], fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

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
                text: 'Masuk ke Akun',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 10),

              // Tombol alternatif "Masuk Mode Demo"
              OutlinedButton(
                onPressed: _handleDemoLogin,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryGreen),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'Masuk Mode Demo (Offline)',
                  style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                ),
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

              const SizedBox(height: 36),

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
