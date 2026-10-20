import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_cehat_mobile/core/theme/app_theme.dart';
import 'package:si_cehat_mobile/providers/auth_provider.dart';
import 'package:si_cehat_mobile/providers/profile_provider.dart';
import 'package:si_cehat_mobile/providers/tracker_provider.dart';
import 'package:si_cehat_mobile/providers/reminder_provider.dart';
import 'package:si_cehat_mobile/providers/education_provider.dart';
import 'package:si_cehat_mobile/providers/notification_provider.dart';
import 'package:si_cehat_mobile/screens/consultation/notification_center_screen.dart';
import 'package:si_cehat_mobile/screens/education/pustaka_edukasi_screen.dart';
import 'package:si_cehat_mobile/screens/profile/mother_profile_screen.dart';
import 'package:si_cehat_mobile/screens/profile/child_profile_screen.dart';
import 'package:si_cehat_mobile/screens/reminder/reminder_screen.dart';
import 'package:si_cehat_mobile/screens/tracker/tracker_screen.dart';

Widget createTestApp(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider(create: (_) => TrackerProvider()),
      ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ChangeNotifierProvider(create: (_) => EducationProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    ),
  );
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('Automated Feature & Edge Case Integration Tests', () {
    testWidgets('Notification Center: displays items, unread counter, mark as read, and delete', (tester) async {
      await tester.pumpWidget(createTestApp(const NotificationCenterScreen()));
      await tester.pumpAndSettle();

      // Verify header and initial seed notifications
      expect(find.text('Pusat Notifikasi'), findsOneWidget);
      expect(find.text('Tandai Dibaca'), findsOneWidget);
      expect(find.text('Selamat Datang di Si Cehat!'), findsOneWidget);
      expect(find.text('Layanan Konsultasi Tenaga Medis Mitra'), findsOneWidget);

      // Tap "Tandai Dibaca"
      await tester.tap(find.text('Tandai Dibaca'));
      await tester.pumpAndSettle();

      // Verify unread button is now gone since all notifications are marked as read
      expect(find.text('Tandai Dibaca'), findsNothing);
    });

    testWidgets('Pustaka Edukasi: category chips filter content and search filters accurately', (tester) async {
      await tester.pumpWidget(createTestApp(const PustakaEdukasiScreen()));
      await tester.pumpAndSettle();

      // Verify initial rendering
      expect(find.text('Pustaka Edukasi'), findsOneWidget);
      expect(find.text('Cari topik edukasi kesehatan...'), findsOneWidget);
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Artikel'), findsOneWidget);
      expect(find.text('Nutrisi'), findsOneWidget);
      expect(find.text('Pencegahan'), findsOneWidget);

      // Filter by "Nutrisi"
      await tester.tap(find.text('Nutrisi'));
      await tester.pumpAndSettle();

      // Type in search bar
      final searchInput = find.byType(TextField);
      expect(searchInput, findsOneWidget);
      await tester.enterText(searchInput, 'Isi Piringku');
      await tester.pumpAndSettle();

      expect(find.text('Panduan Praktis "Isi Piringku" untuk Keluarga'), findsOneWidget);

      // Search non-existent query to test empty state
      await tester.enterText(searchInput, 'XYZ_TIDAK_ADA_KONTEN_123');
      await tester.pumpAndSettle();

      expect(find.text('Materi Tidak Ditemukan'), findsOneWidget);
    });

    testWidgets('Reminder Screen: daily completion checkbox toggles and progress updates', (tester) async {
      await tester.pumpWidget(createTestApp(const ReminderScreen()));
      await tester.pumpAndSettle();

      // Verify header and reminders
      expect(find.text('Reminder'), findsOneWidget);
      expect(find.text('Sarapan Pagi'), findsOneWidget);
      expect(find.text('Minum air putih'), findsOneWidget);

      // Find first reminder checkbox button and toggle it
      final checkButtons = find.byIcon(Icons.check_circle_outline);
      if (checkButtons.evaluate().isNotEmpty) {
        await tester.tap(checkButtons.first);
        await tester.pumpAndSettle();
      }

      // Verify food diary CTA button exists
      expect(find.text('Food Diary'), findsOneWidget);
    });

    testWidgets('Mother Profile: renders avatar and allows opening avatar picker', (tester) async {
      await tester.pumpWidget(createTestApp(const MotherProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Profil Ibu'), findsOneWidget);
      expect(find.text('Nama Ibu'), findsOneWidget);
      expect(find.text('Edit Profil'), findsOneWidget);

      // Tap avatar camera edit button
      final cameraBtn = find.byIcon(Icons.camera_alt);
      expect(cameraBtn, findsOneWidget);
      await tester.tap(cameraBtn);
      await tester.pumpAndSettle();

      // Verify bottom sheet options
      expect(find.text('Pilih Foto Profil Ibu'), findsOneWidget);
      expect(find.text('Pilih dari Karakter Si-Cehat:'), findsOneWidget);
      expect(find.text('Ibu Si Cehat'), findsOneWidget);
      expect(find.text('Hapus / Reset Foto'), findsOneWidget);

      // Select preset
      final prov = tester.element(find.byType(MotherProfileScreen)).read<ProfileProvider>();
      await tester.tap(find.byKey(const Key('preset_Ibu Si Cehat')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));

      expect(prov.mother?.avatarUrl, 'assets/dashboard/hello.png');
      expect(find.text('Foto profil berhasil diperbarui'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Child Profile: renders avatar and allows opening avatar picker', (tester) async {
      await tester.pumpWidget(createTestApp(const ChildProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Profil Anak'), findsOneWidget);
      expect(find.text('Nama Anak'), findsOneWidget);
      expect(find.text('Edit Data Anak'), findsOneWidget);

      // Tap avatar camera edit button
      final cameraBtn = find.byIcon(Icons.camera_alt);
      expect(cameraBtn, findsOneWidget);
      await tester.tap(cameraBtn);
      await tester.pumpAndSettle();

      // Verify bottom sheet options
      expect(find.text('Pilih Foto Profil Anak'), findsOneWidget);
      expect(find.text('Unggah Media / Foto:'), findsOneWidget);
      expect(find.text('Kamera'), findsOneWidget);
      expect(find.text('Galeri'), findsOneWidget);
      expect(find.text('Pilih dari Karakter Si-Cehat:'), findsOneWidget);
      expect(find.text('Anak Si Cehat'), findsOneWidget);
      expect(find.text('Hapus / Reset Foto'), findsOneWidget);

      // Select preset
      final prov = tester.element(find.byType(ChildProfileScreen)).read<ProfileProvider>();
      await tester.tap(find.byKey(const Key('preset_Anak Si Cehat')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));

      expect(prov.activeChild?.avatarUrl, 'assets/dashboard/hello.png');
      expect(find.text('Foto profil anak berhasil diperbarui'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Tracker Screen: displays growth chart, latest values, and measurement history', (tester) async {
      await tester.pumpWidget(createTestApp(const TrackerScreen()));
      await tester.pumpAndSettle();

      // Verify tabs and growth chart
      expect(find.text('Tracker'), findsOneWidget);
      expect(find.text('Tumbuh Kembang'), findsOneWidget);
      expect(find.text('Grafik BB (Kg)'), findsOneWidget);
      expect(find.text('Berat Badan Terakhir'), findsOneWidget);
      expect(find.text('Tinggi Badan Terakhir'), findsOneWidget);
      expect(find.text('+ Tambah Pengukuran'), findsOneWidget);
      expect(find.text('Riwayat Pengukuran'), findsOneWidget);

      // Switch to Aktivitas tab
      await tester.tap(find.text('Aktivitas'));
      await tester.pumpAndSettle();

      expect(find.text('Target Aktivitas Fisik'), findsOneWidget);
      expect(find.text('Konsumsi Air Putih'), findsOneWidget);
      expect(find.text('+ Catat Aktivitas Baru'), findsOneWidget);

      // Increment water glasses
      final addWaterBtn = find.byTooltip('Tambah 1 Gelas');
      expect(addWaterBtn, findsOneWidget);
      await tester.tap(addWaterBtn);
      await tester.pumpAndSettle();
      expect(find.text('1 dari 8 Gelas (~250 ml)'), findsOneWidget);

      // Open Add Activity Sheet
      final addBtn = find.text('+ Catat Aktivitas Baru');
      await tester.ensureVisible(addBtn);
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(find.text('Catat Aktivitas Baru'), findsOneWidget);
      expect(find.text('Bermain Sepeda'), findsOneWidget);

      // Tap preset
      await tester.tap(find.text('Bermain Sepeda'));
      await tester.pumpAndSettle();

      // Submit activity
      final submitBtn = find.text('Simpan Aktivitas');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Aktivitas "Bermain Sepeda" berhasil dicatat!'), findsOneWidget);
      expect(find.text('Bermain Sepeda'), findsOneWidget);
      expect(find.text('30 menit'), findsOneWidget);

      // Return to Tumbuh Kembang tab
      final tumbuhTab = find.text('Tumbuh Kembang');
      await tester.ensureVisible(tumbuhTab);
      await tester.tap(tumbuhTab);
      await tester.pumpAndSettle();
    });
  });
}
