import 'dart:async';
import 'package:flutter/foundation.dart';

class PushMessage {
  final String title;
  final String body;
  final String? type;
  final String? referenceId;

  const PushMessage({
    required this.title,
    required this.body,
    this.type,
    this.referenceId,
  });

  factory PushMessage.fromData(Map<String, dynamic> data) {
    return PushMessage(
      title: data['title']?.toString() ?? 'Notifikasi Si Cehat',
      body: data['body']?.toString() ?? '',
      type: data['type']?.toString(),
      referenceId: data['referenceId']?.toString(),
    );
  }
}

/// Phase 1 seam for FCM. The real Firebase implementation is enabled after
/// `google-services.json` and the Firebase project are available; until then
/// this service is intentionally a no-op so the app still builds and runs.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final StreamController<PushMessage> _messages =
      StreamController<PushMessage>.broadcast();

  bool _initialized = false;
  bool _enabled = false;

  bool get isEnabled => _enabled;
  Stream<PushMessage> get messages => _messages.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _enabled = false;
    debugPrint('[Push] FCM disabled until Firebase configuration is provided.');
  }

  Future<void> registerDevice() async {
    if (!_enabled) return;
    // Phase 2: get the FCM token and POST /api/notifications/devices.
  }

  Future<void> unregisterDevice() async {
    if (!_enabled) return;
    // Phase 2: DELETE /api/notifications/devices for the current token.
  }

  @visibleForTesting
  void emit(PushMessage message) {
    _messages.add(message);
  }
}
