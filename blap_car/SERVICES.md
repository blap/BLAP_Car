# Services API Documentation

## Overview
This document describes the services layer of the BLAP Car application. Services implement business logic and act as intermediaries between the UI layer (providers/screens) and the data layer (DAOs).

## Service Classes

### 1. VehicleService
Manages vehicle-related operations.

**Methods:**
- `Future<List<Vehicle>> getAllVehicles()`: Get all vehicles
- `Future<Vehicle?> getVehicleById(int id)`: Get a vehicle by ID
- `Future<int> addVehicle(Vehicle vehicle)`: Add a new vehicle
- `Future<int> updateVehicle(Vehicle vehicle)`: Update an existing vehicle
- `Future<int> deleteVehicle(int id)`: Delete a vehicle

### 2. RefuelingService
Manages refueling-related operations.

**Methods:**
- `Future<List<Refueling>> getAllRefuelings()`: Get all refueling records
- `Future<List<Refueling>> getRefuelingsByVehicleId(int vehicleId)`: Get refueling records for a specific vehicle
- `Future<Refueling?> getRefuelingById(int id)`: Get a refueling record by ID
- `Future<int> addRefueling(Refueling refueling)`: Add a new refueling record
- `Future<int> updateRefueling(Refueling refueling)`: Update an existing refueling record
- `Future<int> deleteRefueling(int id)`: Delete a refueling record

### 3. ExpenseService
Manages expense-related operations.

**Methods:**
- `Future<List<Expense>> getAllExpenses()`: Get all expenses
- `Future<List<Expense>> getExpensesByVehicleId(int vehicleId)`: Get expenses for a specific vehicle
- `Future<Expense?> getExpenseById(int id)`: Get an expense by ID
- `Future<int> addExpense(Expense expense)`: Add a new expense
- `Future<int> updateExpense(Expense expense)`: Update an existing expense
- `Future<int> deleteExpense(int id)`: Delete an expense

### 4. MaintenanceService
Manages maintenance-related operations.

**Methods:**
- `Future<List<Maintenance>> getAllMaintenances()`: Get all maintenance records
- `Future<List<Maintenance>> getMaintenancesByVehicleId(int vehicleId)`: Get maintenance records for a specific vehicle
- `Future<Maintenance?> getMaintenanceById(int id)`: Get a maintenance record by ID
- `Future<int> addMaintenance(Maintenance maintenance)`: Add a new maintenance record
- `Future<int> updateMaintenance(Maintenance maintenance)`: Update an existing maintenance record
- `Future<int> deleteMaintenance(int id)`: Delete a maintenance record

### 5. ExpenseReminderService
Manages expense reminder-related operations.

**Methods:**
- `Future<List<ExpenseReminder>> getAllExpenseReminders()`: Get all expense reminders
- `Future<List<ExpenseReminder>> getExpenseRemindersByVehicleId(int vehicleId)`: Get expense reminders for a specific vehicle
- `Future<ExpenseReminder?> getExpenseReminderById(int id)`: Get an expense reminder by ID
- `Future<int> addExpenseReminder(ExpenseReminder reminder)`: Add a new expense reminder
- `Future<int> updateExpenseReminder(ExpenseReminder reminder)`: Update an existing expense reminder
- `Future<int> deleteExpenseReminder(int id)`: Delete an expense reminder

### 6. ChecklistService
Manages checklist-related operations.

**Methods:**

**Checklist methods:**
- `Future<List<Checklist>> getAllChecklists()`: Get all checklists
- `Future<Checklist?> getChecklistById(int id)`: Get a checklist by ID
- `Future<int> addChecklist(Checklist checklist)`: Add a new checklist
- `Future<int> updateChecklist(Checklist checklist)`: Update an existing checklist
- `Future<int> deleteChecklist(int id)`: Delete a checklist

**ChecklistItem methods:**
- `Future<List<ChecklistItem>> getChecklistItemsByChecklistId(int checklistId)`: Get items for a specific checklist
- `Future<ChecklistItem?> getChecklistItemById(int id)`: Get a checklist item by ID
- `Future<int> addChecklistItem(ChecklistItem item)`: Add a new checklist item
- `Future<int> updateChecklistItem(ChecklistItem item)`: Update an existing checklist item
- `Future<int> deleteChecklistItem(int id)`: Delete a checklist item

**ChecklistCompletion methods:**
- `Future<List<ChecklistCompletion>> getChecklistCompletionsByVehicleId(int vehicleId)`: Get completions for a specific vehicle
- `Future<ChecklistCompletion?> getChecklistCompletionById(int id)`: Get a checklist completion by ID
- `Future<int> addChecklistCompletion(ChecklistCompletion completion)`: Add a new checklist completion

**ChecklistItemCompletion methods:**
- `Future<List<ChecklistItemCompletion>> getChecklistItemCompletionsByCompletionId(int completionId)`: Get item completions for a specific completion
- `Future<int> addChecklistItemCompletion(ChecklistItemCompletion itemCompletion)`: Add a new checklist item completion
- `Future<int> updateChecklistItemCompletion(ChecklistItemCompletion itemCompletion)`: Update an existing checklist item completion

### 7. ReportingService
Generates reports and statistics.

**Methods:**
- `Future<Map<String, dynamic>> calculateFuelEfficiencyStats(int vehicleId)`: Calculate fuel efficiency statistics for a vehicle
- `Future<Map<String, dynamic>> calculateExpenseStats(int vehicleId)`: Calculate expense statistics for a vehicle
- `Future<Map<String, dynamic>> calculateGeneralStats(int vehicleId)`: Calculate general statistics for a vehicle
- `Future<List<Refueling>> getRefuelingsByVehicleId(int vehicleId)`: Get refueling records for report generation
- `Future<List<Expense>> getExpensesByVehicleId(int vehicleId)`: Get expenses for report generation
- `Future<List<Vehicle>> getAllVehicles()`: Get all vehicles for fleet reports

### 8. DataManagementService
Handles data import/export operations.

**Methods:**
- `Future<String> exportToExcel(List<Vehicle> vehicles, String filePath)`: Export data to Excel format
- `Future<String> exportToCsv(List<Vehicle> vehicles, String filePath)`: Export data to CSV format
- `Future<List<Vehicle>> importFromExcel(String filePath)`: Import data from Excel format
- `Future<List<Vehicle>> importFromCsv(String filePath)`: Import data from CSV format

### 9. NotificationService
Manages local notifications.

**Methods:**
- `Future<void> initialize()`: Initialize notification service
- `Future<void> scheduleReminderNotification(ExpenseReminder reminder)`: Schedule a reminder notification
- `Future<void> cancelNotification(int id)`: Cancel a scheduled notification
- `Future<void> showNotification(String title, String body)`: Show an immediate notification

### 10. PermissionService
Handles Android permission requests.

**Methods:**
- `Future<bool> requestStoragePermission()`: Request storage permission
- `Future<bool> requestLocationPermission()`: Request location permission
- `Future<PermissionStatus> checkStoragePermission()`: Check storage permission status
- `Future<PermissionStatus> checkLocationPermission()`: Check location permission status

### 11. FileSharingService
Handles file sharing operations.

**Methods:**
- `Future<void> shareFile(String filePath, String title)`: Share a file
- `Future<String?> getExternalStoragePath()`: Get external storage path

## Usage Examples

### VehicleService Example
```dart
final vehicleService = VehicleService();

// Add a new vehicle
final vehicle = Vehicle(
  name: 'My Car',
  make: 'Toyota',
  model: 'Camry',
  year: 2020,
  createdAt: DateTime.now(),
);

final vehicleId = await vehicleService.addVehicle(vehicle);

// Get all vehicles
final vehicles = await vehicleService.getAllVehicles();
```

### ReportingService Example
```dart
final reportingService = ReportingService();

// Get fuel efficiency stats for a vehicle
final stats = await reportingService.calculateFuelEfficiencyStats(1);
print('Average consumption: ${stats['averageConsumption']}');
```

### DataManagementService Example
```dart
final dataService = DataManagementService();

// Export vehicles to Excel
final vehicles = await vehicleService.getAllVehicles();
final filePath = '/storage/emulated/0/Download/vehicles.xlsx';
await dataService.exportToExcel(vehicles, filePath);
```

## Error Handling
Services should handle errors gracefully and return appropriate values:
- Methods that return lists should return empty lists on error
- Methods that return objects should return null on error
- Methods that return integers should return 0 on error

## Testing
Each service should have corresponding unit tests that mock the DAO layer to test business logic in isolation.