import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/app_providers.dart';
import '../shell/main_shell_screen.dart';
import 'register_screen.dart';
import 'forgot_password_sheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
      _identifierError =
          identifier.isEmpty ? 'Email atau No. HP wajib diisi' : null;
      _passwordError = password.isEmpty ? 'Password wajib diisi' : null;
      _errorMessage = null;
    });

    if (_identifierError != null || _passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    final authProv = ref.read(authProvider);
    final result = await authProv.login(
      identifier: identifier,
      password: password,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final profileProv = ref.read(profileProvider);
      profileProv.clearSession();
      await profileProv.loadProfiles();
      if (!mounted) return;
      await ref.read(reminderProvider).loadReminders();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result['message'] as String? ??
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.xl,
            AppSpacing.pageGutter,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.veryLightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.family_restroom_rounded,
                    size: 34,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Selamat Datang\nKembali!',
                textAlign: TextAlign.center,
                style: AppTypography.headingLogin,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Masuk ke akun orang tua untuk memantau tumbuh kembang & gizi anak.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: AppSpacing.xxl),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.accentRed.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.accentRed,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.bodySecondary.copyWith(
                            color: AppColors.accentRed,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.md),

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
              const SizedBox(height: AppSpacing.xs),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => const ForgotPasswordSheet(),
                    );
                  },
                  child: const Text('Lupa Password?'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              PrimaryButton(
                text: 'Masuk',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),

              const SizedBox(height: AppSpacing.xl),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Belum punya akun?',
                    style: AppTypography.bodySecondary.copyWith(fontSize: 14.5),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Daftar'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Data anak disimpan di perangkat ini. Bukan alat diagnosis.',
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
