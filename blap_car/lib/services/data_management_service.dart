import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/models/expense_reminder.dart';
import 'package:blap_car/models/driver.dart';
import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/database/refueling_dao.dart';
import 'package:blap_car/database/expense_dao.dart';
import 'package:blap_car/database/maintenance_dao.dart';
import 'package:blap_car/database/expense_reminder_dao.dart';
import 'package:blap_car/database/driver_dao.dart';

class DataManagementService {
  final VehicleDao _vehicleDao = VehicleDao();
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final MaintenanceDao _maintenanceDao = MaintenanceDao();
  final ExpenseReminderDao _expenseReminderDao = ExpenseReminderDao();
  final DriverDao _driverDao = DriverDao();

  // Export all data to Excel
  Future<String> exportToExcel() async {
    final excel = Excel.createExcel();
    
    // Export vehicles
    final vehicles = await _vehicleDao.getAllVehicles();
    final vehicleSheet = excel['Vehicles'];
    _addVehicleDataToSheet(vehicleSheet, vehicles);
    
    // Export refuelings
    final refuelings = await _refuelingDao.getAllRefuelings();
    final refuelingSheet = excel['Refuelings'];
    _addRefuelingDataToSheet(refuelingSheet, refuelings);
    
    // Export expenses
    final expenses = await _expenseDao.getAllExpenses();
    final expenseSheet = excel['Expenses'];
    _addExpenseDataToSheet(expenseSheet, expenses);
    
    // Export maintenance
    final maintenances = await _maintenanceDao.getAllMaintenances();
    final maintenanceSheet = excel['Maintenance'];
    _addMaintenanceDataToSheet(maintenanceSheet, maintenances);
    
    // Export reminders
    final reminders = await _expenseReminderDao.getAllExpenseReminders();
    final reminderSheet = excel['Reminders'];
    _addReminderDataToSheet(reminderSheet, reminders);
    
    // Export drivers
    final drivers = await _driverDao.getAllDrivers();
    final driverSheet = excel['Drivers'];
    _addDriverDataToSheet(driverSheet, drivers);
    
    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'blap_car_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final filePath = '${directory.path}/$fileName';
    
    final fileBytes = excel.save();
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!);
    
    return filePath;
  }

  // Export all data to CSV
  Future<String> exportToCsv() async {
    final rows = <List<dynamic>>[];
    
    // Add header
    rows.add(['Type', 'ID', 'Vehicle ID', 'Date', 'Details 1', 'Details 2', 'Details 3', 'Details 4', 'Details 5', 'Details 6']);
    
    // Export vehicles
    final vehicles = await _vehicleDao.getAllVehicles();
    for (final vehicle in vehicles) {
      rows.add([
        'Vehicle', vehicle.id, vehicle.name, vehicle.make, vehicle.model,
        vehicle.year, vehicle.plate, '', '', ''
      ]);
    }
    
    // Export refuelings
    final refuelings = await _refuelingDao.getAllRefuelings();
    for (final refueling in refuelings) {
      rows.add([
        'Refueling', refueling.id, refueling.vehicleId, refueling.date.toIso8601String(),
        refueling.fuelType, refueling.liters, refueling.totalCost, refueling.station,
        refueling.paymentMethod, ''  // Removed driver field
      ]);
    }
    
    // Export expenses
    final expenses = await _expenseDao.getAllExpenses();
    for (final expense in expenses) {
      rows.add([
        'Expense', expense.id, expense.vehicleId, expense.date.toIso8601String(),
        expense.type, expense.cost, expense.odometer,
        expense.location, expense.paymentMethod, ''  // Removed driver field
      ]);
    }
    
    // Export maintenance
    final maintenances = await _maintenanceDao.getAllMaintenances();
    for (final maintenance in maintenances) {
      rows.add([
        'Maintenance', maintenance.id, maintenance.vehicleId, 
        maintenance.date?.toIso8601String() ?? '', maintenance.type, maintenance.cost, '',
        maintenance.status, maintenance.nextDate?.toIso8601String() ?? '', ''
      ]);
    }
    
    // Convert to CSV
    final csv = const ListToCsvConverter().convert(rows);
    
    // Save file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'blap_car_export_${DateTime.now().millisecondsSinceEpoch}.csv';
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsString(csv);
    
    return filePath;
  }

  // Import data from Excel
  Future<void> importFromExcel(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      
      // Process each sheet
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        if (sheet.rows.length <= 1) continue; // Skip empty sheets or only header
        
        // Process based on sheet name
        switch (table) {
          case 'Vehicles':
            await _processVehicleSheet(sheet);
            break;
          case 'Refuelings':
            await _processRefuelingSheet(sheet);
            break;
          case 'Expenses':
            await _processExpenseSheet(sheet);
            break;
          case 'Maintenance':
            await _processMaintenanceSheet(sheet);
            break;
          case 'Reminders':
            await _processReminderSheet(sheet);
            break;
          case 'Drivers':
            await _processDriverSheet(sheet);
            break;
        }
      }
    } catch (e) {
      debugPrint('Error importing from Excel: $e');
      rethrow;
    }
  }

  // Import data from CSV
  Future<void> importFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      final csvString = await file.readAsString();
      final csvData = const CsvToListConverter().convert(csvString);
      
      // Process each row, skip header row
      for (int i = 1; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.length < 4) continue; // Skip incomplete rows
        
        final type = row[0] as String;
        
        // Handle each row based on its type
        switch (type) {
          case 'Vehicle':
            await _processVehicleRow(row);
            break;
          case 'Refueling':
            await _processRefuelingRow(row);
            break;
          case 'Expense':
            await _processExpenseRow(row);
            break;
          case 'Maintenance':
            await _processMaintenanceRow(row);
            break;
        }
      }
    } catch (e) {
      debugPrint('Error importing from CSV: $e');
      rethrow;
    }
  }

  // Process vehicle sheet from Excel
  Future<void> _processVehicleSheet(Sheet sheet) async {
    // Skip header row
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;
      
      try {
        final vehicle = Vehicle(
          name: row[1]?.value?.toString() ?? '',
          make: row[2]?.value?.toString(),
          model: row[3]?.value?.toString(),
          year: row[4]?.value is int ? row[4]!.value as int : 
                row[4]?.value?.toString().isNotEmpty == true ? int.tryParse(row[4]!.value.toString()) : null,
          plate: row[5]?.value?.toString(),
          fuelTankVolume: row[6]?.value is double ? row[6]!.value as double : 
                         row[6]?.value is int ? (row[6]!.value as int).toDouble() :
                         row[6]?.value?.toString().isNotEmpty == true ? double.tryParse(row[6]!.value.toString()) : null,
          vin: row[7]?.value?.toString(),
          renavam: row[8]?.value?.toString(),
          initialOdometer: row[9]?.value is double ? row[9]!.value as double : 
                          row[9]?.value is int ? (row[9]!.value as int).toDouble() :
                          row[9]?.value?.toString().isNotEmpty == true ? double.tryParse(row[9]!.value.toString()) : null,
          createdAt: DateTime.now(),
        );
        
        // Set createdAt if available
        if (row.length > 10 && row[10]?.value?.toString().isNotEmpty == true) {
          try {
            vehicle.createdAt = DateTime.parse(row[10]!.value.toString());
          } catch (e) {
            vehicle.createdAt = DateTime.now();
          }
        }
        
        await _vehicleDao.insertVehicle(vehicle);
      } catch (e) {
        debugPrint('Error processing vehicle row: $e');
      }
    }
  }

  // Process refueling sheet from Excel
  Future<void> _processRefuelingSheet(Sheet sheet) async {
    // Skip header row
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;
      
      try {
        final refueling = Refueling(
          vehicleId: row[1]?.value is int ? row[1]!.value as int : 
                    row[1]?.value?.toString().isNotEmpty == true ? int.tryParse(row[1]!.value.toString()) ?? 0 : 0,
          date: row[2]?.value?.toString().isNotEmpty == true ? DateTime.parse(row[2]!.value.toString()) : DateTime.now(),
          odometer: row[4]?.value is double ? row[4]!.value as double : 
                   row[4]?.value is int ? (row[4]!.value as int).toDouble() :
                   row[4]?.value?.toString().isNotEmpty == true ? double.tryParse(row[4]!.value.toString()) ?? 0.0 : 0.0,
          fuelType: row[8]?.value?.toString(),
          station: row[9]?.value?.toString(),
          paymentMethod: row[12]?.value?.toString(),
          observation: row[13]?.value?.toString(),
          attachmentPath: row[14]?.value?.toString(),
        );
        
        // Set optional fields
        if (row.length > 3 && row[3]?.value?.toString().isNotEmpty == true) {
          try {
            refueling.time = DateTime.parse(row[3]!.value.toString());
          } catch (e) {
            // Ignore time parsing errors
          }
        }
        
        if (row.length > 5 && row[5]?.value != null) {
          refueling.liters = row[5]?.value is double ? row[5]!.value as double : 
                           row[5]?.value is int ? (row[5]!.value as int).toDouble() :
                           row[5]?.value?.toString().isNotEmpty == true ? double.tryParse(row[5]!.value.toString()) : null;
        }
        
        if (row.length > 6 && row[6]?.value != null) {
          refueling.pricePerLiter = row[6]?.value is double ? row[6]!.value as double : 
                                  row[6]?.value is int ? (row[6]!.value as int).toDouble() :
                                  row[6]?.value?.toString().isNotEmpty == true ? double.tryParse(row[6]!.value.toString()) : null;
        }
        
        if (row.length > 7 && row[7]?.value != null) {
          refueling.totalCost = row[7]?.value is double ? row[7]!.value as double : 
                              row[7]?.value is int ? (row[7]!.value as int).toDouble() :
                              row[7]?.value?.toString().isNotEmpty == true ? double.tryParse(row[7]!.value.toString()) : null;
        }
        
        if (row.length > 10 && row[10]?.value != null) {
          refueling.fullTank = row[10]?.value is bool ? row[10]!.value as bool : 
                             row[10]?.value?.toString().toLowerCase() == 'true';
        }
        
        if (row.length > 11 && row[11]?.value != null) {
          refueling.previousRefuelingMissing = row[11]?.value is bool ? row[11]!.value as bool : 
                                             row[11]?.value?.toString().toLowerCase() == 'true';
        }
        
        await _refuelingDao.insertRefueling(refueling);
      } catch (e) {
        debugPrint('Error processing refueling row: $e');
      }
    }
  }

  // Process expense sheet from Excel
  Future<void> _processExpenseSheet(Sheet sheet) async {
    // Skip header row
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;
      
      try {
        final expense = Expense(
          vehicleId: row[1]?.value is int ? row[1]!.value as int : 
                    row[1]?.value?.toString().isNotEmpty == true ? int.tryParse(row[1]!.value.toString()) ?? 0 : 0,
          type: row[2]?.value?.toString(),
          description: row[3]?.value?.toString(),
          date: row[5]?.value?.toString().isNotEmpty == true ? DateTime.parse(row[5]!.value.toString()) : DateTime.now(),
          location: row[8]?.value?.toString(),
          paymentMethod: row[9]?.value?.toString(),
          observation: row[10]?.value?.toString(),
          attachmentPath: row[11]?.value?.toString(),
          category: row[12]?.value?.toString(),
        );
        
        // Set optional fields
        if (row.length > 4 && row[4]?.value != null) {
          expense.cost = row[4]?.value is double ? row[4]!.value as double : 
                        row[4]?.value is int ? (row[4]!.value as int).toDouble() :
                        row[4]?.value?.toString().isNotEmpty == true ? double.tryParse(row[4]!.value.toString()) : null;
        }
        
        if (row.length > 6 && row[6]?.value?.toString().isNotEmpty == true) {
          try {
            expense.time = DateTime.parse(row[6]!.value.toString());
          } catch (e) {
            // Ignore time parsing errors
          }
        }
        
        if (row.length > 7 && row[7]?.value != null) {
          expense.odometer = row[7]?.value is double ? row[7]!.value as double : 
                           row[7]?.value is int ? (row[7]!.value as int).toDouble() :
                           row[7]?.value?.toString().isNotEmpty == true ? double.tryParse(row[7]!.value.toString()) : null;
        }
        
        await _expenseDao.insertExpense(expense);
      } catch (e) {
        debugPrint('Error processing expense row: $e');
      }
    }
  }

  // Process maintenance sheet from Excel
  Future<void> _processMaintenanceSheet(Sheet sheet) async {
    // Skip header row
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;
      
      try {
        final maintenance = Maintenance(
          vehicleId: row[1]?.value is int ? row[1]!.value as int : 
                    row[1]?.value?.toString().isNotEmpty == true ? int.tryParse(row[1]!.value.toString()) ?? 0 : 0,
          type: row[2]?.value?.toString(),
          description: row[3]?.value?.toString(),
        );
        
        // Set optional fields
        if (row.length > 4 && row[4]?.value != null) {
          maintenance.cost = row[4]?.value is double ? row[4]!.value as double : 
                           row[4]?.value is int ? (row[4]!.value as int).toDouble() :
                           row[4]?.value?.toString().isNotEmpty == true ? double.tryParse(row[4]!.value.toString()) : null;
        }
        
        if (row.length > 5 && row[5]?.value?.toString().isNotEmpty == true) {
          try {
            maintenance.date = DateTime.parse(row[5]!.value.toString());
          } catch (e) {
            // Ignore date parsing errors
          }
        }
        
        if (row.length > 6 && row[6]?.value?.toString().isNotEmpty == true) {
          try {
            maintenance.nextDate = DateTime.parse(row[6]!.value.toString());
          } catch (e) {
            // Ignore date parsing errors
          }
        }
        
        if (row.length > 7 && row[7]?.value != null) {
          maintenance.odometer = row[7]?.value is int ? row[7]!.value as int : 
                               row[7]?.value?.toString().isNotEmpty == true ? int.tryParse(row[7]!.value.toString()) : null;
        }
        
        if (row.length > 8 && row[8]?.value?.toString().isNotEmpty == true) {
          maintenance.status = row[8]!.value.toString();
        }
        
        await _maintenanceDao.insertMaintenance(maintenance);
      } catch (e) {
        debugPrint('Error processing maintenance row: $e');
      }
    }
  }

  // Process reminder sheet from Excel
  Future<void> _processReminderSheet(Sheet sheet) async {
    // Skip header row
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;
      
      try {
        final reminder = ExpenseReminder(
          vehicleId: row[1]?.value is int ? row[1]!.value as int : 
                    row[1]?.value?.toString().isNotEmpty == true ? int.tryParse(row[1]!.value.toString()) ?? 0 : 0,
          expenseType: row[2]?.value?.toString(),
          isRecurring: row[3]?.value is bool ? row[3]!.value as bool : 
                      row[3]?.value?.toString().toLowerCase() == 'true',
          triggerKmEnabled: row[4]?.value is bool ? row[4]!.value as bool : 
                           row[4]?.value?.toString().toLowerCase() == 'true',
          triggerDateEnabled: row[6]?.value is bool ? row[6]!.value as bool : 
                            row[6]?.value?.toString().toLowerCase() == 'true',
          recurringKmEnabled: row[8]?.value is bool ? row[8]!.value as bool : 
                            row[8]?.value?.toString().toLowerCase() == 'true',
          recurringTimeEnabled: row[10]?.value is bool ? row[10]!.value as bool : 
                              row[10]?.value?.toString().toLowerCase() == 'true',
          createdAt: row[14]?.value?.toString().isNotEmpty == true ? DateTime.parse(row[14]!.value.toString()) : DateTime.now(),
        );
        
        // Set optional fields
        if (row.length > 5 && row[5]?.value != null) {
          reminder.triggerKm = row[5]?.value is double ? row[5]!.value as double : 
                             row[5]?.value is int ? (row[5]!.value as int).toDouble() :
                             row[5]?.value?.toString().isNotEmpty == true ? double.tryParse(row[5]!.value.toString()) : null;
        }
        
        if (row.length > 7 && row[7]?.value?.toString().isNotEmpty == true) {
          try {
            reminder.triggerDate = DateTime.parse(row[7]!.value.toString());
          } catch (e) {
            // Ignore date parsing errors
          }
        }
        
        if (row.length > 9 && row[9]?.value != null) {
          reminder.recurringKmInterval = row[9]?.value is int ? row[9]!.value as int : 
                                       row[9]?.value?.toString().isNotEmpty == true ? int.tryParse(row[9]!.value.toString()) : null;
        }
        
        if (row.length > 11 && row[11]?.value != null) {
          reminder.recurringDaysInterval = row[11]?.value is int ? row[11]!.value as int : 
                                         row[11]?.value?.toString().isNotEmpty == true ? int.tryParse(row[11]!.value.toString()) : null;
        }
        
        if (row.length > 12 && row[12]?.value != null) {
          reminder.recurringMonthsInterval = row[12]?.value is int ? row[12]!.value as int : 
                                           row[12]?.value?.toString().isNotEmpty == true ? int.tryParse(row[12]!.value.toString()) : null;
        }
        
        if (row.length > 13 && row[13]?.value != null) {
          reminder.recurringYearsInterval = row[13]?.value is int ? row[13]!.value as int : 
                                          row[13]?.value?.toString().isNotEmpty == true ? int.tryParse(row[13]!.value.toString()) : null;
        }
        
        if (row.length > 15 && row[15]?.value?.toString().isNotEmpty == true) {
          try {
            reminder.updatedAt = DateTime.parse(row[15]!.value.toString());
          } catch (e) {
            // Ignore date parsing errors
          }
        }
        
        await _expenseReminderDao.insertExpenseReminder(reminder);
      } catch (e) {
        debugPrint('Error processing reminder row: $e');
      }
    }
  }

  // Process driver sheet from Excel
  Future<void> _processDriverSheet(Sheet sheet) async {
    // Skip header row
    for (int i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;
      
      try {
        final driver = Driver(
          name: row[1]?.value?.toString() ?? '',
          licenseNumber: row[2]?.value?.toString(),
          contactInfo: row[4]?.value?.toString(),
          createdAt: row[5]?.value?.toString().isNotEmpty == true ? DateTime.parse(row[5]!.value.toString()) : DateTime.now(),
        );
        
        // Set optional fields
        if (row.length > 3 && row[3]?.value?.toString().isNotEmpty == true) {
          try {
            driver.licenseExpiryDate = DateTime.parse(row[3]!.value.toString());
          } catch (e) {
            // Ignore date parsing errors
          }
        }
        
        await _driverDao.insertDriver(driver);
      } catch (e) {
        debugPrint('Error processing driver row: $e');
      }
    }
  }

  // Process vehicle row from CSV
  Future<void> _processVehicleRow(List<dynamic> row) async {
    try {
      final vehicle = Vehicle(
        name: row[2]?.toString() ?? '',
        make: row[3]?.toString(),
        model: row[4]?.toString(),
        year: row[5] is int ? row[5] as int : 
              row[5]?.toString().isNotEmpty == true ? int.tryParse(row[5].toString()) : null,
        plate: row[6]?.toString(),
        createdAt: DateTime.now(),
      );
      
      await _vehicleDao.insertVehicle(vehicle);
    } catch (e) {
      debugPrint('Error processing vehicle row: $e');
    }
  }

  // Process refueling row from CSV
  Future<void> _processRefuelingRow(List<dynamic> row) async {
    try {
      final refueling = Refueling(
        vehicleId: row[2] is int ? row[2] as int : 
                  row[2]?.toString().isNotEmpty == true ? int.tryParse(row[2].toString()) ?? 0 : 0,
        date: row[3]?.toString().isNotEmpty == true ? DateTime.parse(row[3].toString()) : DateTime.now(),
        odometer: 0.0, // Required field
        fuelType: row[4]?.toString(),
        station: row[7]?.toString(),
        paymentMethod: row[8]?.toString(),
      );
      
      // Set optional fields
      if (row.length > 5 && row[5] != null) {
        refueling.liters = row[5] is double ? row[5] as double : 
                         row[5] is int ? (row[5] as int).toDouble() :
                         row[5]?.toString().isNotEmpty == true ? double.tryParse(row[5].toString()) : null;
      }
      
      if (row.length > 6 && row[6] != null) {
        refueling.totalCost = row[6] is double ? row[6] as double : 
                            row[6] is int ? (row[6] as int).toDouble() :
                            row[6]?.toString().isNotEmpty == true ? double.tryParse(row[6].toString()) : null;
      }
      
      await _refuelingDao.insertRefueling(refueling);
    } catch (e) {
      debugPrint('Error processing refueling row: $e');
    }
  }

  // Process expense row from CSV
  Future<void> _processExpenseRow(List<dynamic> row) async {
    try {
      final expense = Expense(
        vehicleId: row[2] is int ? row[2] as int : 
                  row[2]?.toString().isNotEmpty == true ? int.tryParse(row[2].toString()) ?? 0 : 0,
        type: row[4]?.toString(),
        cost: row[5] is double ? row[5] as double : 
              row[5] is int ? (row[5] as int).toDouble() :
              row[5]?.toString().isNotEmpty == true ? double.tryParse(row[5].toString()) : null,
        date: row[3]?.toString().isNotEmpty == true ? DateTime.parse(row[3].toString()) : DateTime.now(),
        odometer: row[6] is double ? row[6] as double : 
                 row[6] is int ? (row[6] as int).toDouble() :
                 row[6]?.toString().isNotEmpty == true ? double.tryParse(row[6].toString()) : null,
        location: row[7]?.toString(),
        paymentMethod: row[8]?.toString(),
      );
      
      await _expenseDao.insertExpense(expense);
    } catch (e) {
      debugPrint('Error processing expense row: $e');
    }
  }

  // Process maintenance row from CSV
  Future<void> _processMaintenanceRow(List<dynamic> row) async {
    try {
      final maintenance = Maintenance(
        vehicleId: row[2] is int ? row[2] as int : 
                  row[2]?.toString().isNotEmpty == true ? int.tryParse(row[2].toString()) ?? 0 : 0,
        type: row[4]?.toString(),
        cost: row[5] is double ? row[5] as double : 
              row[5] is int ? (row[5] as int).toDouble() :
              row[5]?.toString().isNotEmpty == true ? double.tryParse(row[5].toString()) : null,
        date: row[3]?.toString().isNotEmpty == true ? DateTime.parse(row[3].toString()) : null,
        status: row[7]?.toString(),
        nextDate: row[8]?.toString().isNotEmpty == true ? DateTime.parse(row[8].toString()) : null,
      );
      
      await _maintenanceDao.insertMaintenance(maintenance);
    } catch (e) {
      debugPrint('Error processing maintenance row: $e');
    }
  }

  // Helper methods to add data to Excel sheets
  void _addVehicleDataToSheet(Sheet sheet, List<Vehicle> vehicles) {
    // Add header
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Name'),
      TextCellValue('Make'),
      TextCellValue('Model'),
      TextCellValue('Year'),
      TextCellValue('Plate'),
      TextCellValue('Fuel Tank Volume'),
      TextCellValue('VIN'),
      TextCellValue('RENAVAM'),
      TextCellValue('Initial Odometer'),
      TextCellValue('Created At')
    ]);
    
    // Add data
    for (final vehicle in vehicles) {
      sheet.appendRow([
        vehicle.id != null ? IntCellValue(vehicle.id!) : TextCellValue(''),
        TextCellValue(vehicle.name),
        vehicle.make != null ? TextCellValue(vehicle.make!) : TextCellValue(''),
        vehicle.model != null ? TextCellValue(vehicle.model!) : TextCellValue(''),
        vehicle.year != null ? IntCellValue(vehicle.year!) : TextCellValue(''),
        vehicle.plate != null ? TextCellValue(vehicle.plate!) : TextCellValue(''),
        vehicle.fuelTankVolume != null ? DoubleCellValue(vehicle.fuelTankVolume!) : TextCellValue(''),
        vehicle.vin != null ? TextCellValue(vehicle.vin!) : TextCellValue(''),
        vehicle.renavam != null ? TextCellValue(vehicle.renavam!) : TextCellValue(''),
        vehicle.initialOdometer != null ? DoubleCellValue(vehicle.initialOdometer!) : TextCellValue(''),
        TextCellValue(vehicle.createdAt.toIso8601String()),
      ]);
    }
  }

  void _addRefuelingDataToSheet(Sheet sheet, List<Refueling> refuelings) {
    // Add header
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Vehicle ID'),
      TextCellValue('Date'),
      TextCellValue('Time'),
      TextCellValue('Odometer'),
      TextCellValue('Liters'),
      TextCellValue('Price per Liter'),
      TextCellValue('Total Cost'),
      TextCellValue('Fuel Type'),
      TextCellValue('Station'),
      TextCellValue('Full Tank'),
      TextCellValue('Previous Refueling Missing'),
      TextCellValue('Payment Method'),
      TextCellValue('Observation'),
      TextCellValue('Attachment Path')
    ]);
    
    // Add refueling data
    for (var refueling in refuelings) {
      sheet.appendRow([
        refueling.id != null ? IntCellValue(refueling.id!) : TextCellValue(''),
        IntCellValue(refueling.vehicleId),
        TextCellValue(refueling.date.toIso8601String()),
        refueling.time != null ? TextCellValue(refueling.time!.toIso8601String()) : TextCellValue(''),
        DoubleCellValue(refueling.odometer),
        refueling.liters != null ? DoubleCellValue(refueling.liters!) : TextCellValue(''),
        refueling.pricePerLiter != null ? DoubleCellValue(refueling.pricePerLiter!) : TextCellValue(''),
        refueling.totalCost != null ? DoubleCellValue(refueling.totalCost!) : TextCellValue(''),
        refueling.fuelType != null ? TextCellValue(refueling.fuelType!) : TextCellValue(''),
        refueling.station != null ? TextCellValue(refueling.station!) : TextCellValue(''),
        refueling.fullTank != null ? BoolCellValue(refueling.fullTank!) : TextCellValue(''),
        refueling.previousRefuelingMissing != null ? BoolCellValue(refueling.previousRefuelingMissing!) : TextCellValue(''),
        refueling.paymentMethod != null ? TextCellValue(refueling.paymentMethod!) : TextCellValue(''),
        refueling.observation != null ? TextCellValue(refueling.observation!) : TextCellValue(''),
        refueling.attachmentPath != null ? TextCellValue(refueling.attachmentPath!) : TextCellValue(''),
      ]);
    }
  }

  void _addExpenseDataToSheet(Sheet sheet, List<Expense> expenses) {
    // Add header
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Vehicle ID'),
      TextCellValue('Type'),
      TextCellValue('Description'),
      TextCellValue('Cost'),
      TextCellValue('Date'),
      TextCellValue('Time'),
      TextCellValue('Odometer'),
      TextCellValue('Location'),
      TextCellValue('Payment Method'),
      TextCellValue('Observation'),
      TextCellValue('Attachment Path'),
      TextCellValue('Category')
    ]);
    
    // Add expense data
    for (var expense in expenses) {
      sheet.appendRow([
        expense.id != null ? IntCellValue(expense.id!) : TextCellValue(''),
        IntCellValue(expense.vehicleId),
        expense.type != null ? TextCellValue(expense.type!) : TextCellValue(''),
        expense.description != null ? TextCellValue(expense.description!) : TextCellValue(''),
        expense.cost != null ? DoubleCellValue(expense.cost!) : TextCellValue(''),
        TextCellValue(expense.date.toIso8601String()),
        expense.time != null ? TextCellValue(expense.time!.toIso8601String()) : TextCellValue(''),
        expense.odometer != null ? DoubleCellValue(expense.odometer!) : TextCellValue(''),
        expense.location != null ? TextCellValue(expense.location!) : TextCellValue(''),
        expense.paymentMethod != null ? TextCellValue(expense.paymentMethod!) : TextCellValue(''),
        expense.observation != null ? TextCellValue(expense.observation!) : TextCellValue(''),
        expense.attachmentPath != null ? TextCellValue(expense.attachmentPath!) : TextCellValue(''),
        expense.category != null ? TextCellValue(expense.category!) : TextCellValue(''),
      ]);
    }
  }

  void _addMaintenanceDataToSheet(Sheet sheet, List<Maintenance> maintenances) {
    // Add header
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Vehicle ID'),
      TextCellValue('Type'),
      TextCellValue('Description'),
      TextCellValue('Cost'),
      TextCellValue('Date'),
      TextCellValue('Next Date'),
      TextCellValue('Odometer'),
      TextCellValue('Status')
    ]);
    
    // Add data
    for (final maintenance in maintenances) {
      sheet.appendRow([
        maintenance.id != null ? IntCellValue(maintenance.id!) : TextCellValue(''),
        IntCellValue(maintenance.vehicleId),
        maintenance.type != null ? TextCellValue(maintenance.type!) : TextCellValue(''),
        maintenance.description != null ? TextCellValue(maintenance.description!) : TextCellValue(''),
        maintenance.cost != null ? DoubleCellValue(maintenance.cost!) : TextCellValue(''),
        maintenance.date != null ? TextCellValue(maintenance.date!.toIso8601String()) : TextCellValue(''),
        maintenance.nextDate != null ? TextCellValue(maintenance.nextDate!.toIso8601String()) : TextCellValue(''),
        maintenance.odometer != null ? IntCellValue(maintenance.odometer!) : TextCellValue(''),
        maintenance.status != null ? TextCellValue(maintenance.status!) : TextCellValue(''),
      ]);
    }
  }

  void _addReminderDataToSheet(Sheet sheet, List<ExpenseReminder> reminders) {
    // Add header
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Vehicle ID'),
      TextCellValue('Expense Type'),
      TextCellValue('Is Recurring'),
      TextCellValue('Trigger KM Enabled'),
      TextCellValue('Trigger KM'),
      TextCellValue('Trigger Date Enabled'),
      TextCellValue('Trigger Date'),
      TextCellValue('Recurring KM Enabled'),
      TextCellValue('Recurring KM Interval'),
      TextCellValue('Recurring Time Enabled'),
      TextCellValue('Recurring Days Interval'),
      TextCellValue('Recurring Months Interval'),
      TextCellValue('Recurring Years Interval'),
      TextCellValue('Created At'),
      TextCellValue('Updated At')
    ]);
    
    // Add data
    for (final reminder in reminders) {
      sheet.appendRow([
        reminder.id != null ? IntCellValue(reminder.id!) : TextCellValue(''),
        IntCellValue(reminder.vehicleId),
        reminder.expenseType != null ? TextCellValue(reminder.expenseType!) : TextCellValue(''),
        BoolCellValue(reminder.isRecurring == true),
        BoolCellValue(reminder.triggerKmEnabled == true),
        reminder.triggerKm != null ? DoubleCellValue(reminder.triggerKm!) : TextCellValue(''),
        BoolCellValue(reminder.triggerDateEnabled == true),
        reminder.triggerDate != null ? TextCellValue(reminder.triggerDate!.toIso8601String()) : TextCellValue(''),
        BoolCellValue(reminder.recurringKmEnabled == true),
        reminder.recurringKmInterval != null ? IntCellValue(reminder.recurringKmInterval!) : TextCellValue(''),
        BoolCellValue(reminder.recurringTimeEnabled == true),
        reminder.recurringDaysInterval != null ? IntCellValue(reminder.recurringDaysInterval!) : TextCellValue(''),
        reminder.recurringMonthsInterval != null ? IntCellValue(reminder.recurringMonthsInterval!) : TextCellValue(''),
        reminder.recurringYearsInterval != null ? IntCellValue(reminder.recurringYearsInterval!) : TextCellValue(''),
        TextCellValue(reminder.createdAt.toIso8601String()),
        reminder.updatedAt != null ? TextCellValue(reminder.updatedAt!.toIso8601String()) : TextCellValue(''),
      ]);
    }
  }

  void _addDriverDataToSheet(Sheet sheet, List<Driver> drivers) {
    // Add header
    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Name'),
      TextCellValue('License Number'),
      TextCellValue('License Expiry Date'),
      TextCellValue('Contact Info'),
      TextCellValue('Created At')
    ]);
    
    // Add data
    for (final driver in drivers) {
      sheet.appendRow([
        driver.id != null ? IntCellValue(driver.id!) : TextCellValue(''),
        TextCellValue(driver.name),
        driver.licenseNumber != null ? TextCellValue(driver.licenseNumber!) : TextCellValue(''),
        driver.licenseExpiryDate != null ? TextCellValue(driver.licenseExpiryDate!.toIso8601String()) : TextCellValue(''),
        driver.contactInfo != null ? TextCellValue(driver.contactInfo!) : TextCellValue(''),
        TextCellValue(driver.createdAt.toIso8601String()),
      ]);
    }
  }
}