import 'package:blap_car/database/reminder_dao.dart';
import 'package:blap_car/database/expense_reminder_dao.dart';
import 'package:blap_car/models/reminder.dart';
import 'package:blap_car/models/expense_reminder.dart';

class ReminderService {
  final ReminderDao _reminderDao = ReminderDao();
  final ExpenseReminderDao _expenseReminderDao = ExpenseReminderDao();

  // Get all reminders (both general and expense reminders)
  Future<List<dynamic>> getAllReminders() async {
    final generalReminders = await _reminderDao.getAllReminders();
    final expenseReminders = await _expenseReminderDao.getAllExpenseReminders();
    
    // Combine both lists
    List<dynamic> allReminders = [];
    allReminders.addAll(generalReminders);
    allReminders.addAll(expenseReminders);
    
    // Sort by date (newest first)
    allReminders.sort((a, b) {
      DateTime? dateA, dateB;
      
      if (a is Reminder) {
        dateA = a.date;
      } else if (a is ExpenseReminder) {
        dateA = a.triggerDate;
      }
      
      if (b is Reminder) {
        dateB = b.date;
      } else if (b is ExpenseReminder) {
        dateB = b.triggerDate;
      }
      
      // Handle null dates by treating them as distant future
      dateA ??= DateTime(3000, 1, 1);
      dateB ??= DateTime(3000, 1, 1);
      
      return dateB.compareTo(dateA);
    });
    
    return allReminders;
  }

  // Get reminders by vehicle id
  Future<List<dynamic>> getRemindersByVehicleId(int vehicleId) async {
    final generalReminders = await _reminderDao.getRemindersByVehicleId(vehicleId);
    final expenseReminders = await _expenseReminderDao.getExpenseRemindersByVehicleId(vehicleId);
    
    // Combine both lists
    List<dynamic> vehicleReminders = [];
    vehicleReminders.addAll(generalReminders);
    vehicleReminders.addAll(expenseReminders);
    
    // Sort by date (newest first)
    vehicleReminders.sort((a, b) {
      DateTime? dateA, dateB;
      
      if (a is Reminder) {
        dateA = a.date;
      } else if (a is ExpenseReminder) {
        dateA = a.triggerDate;
      }
      
      if (b is Reminder) {
        dateB = b.date;
      } else if (b is ExpenseReminder) {
        dateB = b.triggerDate;
      }
      
      // Handle null dates by treating them as distant future
      dateA ??= DateTime(3000, 1, 1);
      dateB ??= DateTime(3000, 1, 1);
      
      return dateB.compareTo(dateA);
    });
    
    return vehicleReminders;
  }

  // Get upcoming reminders (within the next 30 days)
  Future<List<dynamic>> getUpcomingReminders({int days = 30}) async {
    final allReminders = await getAllReminders();
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));
    
    return allReminders.where((reminder) {
      DateTime? reminderDate;
      
      if (reminder is Reminder) {
        reminderDate = reminder.date;
      } else if (reminder is ExpenseReminder) {
        reminderDate = reminder.triggerDate;
      }
      
      // Check if the reminder date is within the next 30 days
      if (reminderDate != null) {
        return reminderDate.isAfter(now) && reminderDate.isBefore(futureDate);
      }
      
      return false;
    }).toList();
  }

  // Get overdue reminders
  Future<List<dynamic>> getOverdueReminders() async {
    final allReminders = await getAllReminders();
    final now = DateTime.now();
    
    return allReminders.where((reminder) {
      DateTime? reminderDate;
      bool? isCompleted;
      
      if (reminder is Reminder) {
        reminderDate = reminder.date;
        isCompleted = reminder.completed;
      } else if (reminder is ExpenseReminder) {
        reminderDate = reminder.triggerDate;
        // Expense reminders don't have a completed field, so they're never considered completed
        isCompleted = false;
      }
      
      // Check if the reminder is overdue and not completed
      if (reminderDate != null && (isCompleted == false || isCompleted == null)) {
        return reminderDate.isBefore(now);
      }
      
      return false;
    }).toList();
  }

  // Mark a general reminder as completed
  Future<int> completeReminder(int reminderId) async {
    final reminder = await _reminderDao.getReminderById(reminderId);
    if (reminder != null) {
      reminder.completed = true;
      return await _reminderDao.updateReminder(reminder);
    }
    return 0;
  }

  // Mark a general reminder as incomplete
  Future<int> uncompleteReminder(int reminderId) async {
    final reminder = await _reminderDao.getReminderById(reminderId);
    if (reminder != null) {
      reminder.completed = false;
      return await _reminderDao.updateReminder(reminder);
    }
    return 0;
  }

  // Delete a general reminder
  Future<int> deleteReminder(int reminderId) async {
    return await _reminderDao.deleteReminder(reminderId);
  }

  // Delete an expense reminder
  Future<int> deleteExpenseReminder(int reminderId) async {
    return await _expenseReminderDao.deleteExpenseReminder(reminderId);
  }

  // Add a general reminder
  Future<int> addReminder(Reminder reminder) async {
    return await _reminderDao.insertReminder(reminder);
  }

  // Update a general reminder
  Future<int> updateReminder(Reminder reminder) async {
    return await _reminderDao.updateReminder(reminder);
  }
}