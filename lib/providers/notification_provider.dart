import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../core/database/seed_data.dart';
import '../data/models/notification_model.dart';

/// Notifications are local-only for now: the deployed backend does not expose
/// `/api/notifications` (GET falls through to the SPA and mutations return
/// 404), so asking the server on every action only produced silent failures.
class NotificationProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    _notifications = List.from(SeedData.initialNotifications);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final local = await _dbHelper.getNotifications();
      // Keep the seeded items on a fresh install so the center is not empty
      // before the local database has been populated.
      if (local.isNotEmpty) {
        _notifications = local;
      }
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('[NotificationProvider] Local load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
      notifyListeners();

      await _dbHelper.markNotificationRead(id);
    }
  }

  Future<void> markAllAsRead() async {
    if (_notifications.isEmpty) return;

    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
    notifyListeners();

    await _dbHelper.markAllNotificationsRead();
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();

    await _dbHelper.deleteNotification(id);
  }

  Future<void> addLocalNotification({
    required String title,
    required String message,
    String type = 'SYSTEM',
    String? referenceId,
  }) async {
    final notif = NotificationModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      type: type,
      referenceId: referenceId,
      isRead: false,
      createdAt: DateTime.now(),
    );

    _notifications.insert(0, notif);
    _unreadCount++;
    notifyListeners();

    await _dbHelper.insertNotification(notif);
  }
}
