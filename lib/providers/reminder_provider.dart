import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../data/models/reminder_model.dart';

class ReminderProvider extends ChangeNotifier {
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
    try {
      _reminders = await _dbHelper.getReminders();
    } catch (e) {
      debugPrint('Error loading reminders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleReminder(int id, bool isEnabled) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updated = _reminders[index].copyWith(isEnabled: isEnabled);
      _reminders[index] = updated;
      notifyListeners();
      await _dbHelper.updateReminder(updated);
    }
  }

  Future<void> addReminder(String title, String time, {String repeatDays = 'Setiap Hari'}) async {
    final item = ReminderModel(
      title: title,
      time: time,
      isEnabled: true,
      repeatDays: repeatDays,
    );
    await _dbHelper.insertReminder(item);
    await loadReminders();
  }

  Future<void> deleteReminder(int id) async {
    await _dbHelper.deleteReminder(id);
    await loadReminders();
  }
}
