import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/primary_button.dart';
import '../../providers/app_providers.dart';

class CommunityCreatePostScreen extends ConsumerStatefulWidget {
  const CommunityCreatePostScreen({super.key});

  @override
  ConsumerState<CommunityCreatePostScreen> createState() =>
      _CommunityCreatePostScreenState();
}

class _CommunityCreatePostScreenState
    extends ConsumerState<CommunityCreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);

    final error = await ref.read(communityProvider).createPost(
          _titleController.text.trim(),
          _contentController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop(true);
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
          'Buat Postingan',
          style: AppTypography.headingScreen.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            children: [
              Text(
                'Bagikan tips atau pengalaman seputar gizi dan pola asuh anak dengan ibu-ibu lainnya.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 20),
              Text('Judul', style: AppTypography.formLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                maxLength: 120,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Contoh: Tips mengurangi jajanan manis',
                  hintStyle: AppTypography.bodySecondary,
                  filled: true,
                  fillColor: AppColors.fieldBackground,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.length < 8) return 'Judul minimal 8 karakter.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text('Isi', style: AppTypography.formLabel),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLength: 2000,
                minLines: 6,
                maxLines: 12,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Tulis pengalaman atau tips kamu di sini...',
                  hintStyle: AppTypography.bodySecondary,
                  filled: true,
                  fillColor: AppColors.fieldBackground,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.input,
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  final v = (value ?? '').trim();
                  if (v.length < 10) return 'Isi minimal 10 karakter.';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Kirim Postingan',
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
