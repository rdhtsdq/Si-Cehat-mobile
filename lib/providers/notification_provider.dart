import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/database/database_helper.dart';
import '../core/database/seed_data.dart';
import '../data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;
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

    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.get(ApiConstants.notifications);
        if (res.isSuccess && res.data != null) {
          final rawList = res.data['notifications'] as List<dynamic>?;
          if (rawList != null) {
            _notifications = rawList
                .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
                .toList();

            _unreadCount = res.data['unreadCount'] as int? ??
                _notifications.where((n) => !n.isRead).length;

            // Cache to local db
            for (final n in _notifications) {
              await _dbHelper.insertNotification(n);
            }

            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint('[NotificationProvider] Remote load error: $e');
      }
    }

    // Local SQLite fallback
    try {
      _notifications = await _dbHelper.getNotifications();
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

      final token = await _apiClient.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          await _apiClient.patch(
            '${ApiConstants.notifications}/$id',
            body: {'isRead': true},
          );
        } catch (e) {
          debugPrint('[NotificationProvider] Remote markRead error: $e');
        }
      }

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

    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.post(ApiConstants.notificationsReadAll);
      } catch (e) {
        debugPrint('[NotificationProvider] Remote markAllRead error: $e');
      }
    }

    await _dbHelper.markAllNotificationsRead();
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();

    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.delete('${ApiConstants.notifications}/$id');
      } catch (e) {
        debugPrint('[NotificationProvider] Remote delete error: $e');
      }
    }

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
