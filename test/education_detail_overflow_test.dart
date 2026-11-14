import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/core/theme/app_theme.dart';
import 'package:si_cehat_mobile/data/models/education_model.dart';
import 'package:si_cehat_mobile/screens/education/education_detail_screen.dart';

/// Regression: the video overlay actions and the metadata rows must not
/// overflow on a 360px screen with enlarged text.
void main() {
  testWidgets('video detail has no overflow at 360px + textScale 1.3', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    final item = EducationModel(
      id: 'v1',
      title: 'Mengenal Gizi Seimbang untuk Anak Usia Sekolah',
      type: 'video',
      duration: '10 Menit',
      summary:
          'Panduan singkat menyusun piring makan anak dengan gizi seimbang setiap hari.',
      contentBody:
          'Anak usia sekolah membutuhkan energi dan nutrisi yang cukup untuk tumbuh dan belajar.',
      speakerOrSource: 'Kemenkes RI & IDAI',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: EducationDetailScreen(item: item),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Putar Video'), findsOneWidget);
    expect(find.text('Buka YouTube'), findsOneWidget);
    expect(find.text(item.title), findsWidgets);

    // Play triggers the WebView path; in widget tests this falls back to the
    // error overlay, which must fit inside the 16:9 box.
    await tester.tap(find.text('Putar Video'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // The fallback overlay is visible and still fits.
    expect(find.textContaining('kesalahan pemutar'), findsOneWidget);
  });
}
