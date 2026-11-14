import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/app_providers.dart';
import '../profile/child_profile_setup_screen.dart';
import '../shell/main_shell_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _childNameController = TextEditingController();

  String? _nameError;
  String? _childNameError;
  String? _emailError;
  String? _passwordError;
  String? _serverError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _childNameController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      _nameError = null;
      _childNameError = null;
      _emailError = null;
      _passwordError = null;
      _serverError = null;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final childName = _childNameController.text.trim();

    bool hasError = false;
    if (name.isEmpty) {
      _nameError = 'Nama ibu wajib diisi';
      hasError = true;
    }
    if (childName.isEmpty) {
      _childNameError = 'Nama anak wajib diisi';
      hasError = true;
    }
    if (email.isEmpty || !email.contains('@')) {
      _emailError = 'Format email tidak valid';
      hasError = true;
    }
    if (password.length < 6) {
      _passwordError = 'Password minimal 6 karakter';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() => _isLoading = true);

    final authProv = ref.read(authProvider);
    final result = await authProv.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      childName: childName,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      await ref.read(profileProvider).loadProfiles();
      if (!mounted) return;
      await ref.read(reminderProvider).loadReminders();
      if (!mounted) return;

      final navigator = Navigator.of(context);
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
        (route) => false,
      );
      navigator.push(
        MaterialPageRoute(
          builder: (_) =>
              const ChildProfileSetupScreen(isPostRegistration: true),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _serverError = result['message'] as String? ?? 'Pendaftaran gagal.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Daftar Akun'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.xs,
            AppSpacing.pageGutter,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Satu akun untuk memantau tumbuh kembang anak.',
                style: AppTypography.bodySecondary.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: AppSpacing.lg),

              if (_serverError != null) ...[
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
                        size: 20,
                        color: AppColors.accentRed,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _serverError!,
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

              _FieldGroupLabel('Data orang tua'),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Nama Ibu',
                hintText: 'Masukkan nama lengkap Ibu',
                controller: _nameController,
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Nomor HP',
                hintText: 'Contoh: 0812xxxxxxxx',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Email',
                hintText: 'Masukkan alamat email aktif',
                controller: _emailController,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Password',
                hintText: 'Minimal 6 karakter',
                controller: _passwordController,
                errorText: _passwordError,
                isPassword: true,
                onChanged: (_) {
                  if (_passwordError != null) {
                    setState(() => _passwordError = null);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.lg),
              _FieldGroupLabel('Data anak'),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Nama Anak',
                hintText: 'Masukkan nama panggilan / lengkap anak',
                controller: _childNameController,
                errorText: _childNameError,
                onChanged: (_) {
                  if (_childNameError != null) {
                    setState(() => _childNameError = null);
                  }
                },
              ),

              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: 'Daftar & Mulai Skrining',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun?',
                    style: AppTypography.bodySecondary.copyWith(fontSize: 14.5),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Masuk'),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Data disimpan di perangkat ini dan tidak dipakai untuk diagnosis.',
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

class _FieldGroupLabel extends StatelessWidget {
  final String text;

  const _FieldGroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        style: AppTypography.overline.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
