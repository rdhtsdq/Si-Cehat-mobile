import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/colors.dart';
import '../../data/models/nutrition_model.dart';
import '../../providers/app_providers.dart';

/// Shared "photo → AI analysis → save to diary" flow, used by both the Home
/// shortcut and the Nutrition Calculator.
Future<void> runPhotoAnalysis(
  BuildContext context,
  WidgetRef ref, {
  String? childId,
  String? date,
}) async {
  final id = childId ?? _activeChildId(ref);
  if (id == null || id.isEmpty) {
    _showSnack(context, 'Pilih profil anak terlebih dahulu.');
    return;
  }

  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_rounded),
            title: const Text('Ambil Foto'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_rounded),
            title: const Text('Pilih dari Galeri'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) return;

  final XFile? file = await ImagePicker().pickImage(
    source: source,
    maxWidth: 1280,
    imageQuality: 70,
  );
  if (file == null) return;

  final bytes = await file.readAsBytes();
  if (!context.mounted) return;

  final provider = ref.read(nutritionProvider);
  final result = await _withAnalyzingDialog(
    context,
    () => provider.analyzePhoto(base64Encode(bytes), id),
  );

  if (!context.mounted) return;
  if (result == null) {
    _showSnack(
      context,
      'Gagal menganalisis foto. Coba lagi atau gunakan input manual.',
    );
    return;
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => PhotoResultSheet(
      result: result,
      onSave: (mealSlot) async {
        final saved = await ref
            .read(nutritionProvider)
            .savePhotoResultToDiary(
              childId: id,
              date: date ?? _todayString(),
              mealSlot: mealSlot,
              items: result.items,
            );
        if (!context.mounted) return;
        _showSnack(
          context,
          saved
              ? 'Asupan dari foto disimpan ke diary.'
              : 'Gagal menyimpan ke diary.',
        );
      },
    ),
  );
}

/// Runs [task] behind a non-dismissible "analyzing" dialog so the user gets
/// immediate feedback between capturing a photo and receiving the AI result.
Future<T> _withAnalyzingDialog<T>(
  BuildContext context,
  Future<T> Function() task,
) async {
  var dialogVisible = true;
  final dialogFuture = showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (_) => const _AnalyzingPhotoDialog(),
  ).whenComplete(() => dialogVisible = false);

  try {
    return await task();
  } finally {
    if (dialogVisible && context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    await dialogFuture;
  }
}

class _AnalyzingPhotoDialog extends StatelessWidget {
  const _AnalyzingPhotoDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Menganalisis foto...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AI sedang memperkirakan asupan gizi. Mohon tunggu sebentar.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String? _activeChildId(WidgetRef ref) {
  return ref.read(profileProvider).activeChild?.id?.toString();
}

String _todayString() {
  final now = DateTime.now();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '${now.year}-$m-$d';
}

void _showSnack(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

/// Bottom sheet showing the AI analysis result with a save-to-diary action.
class PhotoResultSheet extends StatefulWidget {
  final PhotoAnalysisResult result;
  final Future<void> Function(String mealSlot) onSave;

  const PhotoResultSheet({
    super.key,
    required this.result,
    required this.onSave,
  });

  @override
  State<PhotoResultSheet> createState() => _PhotoResultSheetState();
}

class _PhotoResultSheetState extends State<PhotoResultSheet> {
  String _mealSlot = 'sarapan';
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    await widget.onSave(_mealSlot);
    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Hasil Analisis Foto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const Text(
            'Perkiraan dari foto, bukan nilai pasti gizi.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          if (result.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Tidak ada makanan terdeteksi.'),
            )
          else ...[
            ...result.items.map(
              (item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.restaurant_rounded,
                  color: AppColors.primary,
                ),
                title: Text(
                  item.foodName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${item.weightGram.toStringAsFixed(0)} g • '
                  '${item.values.caloriesKkal} kkal'
                  '${item.isEstimate ? ' (estimasi)' : ''}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            ),
            const Divider(),
            Text(
              'Total: ${result.totals.caloriesKkal} kkal • '
              'P ${result.totals.proteinGram}g • K ${result.totals.carbsGram}g',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            if (result.target != null)
              Text(
                'Target harian: ${result.target!.caloriesKkal} kkal (edukatif)',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _mealSlot,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                  ),
                  items: const ['sarapan', 'siang', 'camilan', 'malam']
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 12)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _mealSlot = v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: result.items.isEmpty || _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan ke Diary'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
