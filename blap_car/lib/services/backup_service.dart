import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blap_car/database/database_helper.dart';
import 'package:blap_car/models/backup.dart';
import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/models/reminder.dart';
import 'package:blap_car/models/expense_reminder.dart';
import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/database/refueling_dao.dart';
import 'package:blap_car/database/expense_dao.dart';
import 'package:blap_car/database/maintenance_dao.dart';
import 'package:blap_car/database/reminder_dao.dart';
import 'package:blap_car/database/expense_reminder_dao.dart';

class BackupService {
  // DAOs for data access
  final VehicleDao _vehicleDao = VehicleDao();
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final MaintenanceDao _maintenanceDao = MaintenanceDao();
  final ReminderDao _reminderDao = ReminderDao();
  final ExpenseReminderDao _expenseReminderDao = ExpenseReminderDao();

  // Export all data from the database
  Future<Map<String, dynamic>> _exportAllData() async {
    final vehicles = await _vehicleDao.getAllVehicles();
    final refuelings = await _refuelingDao.getAllRefuelings();
    final expenses = await _expenseDao.getAllExpenses();
    final maintenances = await _maintenanceDao.getAllMaintenances();
    final reminders = await _reminderDao.getAllReminders();
    final expenseReminders = await _expenseReminderDao.getAllExpenseReminders();

    return {
      'vehicles': vehicles.map((v) => v.toMap()).toList(),
      'refuelings': refuelings.map((r) => r.toMap()).toList(),
      'expenses': expenses.map((e) => e.toMap()).toList(),
      'maintenances': maintenances.map((m) => m.toMap()).toList(),
      'reminders': reminders.map((r) => r.toMap()).toList(),
      'expenseReminders': expenseReminders.map((er) => er.toMap()).toList(),
    };
  }

  // Import all data to the database
  Future<void> _importAllData(Map<String, dynamic> data) async {
    // Clear existing data first
    await _clearDatabase();

    // Import vehicles
    final vehicles = data['vehicles'] as List?;
    if (vehicles != null) {
      for (final vehicleMap in vehicles) {
        final vehicle = Vehicle.fromMap(vehicleMap as Map<String, dynamic>);
        await _vehicleDao.insertVehicle(vehicle);
      }
    }

    // Import refuelings
    final refuelings = data['refuelings'] as List?;
    if (refuelings != null) {
      for (final refuelingMap in refuelings) {
        final refueling = Refueling.fromMap(refuelingMap as Map<String, dynamic>);
        await _refuelingDao.insertRefueling(refueling);
      }
    }

    // Import expenses
    final expenses = data['expenses'] as List?;
    if (expenses != null) {
      for (final expenseMap in expenses) {
        final expense = Expense.fromMap(expenseMap as Map<String, dynamic>);
        await _expenseDao.insertExpense(expense);
      }
    }

    // Import maintenances
    final maintenances = data['maintenances'] as List?;
    if (maintenances != null) {
      for (final maintenanceMap in maintenances) {
        final maintenance = Maintenance.fromMap(maintenanceMap as Map<String, dynamic>);
        await _maintenanceDao.insertMaintenance(maintenance);
      }
    }

    // Import reminders
    final reminders = data['reminders'] as List?;
    if (reminders != null) {
      for (final reminderMap in reminders) {
        final reminder = Reminder.fromMap(reminderMap as Map<String, dynamic>);
        await _reminderDao.insertReminder(reminder);
      }
    }

    // Import expense reminders
    final expenseReminders = data['expenseReminders'] as List?;
    if (expenseReminders != null) {
      for (final expenseReminderMap in expenseReminders) {
        final expenseReminder = ExpenseReminder.fromMap(expenseReminderMap as Map<String, dynamic>);
        await _expenseReminderDao.insertExpenseReminder(expenseReminder);
      }
    }
  }

  // Create a backup of all data
  Future<Backup> createBackup(String name, {String? description}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      // Export all data
      final exportedData = await _exportAllData();
      
      // Create backup file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$name-$timestamp.json';
      final filePath = '${backupDir.path}/$fileName';
      final file = File(filePath);
      
      await file.writeAsString(jsonEncode(exportedData));
      
      // Get file stats
      final stat = await file.stat();
      
      return Backup(
        name: name,
        description: description,
        filePath: filePath,
        size: stat.size,
        createdAt: stat.modified,
      );
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
    }
  }

  // Restore data from a backup file
  Future<bool> restoreBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }
      
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Import all data
      await _importAllData(data);
      
      return true;
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      return false;
    }
  }

  // Clear all data from the database
  Future<void> _clearDatabase() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    
    await db.delete('refueling');
    await db.delete('expense');
    await db.delete('maintenance');
    await db.delete('reminder');
    await db.delete('expense_reminder');
    await db.delete('vehicle');
  }

  // Get list of all backups
  Future<List<Backup>> getAllBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/backups');
      
      if (!await backupDir.exists()) {
        return [];
      }
      
      final files = backupDir.listSync();
      final backups = <Backup>[];
      
      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final stat = await file.stat();
            final name = basenameWithoutExtension(file.path);
            final size = stat.size;
            final createdAt = stat.modified;
            
            backups.add(Backup(
              name: name,
              description: null,
              filePath: file.path,
              size: size,
              createdAt: createdAt,
            ));
          } catch (e) {
            debugPrint('Error reading backup file ${file.path}: $e');
          }
        }
      }
      
      // Sort by creation date (newest first)
      backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return backups;
    } catch (e) {
      debugPrint('Error getting backups: $e');
      return [];
    }
  }

  // Delete a backup
  Future<bool> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting backup: $e');
      return false;
    }
  }
}