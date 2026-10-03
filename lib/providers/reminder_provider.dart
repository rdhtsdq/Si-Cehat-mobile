import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/api/api_constants.dart';
import '../core/database/database_helper.dart';
import '../data/models/reminder_model.dart';

class ReminderProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<ReminderModel> _reminders = [];
  bool _isLoading = true;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;

  ReminderProvider() {
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
          if (rawList != null) {
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
      _reminders = await _dbHelper.getReminders();
    } catch (e) {
      debugPrint('[ReminderProvider] Local load reminders error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    );
    await _dbHelper.insertReminder(item);
    await loadReminders();
  }

  Future<void> deleteReminder(dynamic id) async {
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
