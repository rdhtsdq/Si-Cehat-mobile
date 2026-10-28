import 'dart:convert';
import 'package:flutter/material.dart';
import '../../screens/consultation/notification_center_screen.dart';
import '../../screens/reminder/reminder_screen.dart';

class NotificationNavigation {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Returns `reminder`, `notifications`, or null for unknown payloads.
  static String? routeNameForPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final data = jsonDecode(payload);
      if (data is! Map) return null;
      final type = data['type']?.toString().toUpperCase();
      if (type == 'REMINDER') return 'reminder';
      if (type == 'CONSULTATION' ||
          type == 'GAME' ||
          type == 'EDUCATION' ||
          type == 'SYSTEM') {
        return 'notifications';
      }
    } catch (_) {}
    return null;
  }

  static Future<void> handlePayload(String? payload) async {
    final route = routeNameForPayload(payload);
    if (route == null) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    if (route == 'reminder') {
      await navigator.push(
        MaterialPageRoute(builder: (_) => const ReminderScreen()),
      );
    } else {
      await navigator.push(
        MaterialPageRoute(builder: (_) => const NotificationCenterScreen()),
      );
    }
  }
}
