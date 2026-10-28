import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/database/database_helper.dart';
import '../core/database/seed_data.dart';
import '../data/models/notification_model.dart';

/// Loads notifications from the backend when the user is signed in and keeps a
/// local SQLite cache as the offline fallback. Mutations update the local state
/// immediately and are forwarded to the API on a best-effort basis.
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
        if (res.isSuccess && res.data is Map<String, dynamic>) {
          final data = res.data as Map<String, dynamic>;
          final rawList = data['notifications'];
          if (rawList is List) {
            _notifications = rawList
                .whereType<Map<String, dynamic>>()
                .map(NotificationModel.fromJson)
                .toList();
            _unreadCount = (data['unreadCount'] as num?)?.toInt() ??
                _notifications.where((n) => !n.isRead).length;

            // Replace the cache with the server state so notifications deleted
            // on the server do not reappear when the app goes offline.
            await _dbHelper.clearNotifications();
            for (final notification in _notifications) {
              await _dbHelper.insertNotification(notification);
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

    // Local SQLite fallback (also used when the backend does not expose the
    // notification routes yet).
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
      await _syncIfLoggedIn(() async {
        await _apiClient.patch(
          '${ApiConstants.notifications}/$id',
          body: {'isRead': true},
        );
      });
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
    await _syncIfLoggedIn(() async {
      await _apiClient.post(ApiConstants.notificationsReadAll);
    });
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    _unreadCount = _notifications.where((n) => !n.isRead).length;
    notifyListeners();

    await _dbHelper.deleteNotification(id);
    await _syncIfLoggedIn(() async {
      await _apiClient.delete('${ApiConstants.notifications}/$id');
    });
  }

  Future<void> _syncIfLoggedIn(Future<void> Function() request) async {
    final token = await _apiClient.getToken();
    if (token == null || token.isEmpty) return;
    try {
      await request();
    } catch (e) {
      debugPrint('[NotificationProvider] Remote sync error: $e');
    }
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
