import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/notification_model.dart';
import '../database/database_helper.dart';

class ReminderService {
  static final ReminderService instance = ReminderService._internal();
  ReminderService._internal();

  Timer? _ticker;
  final StreamController<ReminderModel> _onReminderTriggered =
      StreamController<ReminderModel>.broadcast();

  Stream<ReminderModel> get onReminderTriggered => _onReminderTriggered.stream;

  // Track triggered reminder IDs per date (YYYY-MM-DD:id) to prevent duplicate delivery
  final Set<String> _triggeredSet = {};

  void start() {
    _ticker?.cancel();
    // Check every 20 seconds for precise time matching
    _ticker = Timer.periodic(const Duration(seconds: 20), (_) => _checkReminders());
    _checkReminders();
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
  }

  Future<void> _checkReminders() async {
    try {
      final now = DateTime.now();
      final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final currentHourMinute =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final reminders = await DatabaseHelper.instance.getReminders();

      for (final r in reminders) {
        if (!r.isEnabled) continue;

        if (r.time == currentHourMinute) {
          final triggerKey = '$dateKey:${r.id ?? r.title}';
          if (!_triggeredSet.contains(triggerKey)) {
            _triggeredSet.add(triggerKey);
            debugPrint('[ReminderService] Triggering reminder: ${r.title} at $currentHourMinute');

            // 1. Emit to stream for immediate UI feedback (Snackbar, In-App banner, Dialog)
            _onReminderTriggered.add(r);

            // 2. Persist notification into Notification Center
            final notif = NotificationModel(
              id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Waktunya ${r.title}!',
              message: 'Pengingat kebiasaan sehat keluarga: ${r.title} pukul ${r.time} WIB.',
              type: 'REMINDER',
              referenceId: r.id?.toString(),
              isRead: false,
              createdAt: DateTime.now(),
            );
            await DatabaseHelper.instance.insertNotification(notif);
          }
        }
      }
    } catch (e) {
      debugPrint('[ReminderService] Error checking reminders: $e');
    }
  }

  void dispose() {
    stop();
    _onReminderTriggered.close();
  }
}
