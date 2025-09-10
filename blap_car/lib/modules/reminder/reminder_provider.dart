import 'package:flutter/foundation.dart';
import 'package:blap_car/models/reminder.dart';
import 'package:blap_car/services/reminder_service.dart';

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];
  String? _errorMessage;

  List<Reminder> get reminders => _reminders;
  String? get errorMessage => _errorMessage;

  // Load all reminders
  Future<void> loadReminders() async {
    try {
      final allReminders = await ReminderService().getAllReminders();
      _reminders = allReminders.whereType<Reminder>().toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _reminders = [];
    }
    notifyListeners();
  }

  // Add a new reminder
  Future<bool> addReminder(Reminder reminder) async {
    try {
      final id = await ReminderService().addReminder(reminder);
      reminder.id = id;
      _reminders.add(reminder);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update a reminder
  Future<bool> updateReminder(Reminder reminder) async {
    try {
      await ReminderService().updateReminder(reminder);
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = reminder;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete a reminder
  Future<bool> deleteReminder(int id) async {
    try {
      await ReminderService().deleteReminder(id);
      _reminders.removeWhere((reminder) => reminder.id == id);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
