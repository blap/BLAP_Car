import 'package:blap_car/models/expense_reminder.dart';
import 'package:blap_car/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ExpenseReminderDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get database async => await _databaseHelper.database;

  // Insert an expense reminder
  Future<int> insertExpenseReminder(ExpenseReminder reminder) async {
    final db = await database;
    return await db.insert('expense_reminder', reminder.toMap());
  }

  // Get all expense reminders
  Future<List<ExpenseReminder>> getAllExpenseReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expense_reminder');
    
    return List.generate(maps.length, (i) {
      return ExpenseReminder.fromMap(maps[i]);
    });
  }

  // Get expense reminders by vehicle id
  Future<List<ExpenseReminder>> getExpenseRemindersByVehicleId(int vehicleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expense_reminder',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    
    return List.generate(maps.length, (i) {
      return ExpenseReminder.fromMap(maps[i]);
    });
  }

  // Get an expense reminder by id
  Future<ExpenseReminder?> getExpenseReminderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expense_reminder',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return ExpenseReminder.fromMap(maps.first);
    }
    return null;
  }

  // Update an expense reminder
  Future<int> updateExpenseReminder(ExpenseReminder reminder) async {
    final db = await database;
    return await db.update(
      'expense_reminder',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  // Delete an expense reminder
  Future<int> deleteExpenseReminder(int id) async {
    final db = await database;
    return await db.delete(
      'expense_reminder',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}