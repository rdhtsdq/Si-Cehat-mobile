import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:si_cehat_mobile/core/database/database_helper.dart';
import 'package:si_cehat_mobile/core/services/playlab_storage_service.dart';
import 'package:si_cehat_mobile/data/models/playlab_score_model.dart';

PlayLabScoreResult _result({
  required String sessionId,
  required String childId,
  int totalScore = 100,
}) {
  return PlayLabScoreResult(
    sessionId: sessionId,
    childId: childId,
    childName: 'Anak Uji',
    gameplayScore: totalScore,
    knowledgeScore: 100,
    totalScore: totalScore,
    starsEarned: 3,
    xpAwarded: 75,
    feedbackSummary: 'Piring sehat seimbang.',
    completedAt: DateTime(2026, 10, 28, 10, 30),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlayLabStorageService deduplication', () {
    test('menyimpan sesi yang sama dua kali tidak menggandakan riwayat', () async {
      final result = _result(sessionId: 'sess-dedupe-1', childId: 'child-dedupe-1');

      await PlayLabStorageService.instance.saveScoreResult(result);
      await PlayLabStorageService.instance.saveScoreResult(result);

      final history = await PlayLabStorageService.instance.getScoreHistory(
        childId: 'child-dedupe-1',
      );

      expect(history, hasLength(1));
    });

    test('menyimpan sesi yang sama dua kali tidak menggandakan activity log',
        () async {
      final result = _result(sessionId: 'sess-dedupe-2', childId: 'child-dedupe-2');

      await PlayLabStorageService.instance.saveScoreResult(result);
      await PlayLabStorageService.instance.saveScoreResult(result);

      final activities = await DatabaseHelper.instance.getActivities(
        'child-dedupe-2',
        '2026-10-28',
      );

      expect(
        activities.where((a) => a.title.contains('PlayLab')),
        hasLength(1),
      );
    });

    test('sesi berbeda tetap ditambahkan ke riwayat', () async {
      await PlayLabStorageService.instance.saveScoreResult(
        _result(sessionId: 'sess-dedupe-3a', childId: 'child-dedupe-3'),
      );
      await PlayLabStorageService.instance.saveScoreResult(
        _result(sessionId: 'sess-dedupe-3b', childId: 'child-dedupe-3'),
      );

      final history = await PlayLabStorageService.instance.getScoreHistory(
        childId: 'child-dedupe-3',
      );

      expect(history, hasLength(2));
    });

    test('skor terbaru tetap diperbarui walau sesi sudah pernah disimpan',
        () async {
      await PlayLabStorageService.instance.saveScoreResult(
        _result(
          sessionId: 'sess-dedupe-4',
          childId: 'child-dedupe-4',
          totalScore: 60,
        ),
      );

      await PlayLabStorageService.instance.saveScoreResult(
        _result(
          sessionId: 'sess-dedupe-4',
          childId: 'child-dedupe-4',
          totalScore: 90,
        ),
      );

      final latest = await PlayLabStorageService.instance.getLatestScore(
        childId: 'child-dedupe-4',
      );

      expect(latest?.totalScore, 90);
    });
  });
}
