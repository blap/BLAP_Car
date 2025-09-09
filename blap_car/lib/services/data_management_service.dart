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
    // For simplicity, we'll create a single CSV with all data
    // In a real application, you might want separate CSV files for each entity
    
    final List<List<dynamic>> rows = [];
    
    // Add header
    rows.add([
      'Type', 'ID', 'Vehicle ID', 'Date', 'Description', 'Cost', 'Odometer', 
      'Additional Info 1', 'Additional Info 2', 'Additional Info 3'
    ]);
    
    // Export vehicles
    final vehicles = await _vehicleDao.getAllVehicles();
    for (final vehicle in vehicles) {
      rows.add([
        'Vehicle', vehicle.id, '', '', vehicle.name, '', '',
        vehicle.make, vehicle.model, vehicle.plate
      ]);
    }
    
    // Export refuelings
    final refuelings = await _refuelingDao.getAllRefuelings();
    for (final refueling in refuelings) {
      rows.add([
        'Refueling', refueling.id, refueling.vehicleId, refueling.date.toIso8601String(),
        refueling.fuelType, refueling.totalCost, refueling.odometer,
        refueling.liters, refueling.pricePerLiter, refueling.station
      ]);
    }
    
    // Export expenses
    final expenses = await _expenseDao.getAllExpenses();
    for (final expense in expenses) {
      rows.add([
        'Expense', expense.id, expense.vehicleId, expense.date.toIso8601String(),
        expense.type, expense.cost, expense.odometer,
        expense.location, expense.driver, expense.paymentMethod
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
    // This is a simplified implementation
    // In a real application, you would need to parse the Excel file
    // and handle data validation, conflicts, etc.
    
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    
    // Process each sheet
    for (var table in excel.tables.keys) {
      // Handle each sheet based on its name
      // This would require implementing the actual parsing logic
      debugPrint('Processing sheet: $table');
    }
  }

  // Import data from CSV
  Future<void> importFromCsv(String filePath) async {
    // This is a simplified implementation
    // In a real application, you would need to parse the CSV file
    // and handle data validation, conflicts, etc.
    
    final file = File(filePath);
    final csvString = await file.readAsString();
    final csvData = const CsvToListConverter().convert(csvString);
    
    // Process each row
    // Skip header row
    for (int i = 1; i < csvData.length; i++) {
      final row = csvData[i];
      // Handle each row based on its type
      // This would require implementing the actual parsing logic
      debugPrint('Processing row: $row');
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
      TextCellValue('Driver'),
      TextCellValue('Payment Method'),
      TextCellValue('Observation'),
      TextCellValue('Attachment Path')
    ]);
    
    // Add data
    for (final refueling in refuelings) {
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
        BoolCellValue(refueling.fullTank == true),
        BoolCellValue(refueling.previousRefuelingMissing == true),
        refueling.driver != null ? TextCellValue(refueling.driver!) : TextCellValue(''),
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
      TextCellValue('Driver'),
      TextCellValue('Payment Method'),
      TextCellValue('Observation'),
      TextCellValue('Attachment Path'),
      TextCellValue('Category')
    ]);
    
    // Add data
    for (final expense in expenses) {
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
        expense.driver != null ? TextCellValue(expense.driver!) : TextCellValue(''),
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