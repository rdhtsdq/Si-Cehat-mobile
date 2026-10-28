import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../../data/models/reminder_model.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  static const String remindersChannelId = 'reminders';
  static const String generalChannelId = 'general';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void>? _initializing;
  bool _ready = false;

  /// Called when the user taps a notification. Set by the app shell.
  void Function(String? payload)? onNotificationTap;

  Future<void> initialize() {
    return _initializing ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    try {
      tzdata.initializeTimeZones();
      try {
        final timezone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezone.identifier));
      } catch (e) {
        debugPrint('[LocalNotification] Timezone fallback: $e');
      }

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: androidSettings,
          iOS: darwinSettings,
        ),
        onDidReceiveNotificationResponse: (response) {
          onNotificationTap?.call(response.payload);
        },
      );

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          remindersChannelId,
          'Pengingat Kesehatan',
          description:
              'Pengingat jadwal makan, minum, aktivitas, dan tidur anak.',
          importance: Importance.high,
        ),
      );
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          generalChannelId,
          'Notifikasi Si Cehat',
          description: 'Konsultasi, edukasi, dan aktivitas PlayLab.',
          importance: Importance.max,
        ),
      );

      _ready = true;
    } catch (e) {
      debugPrint('[LocalNotification] Initialization skipped: $e');
    }
  }

  Future<bool> requestPermission() async {
    await initialize();
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (e) {
      debugPrint('[LocalNotification] Permission request failed: $e');
    }
    return true;
  }

  Future<void> rescheduleReminders(List<ReminderModel> reminders) async {
    await initialize();
    if (!_ready) return;

    try {
      await _plugin.cancelAll();
      final now = tz.TZDateTime.now(tz.local);

      for (final reminder in reminders.where((item) => item.isEnabled)) {
        final parts = reminder.time.split(':');
        if (parts.length != 2) continue;

        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null ||
            minute == null ||
            hour < 0 ||
            hour > 23 ||
            minute < 0 ||
            minute > 59) {
          continue;
        }

        var scheduled = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );
        if (!scheduled.isAfter(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }

        await _plugin.zonedSchedule(
          id: notificationIdFor(reminder.id ?? reminder.title),
          title: 'Waktunya ${reminder.title}!',
          body:
              'Pengingat kebiasaan sehat keluarga: ${reminder.title} pukul ${reminder.time} WIB.',
          scheduledDate: scheduled,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              remindersChannelId,
              'Pengingat Kesehatan',
              channelDescription:
                  'Pengingat jadwal makan, minum, aktivitas, dan tidur anak.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: jsonEncode({
            'type': 'REMINDER',
            'reminderId': reminder.id?.toString(),
          }),
        );
      }
    } catch (e) {
      debugPrint('[LocalNotification] Reschedule failed: $e');
    }
  }

  Future<void> cancelAll() async {
    await initialize();
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('[LocalNotification] Cancel failed: $e');
    }
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();
    if (!_ready) return;
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            generalChannelId,
            'Notifikasi Si Cehat',
            channelDescription:
                'Konsultasi, edukasi, dan aktivitas PlayLab.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      debugPrint('[LocalNotification] Show failed: $e');
    }
  }

  /// Stable 31-bit id so scheduling/cancel uses the same value across runs.
  int notificationIdFor(dynamic reminderId) {
    var hash = 0;
    for (final codeUnit in reminderId.toString().codeUnits) {
      hash = ((hash * 31) + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}
