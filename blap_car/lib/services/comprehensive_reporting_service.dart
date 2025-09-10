import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/database/refueling_dao.dart';
import 'package:blap_car/database/expense_dao.dart';
import 'package:blap_car/database/maintenance_dao.dart';

class ComprehensiveReportingService {
  final VehicleDao _vehicleDao = VehicleDao();
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final MaintenanceDao _maintenanceDao = MaintenanceDao();

  // Get comprehensive vehicle report
  Future<Map<String, dynamic>> getVehicleReport(int vehicleId) async {
    final vehicle = await _vehicleDao.getVehicleById(vehicleId);
    if (vehicle == null) {
      throw Exception('Vehicle not found');
    }

    final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
    final expenses = await _expenseDao.getExpensesByVehicleId(vehicleId);
    final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);

    // Calculate fuel efficiency metrics
    final fuelEfficiency = _calculateFuelEfficiency(refuelings);
    
    // Calculate cost metrics
    final totalCosts = _calculateTotalCosts(refuelings, expenses, maintenances);
    
    // Calculate maintenance metrics
    final maintenanceMetrics = _calculateMaintenanceMetrics(maintenances);
    
    // Calculate usage metrics
    final usageMetrics = _calculateUsageMetrics(refuelings);

    return {
      'vehicle': vehicle,
      'fuelEfficiency': fuelEfficiency,
      'totalCosts': totalCosts,
      'maintenanceMetrics': maintenanceMetrics,
      'usageMetrics': usageMetrics,
      'data': {
        'refuelings': refuelings,
        'expenses': expenses,
        'maintenances': maintenances,
      }
    };
  }

  // Calculate fuel efficiency metrics
  Map<String, dynamic> _calculateFuelEfficiency(List<Refueling> refuelings) {
    if (refuelings.isEmpty) {
      return {
        'averageConsumption': 0.0,
        'bestConsumption': 0.0,
        'worstConsumption': 0.0,
        'totalLiters': 0.0,
        'totalCost': 0.0,
      };
    }

    // Sort refuelings by odometer
    refuelings.sort((a, b) => a.odometer.compareTo(b.odometer));

    double totalLiters = 0.0;
    double totalCost = 0.0;
    List<double> consumptions = [];

    // Calculate consumption for each full tank refueling
    for (int i = 1; i < refuelings.length; i++) {
      final previous = refuelings[i - 1];
      final current = refuelings[i];

      // Only calculate for full tank refuelings
      if (current.fullTank == true && current.liters != null) {
        final kmDriven = current.odometer - previous.odometer;
        final litersConsumed = current.liters!;
        
        if (kmDriven > 0 && litersConsumed > 0) {
          final consumption = litersConsumed / (kmDriven / 100); // L/100km
          consumptions.add(consumption);
          totalLiters += litersConsumed;
          totalCost += current.totalCost ?? 0;
        }
      }
    }

    if (consumptions.isEmpty) {
      return {
        'averageConsumption': 0.0,
        'bestConsumption': 0.0,
        'worstConsumption': 0.0,
        'totalLiters': totalLiters,
        'totalCost': totalCost,
      };
    }

    consumptions.sort();
    
    return {
      'averageConsumption': consumptions.reduce((a, b) => a + b) / consumptions.length,
      'bestConsumption': consumptions.first, // Best = lowest consumption
      'worstConsumption': consumptions.last, // Worst = highest consumption
      'totalLiters': totalLiters,
      'totalCost': totalCost,
    };
  }

  // Calculate total costs
  Map<String, double> _calculateTotalCosts(
    List<Refueling> refuelings,
    List<Expense> expenses,
    List<Maintenance> maintenances,
  ) {
    double fuelCosts = 0.0;
    double expenseCosts = 0.0;
    double maintenanceCosts = 0.0;

    // Calculate fuel costs
    for (final refueling in refuelings) {
      fuelCosts += refueling.totalCost ?? 0;
    }

    // Calculate expense costs
    for (final expense in expenses) {
      expenseCosts += expense.cost ?? 0;
    }

    // Calculate maintenance costs
    for (final maintenance in maintenances) {
      maintenanceCosts += maintenance.cost ?? 0;
    }

    return {
      'fuel': fuelCosts,
      'expenses': expenseCosts,
      'maintenance': maintenanceCosts,
      'total': fuelCosts + expenseCosts + maintenanceCosts,
    };
  }

  // Calculate maintenance metrics
  Map<String, dynamic> _calculateMaintenanceMetrics(List<Maintenance> maintenances) {
    if (maintenances.isEmpty) {
      return {
        'totalCost': 0.0,
        'totalCount': 0,
        'byType': <String, int>{},
        'byStatus': <String, int>{},
      };
    }

    double totalCost = 0.0;
    Map<String, int> byType = {};
    Map<String, int> byStatus = {};

    for (final maintenance in maintenances) {
      totalCost += maintenance.cost ?? 0;
      
      // Count by type
      final type = maintenance.type ?? 'Unknown';
      byType[type] = (byType[type] ?? 0) + 1;
      
      // Count by status
      final status = maintenance.status ?? 'Unknown';
      byStatus[status] = (byStatus[status] ?? 0) + 1;
    }

    return {
      'totalCost': totalCost,
      'totalCount': maintenances.length,
      'byType': byType,
      'byStatus': byStatus,
    };
  }

  // Calculate usage metrics
  Map<String, dynamic> _calculateUsageMetrics(List<Refueling> refuelings) {
    if (refuelings.isEmpty) {
      return {
        'totalKm': 0.0,
        'averageMonthlyKm': 0.0,
        'firstRefuelingDate': null,
        'lastRefuelingDate': null,
      };
    }

    // Sort by date
    refuelings.sort((a, b) => a.date.compareTo(b.date));

    final firstRefueling = refuelings.first;
    final lastRefueling = refuelings.last;
    
    final totalKm = lastRefueling.odometer - firstRefueling.odometer;

    final daysBetween = lastRefueling.date.difference(firstRefueling.date).inDays;
    final monthsBetween = daysBetween > 0 ? daysBetween / 30.0 : 1.0;
    final averageMonthlyKm = monthsBetween > 0 ? totalKm / monthsBetween : 0.0;

    return {
      'totalKm': totalKm,
      'averageMonthlyKm': averageMonthlyKm,
      'firstRefuelingDate': firstRefueling.date,
      'lastRefuelingDate': lastRefueling.date,
    };
  }

  // Get cost trend data by month
  Future<List<Map<String, dynamic>>> getCostTrendData(int vehicleId) async {
    final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
    final expenses = await _expenseDao.getExpensesByVehicleId(vehicleId);
    final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);

    // Combine all costs by month
    Map<String, Map<String, double>> monthlyCosts = {};

    // Process refuelings
    for (final refueling in refuelings) {
      if (refueling.totalCost != null) {
        final monthKey = '${refueling.date.year}-${refueling.date.month.toString().padLeft(2, '0')}';
        final costs = monthlyCosts.putIfAbsent(monthKey, () => {
              'fuel': 0.0,
              'expenses': 0.0,
              'maintenance': 0.0,
            });
        costs['fuel'] = (costs['fuel'] ?? 0) + (refueling.totalCost ?? 0);
      }
    }

    // Process expenses
    for (final expense in expenses) {
      if (expense.cost != null) {
        final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
        final costs = monthlyCosts.putIfAbsent(monthKey, () => {
              'fuel': 0.0,
              'expenses': 0.0,
              'maintenance': 0.0,
            });
        costs['expenses'] = (costs['expenses'] ?? 0) + (expense.cost ?? 0);
      }
    }

    // Process maintenances
    for (final maintenance in maintenances) {
      if (maintenance.date != null && maintenance.cost != null) {
        final monthKey = '${maintenance.date!.year}-${maintenance.date!.month.toString().padLeft(2, '0')}';
        final costs = monthlyCosts.putIfAbsent(monthKey, () => {
              'fuel': 0.0,
              'expenses': 0.0,
              'maintenance': 0.0,
            });
        costs['maintenance'] = (costs['maintenance'] ?? 0) + (maintenance.cost ?? 0);
      }
    }

    // Convert to list
    List<Map<String, dynamic>> trendData = [];
    monthlyCosts.forEach((month, costs) {
      trendData.add({
        'month': month,
        'fuel': costs['fuel'] ?? 0,
        'expenses': costs['expenses'] ?? 0,
        'maintenance': costs['maintenance'] ?? 0,
        'total': (costs['fuel'] ?? 0) + (costs['expenses'] ?? 0) + (costs['maintenance'] ?? 0),
      });
    });

    // Sort by month
    trendData.sort((a, b) => a['month'].toString().compareTo(b['month'].toString()));

    return trendData;
  }

  // Get fleet summary report
  Future<Map<String, dynamic>> getFleetSummaryReport() async {
    final vehicles = await _vehicleDao.getAllVehicles();
    
    double totalFleetCost = 0.0;
    int totalVehicles = vehicles.length;
    List<Map<String, dynamic>> vehicleReports = [];

    for (final vehicle in vehicles) {
      try {
        final report = await getVehicleReport(vehicle.id!);
        final totalCost = report['totalCosts']['total'] as double;
        
        totalFleetCost += totalCost;
        
        vehicleReports.add({
          'vehicle': vehicle,
          'totalCost': totalCost,
          'fuelEfficiency': report['fuelEfficiency']['averageConsumption'],
        });
      } catch (e) {
        // Skip vehicles with errors
        continue;
      }
    }

    // Sort vehicles by cost (highest first)
    vehicleReports.sort((a, b) => (b['totalCost'] as double).compareTo(a['totalCost'] as double));

    return {
      'totalFleetCost': totalFleetCost,
      'totalVehicles': totalVehicles,
      'averageCostPerVehicle': totalVehicles > 0 ? totalFleetCost / totalVehicles : 0.0,
      'vehicleReports': vehicleReports,
    };
  }
}