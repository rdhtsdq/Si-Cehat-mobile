import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:si_cehat_mobile/core/theme/app_theme.dart';
import 'package:si_cehat_mobile/screens/shell/main_shell_screen.dart';
import 'package:si_cehat_mobile/screens/screening/screening_step1_screen.dart';
import 'package:si_cehat_mobile/screens/screening/screening_result_screen.dart';
import 'package:si_cehat_mobile/screens/menu/menu_catalog_screen.dart';
import 'package:si_cehat_mobile/screens/reminder/reminder_screen.dart';

Widget createTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

void main() {
  testWidgets('S05 Beranda renders risk meter default & 5 main menus', (tester) async {
    await tester.pumpWidget(createTestApp(const MainShellScreen()));
    await tester.pumpAndSettle();

    // Verify Mother greeting
    expect(find.textContaining('Halo, Ibu Rina!'), findsOneWidget);

    // Verify Default Safety Risk Meter (NOT false low risk!)
    expect(find.text('Skrining belum tersedia'), findsOneWidget);

    // Verify 5 main menus from PDF
    expect(find.text('Skrining'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Reminder'), findsOneWidget);
    expect(find.text('Konsultasi'), findsOneWidget);
    expect(find.text('Komunitas'), findsOneWidget);

    // Verify 4 bottom navigation items
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Tracker'), findsOneWidget);
    expect(find.text('Edukasi'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('S11 Tracker tab displays BB Chart & last values', (tester) async {
    await tester.pumpWidget(createTestApp(const MainShellScreen(initialIndex: 1)));
    await tester.pumpAndSettle();

    // Verify tab buttons
    expect(find.text('Tumbuh Kembang'), findsOneWidget);
    expect(find.text('Aktivitas'), findsOneWidget);

    // Verify BB chart heading & CTA
    expect(find.text('Grafik BB (Kg)'), findsOneWidget);
    expect(find.text('+ Tambah Pengukuran'), findsOneWidget);
  });

  testWidgets('S12 Menu Tradisional lists traditional dishes', (tester) async {
    await tester.pumpWidget(createTestApp(const MenuCatalogScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Menu Tradisional Sehat'), findsOneWidget);
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Sayur Asem'), findsOneWidget);
    expect(find.text('Pepes Ikan'), findsOneWidget);
    expect(find.text('Nasi Tutuk Oncom'), findsOneWidget);
  });

  testWidgets('S14 Reminder lists scheduled tasks with toggle switches', (tester) async {
    await tester.pumpWidget(createTestApp(const ReminderScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Reminder'), findsOneWidget);
    expect(find.text('Tambah Reminder'), findsOneWidget);
    expect(find.text('Sarapan Pagi'), findsOneWidget);
    expect(find.text('Minum air putih'), findsOneWidget);
  });

  testWidgets('S09 & S10 Screening flow includes simulation disclaimer', (tester) async {
    await tester.pumpWidget(createTestApp(const ScreeningStep1Screen()));
    await tester.pumpAndSettle();

    expect(find.text('Skrining Risiko Diabetes'), findsOneWidget);
    expect(find.text('Langkah 1 dari 3'), findsOneWidget);
    expect(find.text('Usia Anak (Tahun)'), findsOneWidget);

    // Directly test S10 simulation result
    await tester.pumpWidget(createTestApp(const ScreeningResultScreen()));
    await tester.pumpAndSettle();

    expect(find.text('50%'), findsOneWidget);
    expect(find.textContaining('SIMULASI'), findsOneWidget);
    expect(find.textContaining('Perbanyak sayur & buah'), findsOneWidget);
    expect(find.text('Selanjutnya'), findsOneWidget);
  });
}
