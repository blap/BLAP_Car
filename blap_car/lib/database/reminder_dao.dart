import 'package:blap_car/models/reminder.dart';
import 'package:blap_car/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ReminderDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get database async => await _databaseHelper.database;

  // Insert a reminder
  Future<int> insertReminder(Reminder reminder) async {
    final db = await database;
    return await db.insert('reminder', reminder.toMap());
  }

  // Get all reminders
  Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reminder');
    
    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  // Get reminders by vehicle id
  Future<List<Reminder>> getRemindersByVehicleId(int vehicleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminder',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    
    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  // Get a reminder by id
  Future<Reminder?> getReminderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reminder',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Reminder.fromMap(maps.first);
    }
    return null;
  }

  // Update a reminder
  Future<int> updateReminder(Reminder reminder) async {
    final db = await database;
    return await db.update(
      'reminder',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  // Delete a reminder
  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete(
      'reminder',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}