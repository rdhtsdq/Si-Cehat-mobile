import 'package:flutter_test/flutter_test.dart';
import 'package:si_cehat_mobile/core/database/database_helper.dart';
import 'package:si_cehat_mobile/data/models/activity_log_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resetDemoData clears activity logs and water logs', () async {
    final db = DatabaseHelper.instance;

    await db.insertActivity(
      ActivityLogModel(
        childId: 1,
        date: '2026-01-15',
        title: 'Bermain Sepeda',
        category: 'Aktivitas Fisik',
        durationMinutes: 30,
        intensity: 'Sedang',
      ),
    );
    await db.setWaterGlasses(1, '2026-01-15', 3);

    // Sanity: data is present before reset.
    expect(await db.getActivities(1, '2026-01-15'), isNotEmpty);
    expect(await db.getWaterGlasses(1, '2026-01-15'), 3);

    await db.resetDemoData();

    // Regression: reset must clear activity + water logs, not leave orphans.
    expect(await db.getActivities(1, '2026-01-15'), isEmpty);
    expect(await db.getWaterGlasses(1, '2026-01-15'), 0);

    // Seed data is restored after reset.
    expect(await db.getMotherProfile(), isNotNull);
    expect(await db.getChildren(), isNotEmpty);
  });
}
