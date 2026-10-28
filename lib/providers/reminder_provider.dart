import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/database/database_helper.dart';
import '../core/database/seed_data.dart';
import '../core/services/local_notification_service.dart';
import '../data/models/reminder_model.dart';

class ReminderProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;

  int get completedTodayCount => _reminders.where((r) => r.isCompleted).length;
  int get activeRemindersCount => _reminders.where((r) => r.isEnabled).length;

  ReminderProvider() {
    _reminders = List.from(SeedData.initialReminders);
    loadReminders();
  }

  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();

    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.get(ApiConstants.reminders);
        if (res.isSuccess && res.data != null) {
          final rawList = res.data['reminders'] as List<dynamic>?;
          if (rawList != null && rawList.isNotEmpty) {
            _reminders = rawList
                .map((r) => ReminderModel.fromJson(r as Map<String, dynamic>))
                .toList();

            _isLoading = false;
            notifyListeners();
            return;
          }
        }
      } catch (e) {
        debugPrint('[ReminderProvider] Remote load reminders error: $e');
      }
    }

    // Fallback to local SQLite db
    try {
      final local = await _dbHelper.getReminders();
      if (local.isNotEmpty) {
        _reminders = local;
      }
    } catch (e) {
      debugPrint('[ReminderProvider] Local load reminders error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      await _reschedule();
    }
  }

  Future<void> _reschedule() async {
    await LocalNotificationService.instance.rescheduleReminders(_reminders);
  }

  Future<void> toggleReminder(dynamic id, bool isEnabled) async {
    final index = _reminders.indexWhere((r) => r.id.toString() == id.toString());
    if (index != -1) {
      final updated = _reminders[index].copyWith(isEnabled: isEnabled);
      _reminders[index] = updated;
      notifyListeners();

      final token = await _apiClient.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          await _apiClient.patch(
            '${ApiConstants.reminders}/$id',
            body: {'isEnabled': isEnabled},
          );
        } catch (e) {
          debugPrint('[ReminderProvider] Remote toggle reminder error: $e');
        }
      }

      await _dbHelper.updateReminder(updated);
      await _reschedule();
    }
  }

  Future<void> toggleCompleteReminder(dynamic id) async {
    final index = _reminders.indexWhere((r) => r.id.toString() == id.toString());
    if (index != -1) {
      final current = _reminders[index];
      final newStatus = !current.isCompleted;
      final nowStr = DateTime.now().toIso8601String();
      final updated = current.copyWith(
        isCompleted: newStatus,
        lastCompletedAt: newStatus ? nowStr : null,
      );
      _reminders[index] = updated;
      notifyListeners();

      final token = await _apiClient.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          await _apiClient.patch(
            '${ApiConstants.reminders}/$id',
            body: {
              'isCompleted': newStatus,
            },
          );
        } catch (e) {
          debugPrint('[ReminderProvider] Remote complete reminder error: $e');
        }
      }

      await _dbHelper.updateReminder(updated);
    }
  }

  Future<void> addReminder(
    String title,
    String time, {
    String repeatDays = 'Setiap Hari',
    String category = 'umum',
  }) async {
    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _apiClient.post(
          ApiConstants.reminders,
          body: {
            'title': title,
            'time': time,
            'category': category,
          },
        );
        if (res.isSuccess) {
          await loadReminders();
          return;
        }
      } catch (e) {
        debugPrint('[ReminderProvider] Remote add reminder error: $e');
      }
    }

    final item = ReminderModel(
      title: title,
      time: time,
      isEnabled: true,
      repeatDays: repeatDays,
      category: category,
      isCompleted: false,
    );
    await _dbHelper.insertReminder(item);
    await loadReminders();
  }

  Future<void> updateReminder(
    dynamic id, {
    required String title,
    required String time,
    String repeatDays = 'Setiap Hari',
    String category = 'umum',
    bool isEnabled = true,
  }) async {
    final index = _reminders.indexWhere((r) => r.id.toString() == id.toString());
    if (index != -1) {
      final updated = _reminders[index].copyWith(
        title: title,
        time: time,
        repeatDays: repeatDays,
        category: category,
        isEnabled: isEnabled,
      );
      _reminders[index] = updated;
      notifyListeners();

      final token = await _apiClient.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          await _apiClient.patch(
            '${ApiConstants.reminders}/$id',
            body: {
              'title': title,
              'time': time,
              'category': category,
              'isEnabled': isEnabled,
            },
          );
        } catch (e) {
          debugPrint('[ReminderProvider] Remote update reminder error: $e');
        }
      }

      await _dbHelper.updateReminder(updated);
      await _reschedule();
    }
  }

  Future<void> deleteReminder(dynamic id) async {
    _reminders.removeWhere((r) => r.id.toString() == id.toString());
    notifyListeners();

    final token = await _apiClient.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _apiClient.delete('${ApiConstants.reminders}/$id');
      } catch (e) {
        debugPrint('[ReminderProvider] Remote delete reminder error: $e');
      }
    }

    await _dbHelper.deleteReminder(id);
    await loadReminders();
  }
}
