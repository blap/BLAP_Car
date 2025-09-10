import 'dart:convert';
import 'package:flutter/foundation.dart';
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
import 'package:blap_car/database/sync_record_dao.dart';
import 'package:blap_car/models/sync_record.dart';

class SyncService {
  final SyncRecordDao _syncRecordDao = SyncRecordDao();
  final VehicleDao _vehicleDao = VehicleDao();
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final MaintenanceDao _maintenanceDao = MaintenanceDao();
  final ReminderDao _reminderDao = ReminderDao();
  final ExpenseReminderDao _expenseReminderDao = ExpenseReminderDao();

  // Add a sync record for a vehicle operation
  Future<void> addVehicleSyncRecord(Vehicle vehicle, String operation) async {
    final syncRecord = SyncRecord(
      tableName: 'vehicle',
      recordId: vehicle.id ?? 0,
      operation: operation,
      data: jsonEncode(vehicle.toMap()),
      timestamp: DateTime.now(),
    );
    await _syncRecordDao.insertSyncRecord(syncRecord);
  }

  // Add a sync record for a refueling operation
  Future<void> addRefuelingSyncRecord(Refueling refueling, String operation) async {
    final syncRecord = SyncRecord(
      tableName: 'refueling',
      recordId: refueling.id ?? 0,
      operation: operation,
      data: jsonEncode(refueling.toMap()),
      timestamp: DateTime.now(),
    );
    await _syncRecordDao.insertSyncRecord(syncRecord);
  }

  // Add a sync record for an expense operation
  Future<void> addExpenseSyncRecord(Expense expense, String operation) async {
    final syncRecord = SyncRecord(
      tableName: 'expense',
      recordId: expense.id ?? 0,
      operation: operation,
      data: jsonEncode(expense.toMap()),
      timestamp: DateTime.now(),
    );
    await _syncRecordDao.insertSyncRecord(syncRecord);
  }

  // Add a sync record for a maintenance operation
  Future<void> addMaintenanceSyncRecord(Maintenance maintenance, String operation) async {
    final syncRecord = SyncRecord(
      tableName: 'maintenance',
      recordId: maintenance.id ?? 0,
      operation: operation,
      data: jsonEncode(maintenance.toMap()),
      timestamp: DateTime.now(),
    );
    await _syncRecordDao.insertSyncRecord(syncRecord);
  }

  // Add a sync record for a reminder operation
  Future<void> addReminderSyncRecord(Reminder reminder, String operation) async {
    final syncRecord = SyncRecord(
      tableName: 'reminder',
      recordId: reminder.id ?? 0,
      operation: operation,
      data: jsonEncode(reminder.toMap()),
      timestamp: DateTime.now(),
    );
    await _syncRecordDao.insertSyncRecord(syncRecord);
  }

  // Add a sync record for an expense reminder operation
  Future<void> addExpenseReminderSyncRecord(ExpenseReminder reminder, String operation) async {
    final syncRecord = SyncRecord(
      tableName: 'expense_reminder',
      recordId: reminder.id ?? 0,
      operation: operation,
      data: jsonEncode(reminder.toMap()),
      timestamp: DateTime.now(),
    );
    await _syncRecordDao.insertSyncRecord(syncRecord);
  }

  // Get all unsynced records
  Future<List<SyncRecord>> getUnsyncedRecords() async {
    return await _syncRecordDao.getUnsyncedRecords();
  }

  // Sync records with a remote server (placeholder implementation)
  Future<bool> syncWithServer() async {
    try {
      final unsyncedRecords = await getUnsyncedRecords();
      
      // In a real implementation, you would send these records to a server
      // For now, we'll just mark them as synced
      if (unsyncedRecords.isNotEmpty) {
        final ids = unsyncedRecords.map((record) => record.id!).toList();
        await _syncRecordDao.markRecordsAsSynced(ids);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error syncing with server: $e');
      return false;
    }
  }

  // Apply remote changes to local database (placeholder implementation)
  Future<void> applyRemoteChanges(List<Map<String, dynamic>> changes) async {
    for (final change in changes) {
      final tableName = change['table_name'];
      final operation = change['operation'];
      final data = change['data'];
      
      try {
        switch (tableName) {
          case 'vehicle':
            final vehicle = Vehicle.fromMap(jsonDecode(data));
            if (operation == 'INSERT' || operation == 'UPDATE') {
              await _vehicleDao.insertVehicle(vehicle);
            } else if (operation == 'DELETE') {
              if (vehicle.id != null) {
                await _vehicleDao.deleteVehicle(vehicle.id!);
              }
            }
            break;
            
          case 'refueling':
            final refueling = Refueling.fromMap(jsonDecode(data));
            if (operation == 'INSERT' || operation == 'UPDATE') {
              await _refuelingDao.insertRefueling(refueling);
            } else if (operation == 'DELETE') {
              if (refueling.id != null) {
                await _refuelingDao.deleteRefueling(refueling.id!);
              }
            }
            break;
            
          case 'expense':
            final expense = Expense.fromMap(jsonDecode(data));
            if (operation == 'INSERT' || operation == 'UPDATE') {
              await _expenseDao.insertExpense(expense);
            } else if (operation == 'DELETE') {
              if (expense.id != null) {
                await _expenseDao.deleteExpense(expense.id!);
              }
            }
            break;
            
          case 'maintenance':
            final maintenance = Maintenance.fromMap(jsonDecode(data));
            if (operation == 'INSERT' || operation == 'UPDATE') {
              await _maintenanceDao.insertMaintenance(maintenance);
            } else if (operation == 'DELETE') {
              if (maintenance.id != null) {
                await _maintenanceDao.deleteMaintenance(maintenance.id!);
              }
            }
            break;
            
          case 'reminder':
            final reminder = Reminder.fromMap(jsonDecode(data));
            if (operation == 'INSERT' || operation == 'UPDATE') {
              await _reminderDao.insertReminder(reminder);
            } else if (operation == 'DELETE') {
              if (reminder.id != null) {
                await _reminderDao.deleteReminder(reminder.id!);
              }
            }
            break;
            
          case 'expense_reminder':
            final reminder = ExpenseReminder.fromMap(jsonDecode(data));
            if (operation == 'INSERT' || operation == 'UPDATE') {
              await _expenseReminderDao.insertExpenseReminder(reminder);
            } else if (operation == 'DELETE') {
              if (reminder.id != null) {
                await _expenseReminderDao.deleteExpenseReminder(reminder.id!);
              }
            }
            break;
        }
      } catch (e) {
        debugPrint('Error applying remote change: $e');
      }
    }
  }
}
