import 'package:flutter/foundation.dart';
import 'package:blap_car/models/expense_reminder.dart';
import 'package:blap_car/services/expense_reminder_service.dart';

class ExpenseReminderProvider with ChangeNotifier {
  List<ExpenseReminder> _expenseReminders = [];
  final ExpenseReminderService _expenseReminderService = ExpenseReminderService();

  List<ExpenseReminder> get expenseReminders => _expenseReminders;

  // Load all expense reminders for a vehicle
  Future<void> loadExpenseReminders(int vehicleId) async {
    _expenseReminders = await _expenseReminderService.getExpenseRemindersByVehicleId(vehicleId);
    notifyListeners();
  }

  // Add a new expense reminder
  Future<void> addExpenseReminder(ExpenseReminder reminder) async {
    final id = await _expenseReminderService.addExpenseReminder(reminder);
    reminder.id = id;
    _expenseReminders.add(reminder);
    notifyListeners();
  }

  // Update an expense reminder
  Future<void> updateExpenseReminder(ExpenseReminder reminder) async {
    await _expenseReminderService.updateExpenseReminder(reminder);
    final index = _expenseReminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _expenseReminders[index] = reminder;
      notifyListeners();
    }
  }

  // Delete an expense reminder
  Future<void> deleteExpenseReminder(int id) async {
    await _expenseReminderService.deleteExpenseReminder(id);
    _expenseReminders.removeWhere((reminder) => reminder.id == id);
    notifyListeners();
  }
}