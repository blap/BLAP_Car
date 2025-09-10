import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/database/refueling_dao.dart';
import 'package:blap_car/database/expense_dao.dart';
import 'package:blap_car/database/maintenance_dao.dart';

class VehicleComparisonService {
  final VehicleDao _vehicleDao = VehicleDao();
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final MaintenanceDao _maintenanceDao = MaintenanceDao();

  // Compare multiple vehicles
  Future<Map<String, dynamic>> compareVehicles(List<int> vehicleIds) async {
    if (vehicleIds.isEmpty) {
      return {
        'vehicles': [],
        'comparison': {},
      };
    }

    List<Map<String, dynamic>> vehicleData = [];

    // Get data for each vehicle
    for (final vehicleId in vehicleIds) {
      final vehicle = await _vehicleDao.getVehicleById(vehicleId);
      if (vehicle != null) {
        final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
        final expenses = await _expenseDao.getExpensesByVehicleId(vehicleId);
        final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);

        final fuelEfficiency = _calculateFuelEfficiency(refuelings);
        final totalCosts = _calculateTotalCosts(refuelings, expenses, maintenances);
        final usageMetrics = _calculateUsageMetrics(refuelings);

        vehicleData.add({
          'vehicle': vehicle,
          'refuelings': refuelings,
          'expenses': expenses,
          'maintenances': maintenances,
          'fuelEfficiency': fuelEfficiency,
          'totalCosts': totalCosts,
          'usageMetrics': usageMetrics,
        });
      }
    }

    // Calculate comparison metrics
    final comparison = _calculateComparisonMetrics(vehicleData);

    return {
      'vehicles': vehicleData,
      'comparison': comparison,
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

  // Calculate comparison metrics
  Map<String, dynamic> _calculateComparisonMetrics(List<Map<String, dynamic>> vehicleData) {
    if (vehicleData.isEmpty) {
      return {
        'bestFuelEfficiency': null,
        'worstFuelEfficiency': null,
        'lowestTotalCost': null,
        'highestTotalCost': null,
        'mostUsed': null,
        'leastUsed': null,
      };
    }

    // Find best and worst fuel efficiency
    vehicleData.sort((a, b) => 
        (a['fuelEfficiency']['averageConsumption'] as double)
            .compareTo(b['fuelEfficiency']['averageConsumption'] as double));
    
    final bestFuelEfficiency = vehicleData.first;
    final worstFuelEfficiency = vehicleData.last;

    // Find lowest and highest total costs
    vehicleData.sort((a, b) => 
        (a['totalCosts']['total'] as double)
            .compareTo(b['totalCosts']['total'] as double));
    
    final lowestTotalCost = vehicleData.first;
    final highestTotalCost = vehicleData.last;

    // Find most and least used vehicles
    vehicleData.sort((a, b) => 
        (a['usageMetrics']['totalKm'] as double)
            .compareTo(b['usageMetrics']['totalKm'] as double));
    
    final mostUsed = vehicleData.last;
    final leastUsed = vehicleData.first;

    return {
      'bestFuelEfficiency': bestFuelEfficiency,
      'worstFuelEfficiency': worstFuelEfficiency,
      'lowestTotalCost': lowestTotalCost,
      'highestTotalCost': highestTotalCost,
      'mostUsed': mostUsed,
      'leastUsed': leastUsed,
    };
  }

  // Get vehicle ranking by specific metric
  Future<List<Map<String, dynamic>>> getVehicleRankingByMetric(
    List<int> vehicleIds,
    String metric,
  ) async {
    final comparisonData = await compareVehicles(vehicleIds);
    final vehicles = comparisonData['vehicles'] as List<Map<String, dynamic>>;

    switch (metric) {
      case 'fuelEfficiency':
        // Sort by average consumption (lower is better)
        vehicles.sort((a, b) => 
            (a['fuelEfficiency']['averageConsumption'] as double)
                .compareTo(b['fuelEfficiency']['averageConsumption'] as double));
        break;
      
      case 'totalCost':
        // Sort by total cost (lower is better)
        vehicles.sort((a, b) => 
            (a['totalCosts']['total'] as double)
                .compareTo(b['totalCosts']['total'] as double));
        break;
      
      case 'usage':
        // Sort by total km (higher might be better depending on context)
        vehicles.sort((a, b) => 
            (b['usageMetrics']['totalKm'] as double)
                .compareTo(a['usageMetrics']['totalKm'] as double));
        break;
      
      default:
        // Default sort by vehicle name
        vehicles.sort((a, b) => 
            (a['vehicle'] as Vehicle).name.compareTo((b['vehicle'] as Vehicle).name));
    }

    return vehicles;
  }

  // Get detailed comparison report
  Future<String> getDetailedComparisonReport(List<int> vehicleIds) async {
    final comparisonData = await compareVehicles(vehicleIds);
    final vehicles = comparisonData['vehicles'] as List<Map<String, dynamic>>;
    final comparison = comparisonData['comparison'] as Map<String, dynamic>;

    if (vehicles.isEmpty) {
      return 'No vehicles to compare.';
    }

    StringBuffer report = StringBuffer();
    report.writeln('VEHICLE COMPARISON REPORT');
    report.writeln('========================');
    report.writeln();

    // Vehicle details
    report.writeln('VEHICLE DETAILS:');
    report.writeln('----------------');
    for (final vehicleData in vehicles) {
      final vehicle = vehicleData['vehicle'] as Vehicle;
      final fuelEfficiency = vehicleData['fuelEfficiency'] as Map<String, dynamic>;
      final totalCosts = vehicleData['totalCosts'] as Map<String, double>;
      final usageMetrics = vehicleData['usageMetrics'] as Map<String, dynamic>;

      report.writeln('${vehicle.name} (${vehicle.make} ${vehicle.model} ${vehicle.year})');
      report.writeln('  Fuel Efficiency: ${fuelEfficiency['averageConsumption']?.toStringAsFixed(2) ?? '0.00'} L/100km');
      report.writeln('  Total Costs: \$${totalCosts['total']?.toStringAsFixed(2) ?? '0.00'}');
      report.writeln('  Total Distance: ${usageMetrics['totalKm']?.toStringAsFixed(0) ?? '0'} km');
      report.writeln();
    }

    // Comparison highlights
    report.writeln('COMPARISON HIGHLIGHTS:');
    report.writeln('----------------------');
    
    if (comparison['bestFuelEfficiency'] != null) {
      final best = comparison['bestFuelEfficiency'] as Map<String, dynamic>;
      final vehicle = best['vehicle'] as Vehicle;
      final efficiency = best['fuelEfficiency'] as Map<String, dynamic>;
      report.writeln('Best Fuel Efficiency: ${vehicle.name} (${efficiency['averageConsumption']?.toStringAsFixed(2) ?? '0.00'} L/100km)');
    }

    if (comparison['lowestTotalCost'] != null) {
      final lowest = comparison['lowestTotalCost'] as Map<String, dynamic>;
      final vehicle = lowest['vehicle'] as Vehicle;
      final costs = lowest['totalCosts'] as Map<String, double>;
      report.writeln('Lowest Total Cost: ${vehicle.name} (\$${costs['total']?.toStringAsFixed(2) ?? '0.00'})');
    }
    if (comparison['mostUsed'] != null) {
      final most = comparison['mostUsed'] as Map<String, dynamic>;
      final vehicle = most['vehicle'] as Vehicle;
      final usage = most['usageMetrics'] as Map<String, dynamic>;
      report.writeln('Most Used: ${vehicle.name} (${usage['totalKm']?.toStringAsFixed(0) ?? '0'} km)');
    }

    return report.toString();
  }
}