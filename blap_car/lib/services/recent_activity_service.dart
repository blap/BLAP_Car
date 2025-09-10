import 'package:blap_car/database/refueling_dao.dart';
import 'package:blap_car/database/expense_dao.dart';
import 'package:blap_car/database/maintenance_dao.dart';
import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/models/recent_activity.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/models/vehicle.dart';

class RecentActivityService {
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final MaintenanceDao _maintenanceDao = MaintenanceDao();
  final VehicleDao _vehicleDao = VehicleDao();

  // Get recent activities from all vehicles
  Future<List<RecentActivity>> getRecentActivities({int limit = 10}) async {
    // Fetch all vehicles for name lookup
    final List<Vehicle> vehicles = await _vehicleDao.getAllVehicles();
    final Map<int, String> vehicleNames = {
      for (var vehicle in vehicles) vehicle.id!: vehicle.name
    };

    // Fetch recent activities from all sources
    final List<Refueling> recentRefuelings = await _getRecentRefuelings(limit);
    final List<Expense> recentExpenses = await _getRecentExpenses(limit);
    final List<Maintenance> recentMaintenances = await _getRecentMaintenances(limit);

    // Convert to RecentActivity objects
    final List<RecentActivity> activities = [];

    // Add refueling activities
    for (final refueling in recentRefuelings) {
      final vehicleName = vehicleNames[refueling.vehicleId] ?? 'Unknown Vehicle';
      activities.add(
        RecentActivity(
          id: refueling.id ?? 0,
          type: 'Refueling',
          description: '${refueling.fuelType ?? 'Fuel'} at ${refueling.station ?? 'Unknown Station'}',
          date: refueling.date,
          cost: refueling.totalCost,
          vehicleName: vehicleName,
        ),
      );
    }

    // Add expense activities
    for (final expense in recentExpenses) {
      final vehicleName = vehicleNames[expense.vehicleId] ?? 'Unknown Vehicle';
      activities.add(
        RecentActivity(
          id: expense.id ?? 0,
          type: 'Expense',
          description: '${expense.type ?? 'Expense'} - ${expense.description ?? 'No description'}',
          date: expense.date,
          cost: expense.cost,
          vehicleName: vehicleName,
        ),
      );
    }

    // Add maintenance activities
    for (final maintenance in recentMaintenances) {
      final vehicleName = vehicleNames[maintenance.vehicleId] ?? 'Unknown Vehicle';
      activities.add(
        RecentActivity(
          id: maintenance.id ?? 0,
          type: 'Maintenance',
          description: '${maintenance.type ?? 'Maintenance'} - ${maintenance.description ?? 'No description'}',
          date: maintenance.date ?? DateTime.now(),
          cost: maintenance.cost,
          vehicleName: vehicleName,
        ),
      );
    }

    // Sort by date (newest first) and limit
    activities.sort((a, b) => b.date.compareTo(a.date));
    return activities.take(limit).toList();
  }

  // Get recent refuelings
  Future<List<Refueling>> _getRecentRefuelings(int limit) async {
    final List<Refueling> allRefuelings = await _refuelingDao.getAllRefuelings();
    // Sort by date (newest first) and limit
    allRefuelings.sort((a, b) => b.date.compareTo(a.date));
    return allRefuelings.take(limit).toList();
  }

  // Get recent expenses
  Future<List<Expense>> _getRecentExpenses(int limit) async {
    final List<Expense> allExpenses = await _expenseDao.getAllExpenses();
    // Sort by date (newest first) and limit
    allExpenses.sort((a, b) => b.date.compareTo(a.date));
    return allExpenses.take(limit).toList();
  }

  // Get recent maintenances
  Future<List<Maintenance>> _getRecentMaintenances(int limit) async {
    final List<Maintenance> allMaintenances = await _maintenanceDao.getAllMaintenances();
    // Sort by date (newest first) and limit
    allMaintenances.sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
    return allMaintenances.take(limit).toList();
  }
}