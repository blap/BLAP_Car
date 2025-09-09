import 'package:blap_car/models/expense_reminder.dart';
import 'package:blap_car/database/expense_reminder_dao.dart';

class ExpenseReminderService {
  final ExpenseReminderDao _expenseReminderDao = ExpenseReminderDao();

  // Get all expense reminders
  Future<List<ExpenseReminder>> getAllExpenseReminders() async {
    return await _expenseReminderDao.getAllExpenseReminders();
  }

  // Get expense reminders by vehicle id
  Future<List<ExpenseReminder>> getExpenseRemindersByVehicleId(int vehicleId) async {
    return await _expenseReminderDao.getExpenseRemindersByVehicleId(vehicleId);
  }

  // Get an expense reminder by id
  Future<ExpenseReminder?> getExpenseReminderById(int id) async {
    return await _expenseReminderDao.getExpenseReminderById(id);
  }

  // Add a new expense reminder
  Future<int> addExpenseReminder(ExpenseReminder reminder) async {
    return await _expenseReminderDao.insertExpenseReminder(reminder);
  }

  // Update an expense reminder
  Future<int> updateExpenseReminder(ExpenseReminder reminder) async {
    return await _expenseReminderDao.updateExpenseReminder(reminder);
  }

  // Delete an expense reminder
  Future<int> deleteExpenseReminder(int id) async {
    return await _expenseReminderDao.deleteExpenseReminder(id);
  }
}