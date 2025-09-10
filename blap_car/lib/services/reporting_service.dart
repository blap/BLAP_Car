import 'package:blap_car/database/refueling_dao.dart';
import 'package:blap_car/database/expense_dao.dart';
import 'package:blap_car/database/maintenance_dao.dart';
import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/models/vehicle.dart';

class ReportingService {
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final MaintenanceDao _maintenanceDao = MaintenanceDao();
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

  // Get maintenance records for a vehicle
  Future<List<Maintenance>> getMaintenancesByVehicleId(int vehicleId) async {
    return await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);
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
        'bestConsumption': 0.0,
        'worstConsumption': 0.0,
        'consumptionTrend': <double>[],
        'fuelTypeStats': <String, dynamic>{},
      };
    }

    double totalCost = 0.0;
    double totalLiters = 0.0;
    double totalDistance = 0.0;
    double bestConsumption = double.infinity;
    double worstConsumption = 0.0;
    List<double> consumptionTrend = [];
    Map<String, dynamic> fuelTypeStats = {};

    // Sort refuelings by odometer
    refuelings.sort((a, b) => a.odometer.compareTo(b.odometer));

    // Calculate consumption between refuelings
    for (int i = 1; i < refuelings.length; i++) {
      final current = refuelings[i];
      final previous = refuelings[i - 1];
      
      final distance = current.odometer - previous.odometer;
      totalDistance += distance;
      
      if (current.liters != null && current.liters! > 0) {
        totalLiters += current.liters!;
        final consumption = distance / current.liters!;
        consumptionTrend.add(consumption);
        
        // Track best and worst consumption
        if (consumption < bestConsumption) {
          bestConsumption = consumption;
        }
        if (consumption > worstConsumption) {
          worstConsumption = consumption;
        }
        
        // Update fuel type stats
        final fuelType = current.fuelType ?? 'Unknown';
        if (!fuelTypeStats.containsKey(fuelType)) {
          fuelTypeStats[fuelType] = {
            'totalCost': 0.0,
            'totalLiters': 0.0,
            'totalDistance': 0.0,
            'bestConsumption': double.infinity,
            'worstConsumption': 0.0,
            'averageConsumption': 0.0,
            'count': 0,
          };
        }
        
        final stats = fuelTypeStats[fuelType];
        stats['totalCost'] += (current.totalCost ?? 0.0);
        stats['totalLiters'] += (current.liters ?? 0.0);
        stats['totalDistance'] += distance;
        stats['count'] += 1;
        
        // Update fuel type best/worst consumption
        if (consumption < stats['bestConsumption']) {
          stats['bestConsumption'] = consumption;
        }
        if (consumption > stats['worstConsumption']) {
          stats['worstConsumption'] = consumption;
        }
        
        // Calculate average consumption for this fuel type
        if (stats['totalLiters'] > 0) {
          stats['averageConsumption'] = stats['totalDistance'] / stats['totalLiters'];
        }
      }
      
      totalCost += (current.totalCost ?? 0.0);
    }

    final averageConsumption = totalLiters > 0 ? totalDistance / totalLiters : 0.0;
    final costPerKm = totalDistance > 0 ? totalCost / totalDistance : 0.0;
    
    // Adjust bestConsumption if no valid consumption was found
    if (bestConsumption == double.infinity) {
      bestConsumption = 0.0;
    }

    return {
      'totalRefuelings': refuelings.length,
      'totalCost': totalCost,
      'totalLiters': totalLiters,
      'totalDistance': totalDistance,
      'averageConsumption': averageConsumption,
      'costPerKm': costPerKm,
      'bestConsumption': bestConsumption,
      'worstConsumption': worstConsumption,
      'consumptionTrend': consumptionTrend,
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

  // Calculate maintenance statistics
  Future<Map<String, dynamic>> calculateMaintenanceStats(int vehicleId) async {
    final maintenances = await getMaintenancesByVehicleId(vehicleId);
    
    if (maintenances.isEmpty) {
      return {
        'totalMaintenances': 0,
        'totalCost': 0.0,
        'maintenanceTypeStats': <String, dynamic>{},
      };
    }

    double totalCost = 0.0;
    Map<String, dynamic> maintenanceTypeStats = {};

    for (final maintenance in maintenances) {
      totalCost += (maintenance.cost ?? 0.0);
      
      final maintenanceType = maintenance.type ?? 'Unknown';
      if (!maintenanceTypeStats.containsKey(maintenanceType)) {
        maintenanceTypeStats[maintenanceType] = {
          'count': 0,
          'totalCost': 0.0,
        };
      }
      
      final stats = maintenanceTypeStats[maintenanceType];
      stats['count'] += 1;
      stats['totalCost'] += (maintenance.cost ?? 0.0);
    }

    return {
      'totalMaintenances': maintenances.length,
      'totalCost': totalCost,
      'maintenanceTypeStats': maintenanceTypeStats,
    };
  }

  // Calculate general statistics
  Future<Map<String, dynamic>> calculateGeneralStats(int vehicleId) async {
    final refuelings = await getRefuelingsByVehicleId(vehicleId);
    final expenses = await getExpensesByVehicleId(vehicleId);
    final maintenances = await getMaintenancesByVehicleId(vehicleId);
    
    if (refuelings.isEmpty && expenses.isEmpty && maintenances.isEmpty) {
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

    // Process maintenances
    for (final maintenance in maintenances) {
      totalCost += (maintenance.cost ?? 0.0);
      
      if (maintenance.date != null) {
        if (firstDate == null || maintenance.date!.isBefore(firstDate)) {
          firstDate = maintenance.date;
        }
        if (lastDate == null || maintenance.date!.isAfter(lastDate)) {
          lastDate = maintenance.date;
        }
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
      'totalRecords': refuelings.length + expenses.length + maintenances.length,
      'totalCost': totalCost,
      'totalDistance': totalDistance,
      'averageDailyCost': averageDailyCost,
      'costPerKm': costPerKm,
    };
  }

  // Get fuel consumption trend data (consumption per refueling)
  Future<List<Map<String, dynamic>>> getFuelConsumptionTrend(int vehicleId) async {
    final refuelings = await getRefuelingsByVehicleId(vehicleId);
    
    if (refuelings.isEmpty) {
      return [];
    }

    // Sort refuelings by odometer
    refuelings.sort((a, b) => a.odometer.compareTo(b.odometer));
    
    List<Map<String, dynamic>> trendData = [];
    
    // Calculate consumption between refuelings
    for (int i = 1; i < refuelings.length; i++) {
      final current = refuelings[i];
      final previous = refuelings[i - 1];
      
      final distance = current.odometer - previous.odometer;
      
      if (current.liters != null && current.liters! > 0) {
        final consumption = distance / current.liters!;
        
        trendData.add({
          'date': current.date,
          'odometer': current.odometer,
          'consumption': consumption,
          'liters': current.liters,
          'cost': current.totalCost,
        });
      }
    }
    
    return trendData;
  }

  // Get cost per liter trend data
  Future<List<Map<String, dynamic>>> getCostPerLiterTrend(int vehicleId) async {
    final refuelings = await getRefuelingsByVehicleId(vehicleId);
    
    if (refuelings.isEmpty) {
      return [];
    }

    // Sort refuelings by date
    refuelings.sort((a, b) => a.date.compareTo(b.date));
    
    List<Map<String, dynamic>> trendData = [];
    
    for (final refueling in refuelings) {
      if (refueling.liters != null && refueling.liters! > 0) {
        final costPerLiter = (refueling.totalCost ?? 0.0) / refueling.liters!;
        
        trendData.add({
          'date': refueling.date,
          'costPerLiter': costPerLiter,
          'liters': refueling.liters,
          'totalCost': refueling.totalCost,
          'fuelType': refueling.fuelType,
        });
      }
    }
    
    return trendData;
  }

  // Get expense trend data (monthly expenses)
  Future<List<Map<String, dynamic>>> getExpenseTrend(int vehicleId) async {
    final expenses = await getExpensesByVehicleId(vehicleId);
    
    if (expenses.isEmpty) {
      return [];
    }

    // Sort expenses by date
    expenses.sort((a, b) => a.date.compareTo(b.date));
    
    // Group expenses by month
    Map<String, double> monthlyExpenses = {};
    
    for (final expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyExpenses[monthKey] = (monthlyExpenses[monthKey] ?? 0.0) + (expense.cost ?? 0.0);
    }
    
    // Convert to list of trend data
    List<Map<String, dynamic>> trendData = [];
    monthlyExpenses.forEach((month, totalCost) {
      trendData.add({
        'month': month,
        'totalCost': totalCost,
      });
    });
    
    // Sort by month
    trendData.sort((a, b) => a['month'].toString().compareTo(b['month'].toString()));
    
    return trendData;
  }

  // Get maintenance trend data (monthly maintenance costs)
  Future<List<Map<String, dynamic>>> getMaintenanceTrend(int vehicleId) async {
    final maintenances = await getMaintenancesByVehicleId(vehicleId);
    
    if (maintenances.isEmpty) {
      return [];
    }

    // Sort maintenances by date
    maintenances.sort((a, b) {
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return a.date!.compareTo(b.date!);
    });
    
    // Group maintenances by month
    Map<String, double> monthlyMaintenances = {};
    
    for (final maintenance in maintenances) {
      if (maintenance.date != null) {
        final monthKey = '${maintenance.date!.year}-${maintenance.date!.month.toString().padLeft(2, '0')}';
        monthlyMaintenances[monthKey] = (monthlyMaintenances[monthKey] ?? 0.0) + (maintenance.cost ?? 0.0);
      }
    }
    
    // Convert to list of trend data
    List<Map<String, dynamic>> trendData = [];
    monthlyMaintenances.forEach((month, totalCost) {
      trendData.add({
        'month': month,
        'totalCost': totalCost,
      });
    });
    
    // Sort by month
    trendData.sort((a, b) => a['month'].toString().compareTo(b['month'].toString()));
    
    return trendData;
  }

  // Get expense distribution by type
  Future<Map<String, double>> getExpenseTypeDistribution(int vehicleId) async {
    final expenses = await getExpensesByVehicleId(vehicleId);
    
    if (expenses.isEmpty) {
      return {};
    }

    Map<String, double> typeDistribution = {};
    
    for (final expense in expenses) {
      final type = expense.type ?? 'Unknown';
      typeDistribution[type] = (typeDistribution[type] ?? 0.0) + (expense.cost ?? 0.0);
    }
    
    return typeDistribution;
  }

  // Get maintenance distribution by type
  Future<Map<String, double>> getMaintenanceTypeDistribution(int vehicleId) async {
    final maintenances = await getMaintenancesByVehicleId(vehicleId);
    
    if (maintenances.isEmpty) {
      return {};
    }

    Map<String, double> typeDistribution = {};
    
    for (final maintenance in maintenances) {
      final type = maintenance.type ?? 'Unknown';
      typeDistribution[type] = (typeDistribution[type] ?? 0.0) + (maintenance.cost ?? 0.0);
    }
    
    return typeDistribution;
  }

  // Get comprehensive vehicle report
  Future<Map<String, dynamic>> getComprehensiveVehicleReport(int vehicleId) async {
    final generalStats = await calculateGeneralStats(vehicleId);
    final refuelingStats = await calculateFuelEfficiencyStats(vehicleId);
    final expenseStats = await calculateExpenseStats(vehicleId);
    final maintenanceStats = await calculateMaintenanceStats(vehicleId);
    
    final fuelConsumptionTrend = await getFuelConsumptionTrend(vehicleId);
    final costPerLiterTrend = await getCostPerLiterTrend(vehicleId);
    final expenseTrend = await getExpenseTrend(vehicleId);
    final maintenanceTrend = await getMaintenanceTrend(vehicleId);
    final expenseTypeDistribution = await getExpenseTypeDistribution(vehicleId);
    final maintenanceTypeDistribution = await getMaintenanceTypeDistribution(vehicleId);
    
    return {
      'generalStats': generalStats,
      'refuelingStats': refuelingStats,
      'expenseStats': expenseStats,
      'maintenanceStats': maintenanceStats,
      'fuelConsumptionTrend': fuelConsumptionTrend,
      'costPerLiterTrend': costPerLiterTrend,
      'expenseTrend': expenseTrend,
      'maintenanceTrend': maintenanceTrend,
      'expenseTypeDistribution': expenseTypeDistribution,
      'maintenanceTypeDistribution': maintenanceTypeDistribution,
    };
  }
}