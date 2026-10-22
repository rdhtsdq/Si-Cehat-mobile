import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
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
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _identifierError;
  String? _passwordError;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _identifierError = identifier.isEmpty
          ? 'Email atau No. HP wajib diisi'
          : null;
      _passwordError = password.isEmpty ? 'Password wajib diisi' : null;
      _errorMessage = null;
    });

    if (_identifierError != null || _passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    final authProv = context.read<AuthProvider>();
    final result = await authProv.login(
      identifier: identifier,
      password: password,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final profileProv = context.read<ProfileProvider>();
      profileProv.clearSession();
      await profileProv.loadProfiles();
      if (!mounted) return;
      await context.read<ReminderProvider>().loadReminders();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result['message'] as String? ??
            'Gagal masuk. Periksa email & password Anda.';
      });
    }
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
              const SizedBox(height: 24),
              Text(
                'Selamat Datang\nKembali!',
                textAlign: TextAlign.center,
                style: AppTypography.headingLogin,
              ),
              const SizedBox(height: 8),
              Text(
                'Masuk ke akun orang tua untuk memantau tumbuh kembang & gizi anak',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

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
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              AppTextField(
                label: 'Email / No. HP',
                hintText: 'Masukkan email atau nomor HP',
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                errorText: _identifierError,
                onChanged: (_) {
                  if (_identifierError != null) {
                    setState(() => _identifierError = null);
                  }
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Password',
                hintText: 'Masukkan password Anda',
                controller: _passwordController,
                isPassword: true,
                errorText: _passwordError,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
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
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Masuk',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: 36),

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
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
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
