import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/reminder_provider.dart';
import '../profile/child_profile_setup_screen.dart';
import '../shell/main_shell_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

    final authProv = context.read<AuthProvider>();
    final result = await authProv.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      childName: childName,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      await context.read<ProfileProvider>().loadProfiles();
      if (!mounted) return;
      await context.read<ReminderProvider>().loadReminders();
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 28,
            color: AppColors.textDark,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Daftar Akun',
                textAlign: TextAlign.center,
                style: AppTypography.headingLogin.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 6),
              Text(
                'Lengkapi data untuk pendampingan keluarga',
                textAlign: TextAlign.center,
                style: AppTypography.bodySecondary.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),

              if (_serverError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    _serverError!,
                    style: TextStyle(color: Colors.red[800], fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              AppTextField(
                label: 'Nama Ibu',
                hintText: 'Masukkan nama lengkap Ibu',
                controller: _nameController,
                errorText: _nameError,
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Nama Anak',
                hintText: 'Masukkan nama panggilan / lengkap anak',
                controller: _childNameController,
                errorText: _childNameError,
                onChanged: (_) {
                  if (_childNameError != null)
                    setState(() => _childNameError = null);
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Nomor HP',
                hintText: 'Contoh: 0812xxxxxxxx',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Email',
                hintText: 'Masukkan alamat email aktif',
                controller: _emailController,
                errorText: _emailError,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Password',
                hintText: 'Minimal 6 karakter',
                controller: _passwordController,
                errorText: _passwordError,
                isPassword: true,
                onChanged: (_) {
                  if (_passwordError != null)
                    setState(() => _passwordError = null);
                },
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Daftar & Mulai Skrining',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: AppTypography.bodySecondary.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'Masuk',
                      style: AppTypography.bodySecondary.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
