import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/database/refueling_dao.dart';
import 'package:blap_car/database/expense_dao.dart';
import 'package:blap_car/database/maintenance_dao.dart';

class CostTrackingService {
  final VehicleDao _vehicleDao = VehicleDao();
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final MaintenanceDao _maintenanceDao = MaintenanceDao();

  // Get total costs for a vehicle
  Future<double> getTotalCosts(int vehicleId) async {
    final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
    final expenses = await _expenseDao.getExpensesByVehicleId(vehicleId);
    final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);

    double total = 0.0;

    // Add refueling costs
    for (final refueling in refuelings) {
      total += refueling.totalCost ?? 0;
    }

    // Add expense costs
    for (final expense in expenses) {
      total += expense.cost ?? 0;
    }

    // Add maintenance costs
    for (final maintenance in maintenances) {
      total += maintenance.cost ?? 0;
    }

    return total;
  }

  // Get cost breakdown by category
  Future<Map<String, double>> getCostBreakdown(int vehicleId) async {
    final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
    final expenses = await _expenseDao.getExpensesByVehicleId(vehicleId);
    final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);

    double fuelCosts = 0.0;
    double maintenanceCosts = 0.0;
    double otherExpenseCosts = 0.0;

    // Calculate fuel costs
    for (final refueling in refuelings) {
      fuelCosts += refueling.totalCost ?? 0;
    }

    // Calculate maintenance costs
    for (final maintenance in maintenances) {
      maintenanceCosts += maintenance.cost ?? 0;
    }

    // Calculate other expense costs
    for (final expense in expenses) {
      otherExpenseCosts += expense.cost ?? 0;
    }

    return {
      'Fuel': fuelCosts,
      'Maintenance': maintenanceCosts,
      'Other Expenses': otherExpenseCosts,
    };
  }

  // Get monthly cost trends
  Future<List<Map<String, dynamic>>> getMonthlyCostTrends(int vehicleId) async {
    final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
    final expenses = await _expenseDao.getExpensesByVehicleId(vehicleId);
    final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);

    Map<String, Map<String, double>> monthlyCosts = {};

    // Process refuelings
    for (final refueling in refuelings) {
      final monthKey = '${refueling.date.year}-${refueling.date.month.toString().padLeft(2, '0')}';
      final costs = monthlyCosts.putIfAbsent(monthKey, () => {
            'Fuel': 0.0,
            'Maintenance': 0.0,
            'Other Expenses': 0.0,
          });
      costs['Fuel'] = (costs['Fuel'] ?? 0) + (refueling.totalCost ?? 0);
    }

    // Process expenses
    for (final expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      final costs = monthlyCosts.putIfAbsent(monthKey, () => {
            'Fuel': 0.0,
            'Maintenance': 0.0,
            'Other Expenses': 0.0,
          });
      costs['Other Expenses'] = (costs['Other Expenses'] ?? 0) + (expense.cost ?? 0);
    }

    // Process maintenances
    for (final maintenance in maintenances) {
      final monthKey = '${maintenance.date!.year}-${maintenance.date!.month.toString().padLeft(2, '0')}';
      final costs = monthlyCosts.putIfAbsent(monthKey, () => {
            'Fuel': 0.0,
            'Maintenance': 0.0,
            'Other Expenses': 0.0,
          });
      costs['Maintenance'] = (costs['Maintenance'] ?? 0) + (maintenance.cost ?? 0);
    }

    // Convert to list
    List<Map<String, dynamic>> trendData = [];
    monthlyCosts.forEach((month, costs) {
      trendData.add({
        'month': month,
        'Fuel': costs['Fuel'] ?? 0,
        'Maintenance': costs['Maintenance'] ?? 0,
        'Other Expenses': costs['Other Expenses'] ?? 0,
        'total': (costs['Fuel'] ?? 0) + (costs['Maintenance'] ?? 0) + (costs['Other Expenses'] ?? 0),
      });
    });

    // Sort by month
    trendData.sort((a, b) => a['month'].toString().compareTo(b['month'].toString()));

    return trendData;
  }

  // Get cost per kilometer
  Future<double> getCostPerKilometer(int vehicleId) async {
    final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
    
    if (refuelings.isEmpty) {
      return 0.0;
    }

    // Sort refuelings by odometer
    refuelings.sort((a, b) => a.odometer.compareTo(b.odometer));

    final firstOdometer = refuelings.first.odometer;
    final lastOdometer = refuelings.last.odometer;
    final totalKm = lastOdometer - firstOdometer;

    if (totalKm <= 0) {
      return 0.0;
    }

    final totalCosts = await getTotalCosts(vehicleId);
    return totalCosts / totalKm;
  }

  // Check if budget is exceeded
  Future<bool> isBudgetExceeded(int vehicleId, double budget) async {
    final totalCosts = await getTotalCosts(vehicleId);
    return totalCosts > budget;
  }

  // Get budget utilization percentage
  Future<double> getBudgetUtilization(int vehicleId, double budget) async {
    if (budget <= 0) {
      return 0.0;
    }
    
    final totalCosts = await getTotalCosts(vehicleId);
    return (totalCosts / budget) * 100;
  }

  // Get cost predictions
  Future<Map<String, dynamic>> getCostPredictions(int vehicleId) async {
    final monthlyTrends = await getMonthlyCostTrends(vehicleId);
    
    if (monthlyTrends.isEmpty) {
      return {
        'nextMonthPrediction': 0.0,
        'averageMonthlyCost': 0.0,
        'trend': 'stable',
      };
    }

    // Calculate average monthly cost
    double totalCost = 0.0;
    for (final monthData in monthlyTrends) {
      final total = monthData['total'];
      if (total is double) {
        totalCost += total;
      } else if (total is int) {
        totalCost += total.toDouble();
      }
    }
    final averageMonthlyCost = monthlyTrends.isNotEmpty ? totalCost / monthlyTrends.length : 0.0;

    // Simple prediction: assume next month will be similar to average
    double nextMonthPrediction = averageMonthlyCost;

    // Determine trend based on last few months
    String trend = 'stable';
    if (monthlyTrends.length >= 3) {
      final lastMonthData = monthlyTrends[monthlyTrends.length - 1];
      final prevMonthData = monthlyTrends[monthlyTrends.length - 2];
      final prevPrevMonthData = monthlyTrends[monthlyTrends.length - 3];
      
      if (lastMonthData['total'] is double && prevMonthData['total'] is double && prevPrevMonthData['total'] is double) {
        final lastMonth = lastMonthData['total'] as double;
        final prevMonth = prevMonthData['total'] as double;
        final prevPrevMonth = prevPrevMonthData['total'] as double;

        if (lastMonth > prevMonth && prevMonth > prevPrevMonth) {
          trend = 'increasing';
          // Predict higher costs if trend is increasing
          nextMonthPrediction = lastMonth * 1.1;
        } else if (lastMonth < prevMonth && prevMonth < prevPrevMonth) {
          trend = 'decreasing';
          // Predict lower costs if trend is decreasing
          nextMonthPrediction = lastMonth * 0.9;
        }
      }
    }

    return {
      'nextMonthPrediction': nextMonthPrediction,
      'averageMonthlyCost': averageMonthlyCost,
      'trend': trend,
    };
  }

  // Get fleet cost analysis
  Future<Map<String, dynamic>> getFleetCostAnalysis() async {
    final vehicles = await _vehicleDao.getAllVehicles();
    
    double totalFleetCost = 0.0;
    List<Map<String, dynamic>> vehicleCosts = [];

    for (final vehicle in vehicles) {
      final vehicleCost = await getTotalCosts(vehicle.id!);
      totalFleetCost += vehicleCost;
      
      vehicleCosts.add({
        'vehicle': vehicle,
        'totalCost': vehicleCost,
      });
    }

    // Sort by cost (highest first)
    vehicleCosts.sort((a, b) => (b['totalCost'] as double).compareTo(a['totalCost'] as double));

    return {
      'totalFleetCost': totalFleetCost,
      'vehicleCosts': vehicleCosts,
      'averageCostPerVehicle': vehicles.isNotEmpty ? totalFleetCost / vehicles.length : 0.0,
    };
  }
}