import 'package:blap_car/database/refueling_dao.dart';
import 'package:blap_car/database/expense_dao.dart';
import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/models/vehicle.dart';

class ReportingService {
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final VehicleDao _vehicleDao = VehicleDao();

  // Get all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    return await _vehicleDao.getAllVehicles();
  }

  // Get refuelings for a vehicle
  Future<List<Refueling>> getRefuelingsByVehicleId(int vehicleId) async {
    return await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
  }

  // Get expenses for a vehicle
  Future<List<Expense>> getExpensesByVehicleId(int vehicleId) async {
    return await _expenseDao.getExpensesByVehicleId(vehicleId);
  }

  // Calculate fuel efficiency statistics
  Future<Map<String, dynamic>> calculateFuelEfficiencyStats(int vehicleId) async {
    final refuelings = await getRefuelingsByVehicleId(vehicleId);
    
    if (refuelings.isEmpty) {
      return {
        'totalRefuelings': 0,
        'totalCost': 0.0,
        'totalLiters': 0.0,
        'totalDistance': 0.0,
        'averageConsumption': 0.0,
        'costPerKm': 0.0,
        'fuelTypeStats': <String, dynamic>{},
      };
    }

    double totalCost = 0.0;
    double totalLiters = 0.0;
    double totalDistance = 0.0;
    Map<String, dynamic> fuelTypeStats = {};

    // Sort refuelings by odometer
    refuelings.sort((a, b) => a.odometer.compareTo(b.odometer));

    // Calculate consumption between refuelings
    for (int i = 1; i < refuelings.length; i++) {
      final current = refuelings[i];
      final previous = refuelings[i - 1];
      
      final distance = current.odometer - previous.odometer;
      totalDistance += distance;
      
      if (current.liters != null) {
        totalLiters += current.liters!;
        
        // Update fuel type stats
        final fuelType = current.fuelType ?? 'Unknown';
        if (!fuelTypeStats.containsKey(fuelType)) {
          fuelTypeStats[fuelType] = {
            'totalCost': 0.0,
            'totalLiters': 0.0,
            'totalDistance': 0.0,
          };
        }
        
        final stats = fuelTypeStats[fuelType];
        stats['totalCost'] += (current.totalCost ?? 0.0);
        stats['totalLiters'] += (current.liters ?? 0.0);
        stats['totalDistance'] += distance;
      }
      
      totalCost += (current.totalCost ?? 0.0);
    }

    final averageConsumption = totalLiters > 0 ? totalDistance / totalLiters : 0.0;
    final costPerKm = totalDistance > 0 ? totalCost / totalDistance : 0.0;

    return {
      'totalRefuelings': refuelings.length,
      'totalCost': totalCost,
      'totalLiters': totalLiters,
      'totalDistance': totalDistance,
      'averageConsumption': averageConsumption,
      'costPerKm': costPerKm,
      'fuelTypeStats': fuelTypeStats,
    };
  }

  // Calculate expense statistics
  Future<Map<String, dynamic>> calculateExpenseStats(int vehicleId) async {
    final expenses = await getExpensesByVehicleId(vehicleId);
    
    if (expenses.isEmpty) {
      return {
        'totalExpenses': 0,
        'totalCost': 0.0,
        'expenseTypeStats': <String, dynamic>{},
      };
    }

    double totalCost = 0.0;
    Map<String, dynamic> expenseTypeStats = {};

    for (final expense in expenses) {
      totalCost += (expense.cost ?? 0.0);
      
      final expenseType = expense.type ?? 'Unknown';
      if (!expenseTypeStats.containsKey(expenseType)) {
        expenseTypeStats[expenseType] = {
          'count': 0,
          'totalCost': 0.0,
        };
      }
      
      final stats = expenseTypeStats[expenseType];
      stats['count'] += 1;
      stats['totalCost'] += (expense.cost ?? 0.0);
    }

    return {
      'totalExpenses': expenses.length,
      'totalCost': totalCost,
      'expenseTypeStats': expenseTypeStats,
    };
  }

  // Calculate general statistics
  Future<Map<String, dynamic>> calculateGeneralStats(int vehicleId) async {
    final refuelings = await getRefuelingsByVehicleId(vehicleId);
    final expenses = await getExpensesByVehicleId(vehicleId);
    
    if (refuelings.isEmpty && expenses.isEmpty) {
      return {
        'totalRecords': 0,
        'totalCost': 0.0,
        'totalDistance': 0.0,
        'averageDailyCost': 0.0,
        'costPerKm': 0.0,
      };
    }

    double totalCost = 0.0;
    double totalDistance = 0.0;
    DateTime? firstDate;
    DateTime? lastDate;

    // Process refuelings
    for (final refueling in refuelings) {
      totalCost += (refueling.totalCost ?? 0.0);
      
      if (firstDate == null || refueling.date.isBefore(firstDate)) {
        firstDate = refueling.date;
      }
      if (lastDate == null || refueling.date.isAfter(lastDate)) {
        lastDate = refueling.date;
      }
    }

    // Process expenses
    for (final expense in expenses) {
      totalCost += (expense.cost ?? 0.0);
      
      if (firstDate == null || expense.date.isBefore(firstDate)) {
        firstDate = expense.date;
      }
      if (lastDate == null || expense.date.isAfter(lastDate)) {
        lastDate = expense.date;
      }
    }

    // Calculate distance from refuelings
    if (refuelings.isNotEmpty) {
      refuelings.sort((a, b) => a.odometer.compareTo(b.odometer));
      totalDistance = refuelings.last.odometer - refuelings.first.odometer;
    }

    double averageDailyCost = 0.0;
    double costPerKm = 0.0;
    
    if (firstDate != null && lastDate != null && lastDate.isAfter(firstDate)) {
      final days = lastDate.difference(firstDate).inDays;
      if (days > 0) {
        averageDailyCost = totalCost / days;
      }
    }
    
    if (totalDistance > 0) {
      costPerKm = totalCost / totalDistance;
    }

    return {
      'totalRecords': refuelings.length + expenses.length,
      'totalCost': totalCost,
      'totalDistance': totalDistance,
      'averageDailyCost': averageDailyCost,
      'costPerKm': costPerKm,
    };
  }
}