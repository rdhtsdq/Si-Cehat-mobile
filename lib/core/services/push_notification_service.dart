import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_constants.dart';
import 'local_notification_service.dart';
import 'notification_navigation.dart';

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

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final ApiClient _apiClient = ApiClient.instance;
  final LocalNotificationService _local = LocalNotificationService.instance;
  final StreamController<PushMessage> _messages =
      StreamController<PushMessage>.broadcast();

  StreamSubscription<String>? _registrationSubscription;
  StreamSubscription<String>? _unregistrationSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;

  bool _initialized = false;
  bool _enabled = false;
  String? _fid;

  bool get isEnabled => _enabled;
  Stream<PushMessage> get messages => _messages.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final supported = await FirebaseMessaging.instance.isSupported();
      if (!supported) {
        debugPrint('[Push] FCM is not supported on this platform.');
        return;
      }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );

      _enabled = true;

      // FCM 17 uses Firebase Installation IDs (FID) instead of the legacy
      // registration token. The FID is delivered through onRegistered.
      _registrationSubscription =
          FirebaseMessaging.instance.onRegistered.listen((fid) {
        _fid = fid;
        registerDevice();
      });
      _unregistrationSubscription =
          FirebaseMessaging.instance.onUnregistered.listen((_) {
        _fid = null;
      });

      await FirebaseMessaging.instance.register();

      _foregroundSubscription =
          FirebaseMessaging.onMessage.listen(_handleForeground);
      _openedSubscription =
          FirebaseMessaging.onMessageOpenedApp.listen((message) {
        NotificationNavigation.handlePayload(
          jsonEncode(_payloadFor(message)),
        );
      });
    } catch (e) {
      _enabled = false;
      debugPrint('[Push] FCM initialization skipped: $e');
    }
  }

  Future<void> registerDevice() async {
    if (!_enabled) return;
    try {
      final authToken = await _apiClient.getToken();
      if (authToken == null || authToken.isEmpty) return;

      if (_fid == null || _fid!.isEmpty) {
        // onRegistered will call registerDevice again with the FID.
        await FirebaseMessaging.instance.register();
        return;
      }

      await _apiClient.post(
        ApiConstants.notificationsDevices,
        body: {'token': _fid, 'platform': 'android'},
      );
    } catch (e) {
      debugPrint('[Push] Device registration failed: $e');
    }
  }

  Future<void> unregisterDevice() async {
    final fid = _fid;
    if (fid == null || fid.isEmpty) return;
    try {
      await _apiClient.delete(
        '${ApiConstants.notificationsDevices}?token=${Uri.encodeQueryComponent(fid)}',
      );
    } catch (e) {
      debugPrint('[Push] Device unregister failed: $e');
    }
  }

  /// Call after the navigator is ready to handle a notification tap that
  /// launched a terminated app.
  Future<String?> consumeInitialMessage() async {
    if (!_enabled) return null;
    try {
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message == null) return null;
      return jsonEncode(_payloadFor(message));
    } catch (e) {
      debugPrint('[Push] Initial message error: $e');
      return null;
    }
  }

  void _handleForeground(RemoteMessage message) {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Notifikasi Si Cehat';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        '';
    final payload = jsonEncode(_payloadFor(message));

    _messages.add(
      PushMessage(
        title: title,
        body: body,
        type: message.data['type']?.toString(),
        referenceId: message.data['referenceId']?.toString(),
      ),
    );

    _local.show(
      id: _local.notificationIdFor(
        message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      ),
      title: title,
      body: body,
      payload: payload,
    );
  }

  Map<String, String> _payloadFor(RemoteMessage message) {
    return {
      'type': message.data['type']?.toString() ?? '',
      'referenceId': message.data['referenceId']?.toString() ?? '',
    };
  }

  @visibleForTesting
  void emit(PushMessage message) {
    _messages.add(message);
  }

  Future<void> dispose() async {
    await _registrationSubscription?.cancel();
    await _unregistrationSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _messages.close();
  }
}
