import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/database/vehicle_dao.dart';
import 'package:blap_car/database/refueling_dao.dart';
import 'package:blap_car/database/expense_dao.dart';
import 'package:blap_car/database/maintenance_dao.dart';

class FleetManagementService {
  final VehicleDao _vehicleDao = VehicleDao();
  final RefuelingDao _refuelingDao = RefuelingDao();
  final ExpenseDao _expenseDao = ExpenseDao();
  final MaintenanceDao _maintenanceDao = MaintenanceDao();

  // Get fleet overview
  Future<Map<String, dynamic>> getFleetOverview() async {
    final vehicles = await _vehicleDao.getAllVehicles();
    
    int totalVehicles = vehicles.length;
    int activeVehicles = 0;
    int inactiveVehicles = 0;
    
    // Count active vs inactive vehicles
    for (final vehicle in vehicles) {
      if (vehicle.id != null) {
        // For simplicity, we'll consider vehicles with recent activity as active
        final recentRefuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicle.id!);
        final recentExpenses = await _expenseDao.getExpensesByVehicleId(vehicle.id!);
        final recentMaintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicle.id!);
        
        if (recentRefuelings.isNotEmpty || recentExpenses.isNotEmpty || recentMaintenances.isNotEmpty) {
          activeVehicles++;
        } else {
          inactiveVehicles++;
        }
      }
    }

    return {
      'totalVehicles': totalVehicles,
      'activeVehicles': activeVehicles,
      'inactiveVehicles': inactiveVehicles,
      'vehicles': vehicles,
    };
  }

  // Get fleet costs summary
  Future<Map<String, dynamic>> getFleetCostsSummary() async {
    final vehicles = await _vehicleDao.getAllVehicles();
    
    double totalFleetCost = 0.0;
    double totalFuelCost = 0.0;
    double totalMaintenanceCost = 0.0;
    double totalExpenseCost = 0.0;
    
    List<Map<String, dynamic>> vehicleCosts = [];

    for (final vehicle in vehicles) {
      if (vehicle.id != null) {
        final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicle.id!);
        final expenses = await _expenseDao.getExpensesByVehicleId(vehicle.id!);
        final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicle.id!);

        double vehicleFuelCost = 0.0;
        double vehicleMaintenanceCost = 0.0;
        double vehicleExpenseCost = 0.0;

        // Calculate fuel costs
        for (final refueling in refuelings) {
          vehicleFuelCost += refueling.totalCost ?? 0;
        }

        // Calculate maintenance costs
        for (final maintenance in maintenances) {
          vehicleMaintenanceCost += maintenance.cost ?? 0;
        }

        // Calculate other expense costs
        for (final expense in expenses) {
          vehicleExpenseCost += expense.cost ?? 0;
        }

        final vehicleTotalCost = vehicleFuelCost + vehicleMaintenanceCost + vehicleExpenseCost;

        vehicleCosts.add({
          'vehicle': vehicle,
          'totalCost': vehicleTotalCost,
          'fuelCost': vehicleFuelCost,
          'maintenanceCost': vehicleMaintenanceCost,
          'expenseCost': vehicleExpenseCost,
        });

        totalFleetCost += vehicleTotalCost;
        totalFuelCost += vehicleFuelCost;
        totalMaintenanceCost += vehicleMaintenanceCost;
        totalExpenseCost += vehicleExpenseCost;
      }
    }

    // Sort by total cost (highest first)
    vehicleCosts.sort((a, b) => (b['totalCost'] as double).compareTo(a['totalCost'] as double));

    return {
      'totalFleetCost': totalFleetCost,
      'totalFuelCost': totalFuelCost,
      'totalMaintenanceCost': totalMaintenanceCost,
      'totalExpenseCost': totalExpenseCost,
      'vehicleCosts': vehicleCosts,
      'averageCostPerVehicle': vehicles.isNotEmpty ? totalFleetCost / vehicles.length : 0.0,
    };
  }

  // Get fleet maintenance overview
  Future<Map<String, dynamic>> getFleetMaintenanceOverview() async {
    final vehicles = await _vehicleDao.getAllVehicles();
    
    int totalMaintenances = 0;
    int completedMaintenances = 0;
    int pendingMaintenances = 0;
    int overdueMaintenances = 0;
    
    List<Map<String, dynamic>> vehicleMaintenances = [];
    final now = DateTime.now();

    for (final vehicle in vehicles) {
      if (vehicle.id != null) {
        final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicle.id!);
        
        int vehicleTotal = maintenances.length;
        int vehicleCompleted = 0;
        int vehiclePending = 0;
        int vehicleOverdue = 0;

        for (final maintenance in maintenances) {
          if (maintenance.status == 'Completed') {
            vehicleCompleted++;
          } else if (maintenance.status == 'Scheduled' || maintenance.status == 'In Progress') {
            vehiclePending++;
            
            // Check if overdue
            if (maintenance.nextDate != null && maintenance.nextDate!.isBefore(now)) {
              vehicleOverdue++;
            }
          }
        }

        vehicleMaintenances.add({
          'vehicle': vehicle,
          'total': vehicleTotal,
          'completed': vehicleCompleted,
          'pending': vehiclePending,
          'overdue': vehicleOverdue,
        });

        totalMaintenances += vehicleTotal;
        completedMaintenances += vehicleCompleted;
        pendingMaintenances += vehiclePending;
        overdueMaintenances += vehicleOverdue;
      }
    }

    // Sort by total maintenances (highest first)
    vehicleMaintenances.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));

    return {
      'totalMaintenances': totalMaintenances,
      'completedMaintenances': completedMaintenances,
      'pendingMaintenances': pendingMaintenances,
      'overdueMaintenances': overdueMaintenances,
      'vehicleMaintenances': vehicleMaintenances,
    };
  }

  // Get fleet utilization report
  Future<Map<String, dynamic>> getFleetUtilizationReport() async {
    final vehicles = await _vehicleDao.getAllVehicles();
    
    double totalFleetKm = 0.0;
    List<Map<String, dynamic>> vehicleUtilization = [];

    for (final vehicle in vehicles) {
      if (vehicle.id != null) {
        final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicle.id!);
        
        if (refuelings.isNotEmpty) {
          // Sort refuelings by odometer
          refuelings.sort((a, b) => a.odometer.compareTo(b.odometer));
          
          final firstOdometer = refuelings.first.odometer;
          final lastOdometer = refuelings.last.odometer;
          final totalKm = lastOdometer - firstOdometer;
          
          // Calculate age in months
          final ageInMonths = DateTime.now().difference(vehicle.createdAt).inDays / 30;
          final monthlyUsage = ageInMonths > 0 ? totalKm / ageInMonths : 0.0;

          vehicleUtilization.add({
            'vehicle': vehicle,
            'totalKm': totalKm,
            'monthlyUsage': monthlyUsage,
            'firstOdometer': firstOdometer,
            'lastOdometer': lastOdometer,
          });

          totalFleetKm += totalKm;
        } else {
          vehicleUtilization.add({
            'vehicle': vehicle,
            'totalKm': 0.0,
            'monthlyUsage': 0.0,
            'firstOdometer': 0.0,
            'lastOdometer': 0.0,
          });
        }
      }
    }

    // Sort by total km (highest first)
    vehicleUtilization.sort((a, b) => (b['totalKm'] as double).compareTo(a['totalKm'] as double));

    return {
      'totalFleetKm': totalFleetKm,
      'vehicleUtilization': vehicleUtilization,
      'averageKmPerVehicle': vehicles.isNotEmpty ? totalFleetKm / vehicles.length : 0.0,
    };
  }

  // Get fleet alerts and notifications
  Future<List<Map<String, dynamic>>> getFleetAlerts() async {
    final vehicles = await _vehicleDao.getAllVehicles();
    final alerts = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (final vehicle in vehicles) {
      if (vehicle.id != null) {
        // Check for overdue maintenances
        final maintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicle.id!);
        for (final maintenance in maintenances) {
          if ((maintenance.status == 'Scheduled' || maintenance.status == 'In Progress') &&
              maintenance.nextDate != null && 
              maintenance.nextDate!.isBefore(now)) {
            alerts.add({
              'type': 'overdue_maintenance',
              'vehicle': vehicle,
              'maintenance': maintenance,
              'severity': 'high',
              'message': 'Overdue maintenance: ${maintenance.type} for ${vehicle.name}',
            });
          }
        }

        // Check for vehicles with no recent activity (potentially inactive)
        final recentRefuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicle.id!);
        final recentExpenses = await _expenseDao.getExpensesByVehicleId(vehicle.id!);
        final recentMaintenances = await _maintenanceDao.getMaintenancesByVehicleId(vehicle.id!);
        
        if (recentRefuelings.isEmpty && recentExpenses.isEmpty && recentMaintenances.isEmpty) {
          alerts.add({
            'type': 'inactive_vehicle',
            'vehicle': vehicle,
            'severity': 'medium',
            'message': 'Vehicle ${vehicle.name} has no recent activity',
          });
        }

      }
    }

    return alerts;
  }

  // Get fleet performance metrics
  Future<Map<String, dynamic>> getFleetPerformanceMetrics() async {
    final vehicles = await _vehicleDao.getAllVehicles();
    
    double totalFleetEfficiency = 0.0;
    int vehicleCount = 0;
    
    List<Map<String, dynamic>> vehicleEfficiencies = [];

    for (final vehicle in vehicles) {
      if (vehicle.id != null) {
        final refuelings = await _refuelingDao.getRefuelingsByVehicleId(vehicle.id!);
        
        if (refuelings.length > 1) {
          // Calculate fuel efficiency for this vehicle
          refuelings.sort((a, b) => a.odometer.compareTo(b.odometer));

          double totalLiters = 0.0;
          double totalKm = 0.0;
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
                totalKm += kmDriven;
              }
            }
          }

          if (consumptions.isNotEmpty) {
            final averageConsumption = consumptions.reduce((a, b) => a + b) / consumptions.length;
            
            vehicleEfficiencies.add({
              'vehicle': vehicle,
              'efficiency': averageConsumption,
              'totalKm': totalKm,
              'totalLiters': totalLiters,
            });

            totalFleetEfficiency += averageConsumption;
            vehicleCount++;
          }
        }
      }
    }

    // Sort by efficiency (best first - lowest consumption)
    if (vehicleEfficiencies.isNotEmpty) {
      vehicleEfficiencies.sort((a, b) => (a['efficiency'] as double).compareTo(b['efficiency'] as double));
    }

    return {
      'fleetAverageEfficiency': vehicleCount > 0 ? totalFleetEfficiency / vehicleCount : 0.0,
      'bestEfficiencyVehicle': vehicleEfficiencies.isNotEmpty ? vehicleEfficiencies.first : null,
      'worstEfficiencyVehicle': vehicleEfficiencies.isNotEmpty ? vehicleEfficiencies.last : null,
      'vehicleEfficiencies': vehicleEfficiencies,
    };
  }

  // Generate fleet summary report
  Future<String> generateFleetSummaryReport() async {
    final overview = await getFleetOverview();
    final costs = await getFleetCostsSummary();
    final maintenance = await getFleetMaintenanceOverview();
    final utilization = await getFleetUtilizationReport();
    final performance = await getFleetPerformanceMetrics();

    StringBuffer report = StringBuffer();
    report.writeln('FLEET MANAGEMENT SUMMARY REPORT');
    report.writeln('===============================');
    report.writeln();

    // Fleet Overview
    report.writeln('FLEET OVERVIEW:');
    report.writeln('--------------');
    report.writeln('Total Vehicles: ${overview['totalVehicles']}');
    report.writeln('Active Vehicles: ${overview['activeVehicles']}');
    report.writeln('Inactive Vehicles: ${overview['inactiveVehicles']}');
    report.writeln();

    // Cost Summary
    report.writeln('COST SUMMARY:');
    report.writeln('------------');
    report.writeln('Total Fleet Cost: \$${(costs['totalFleetCost'] as double?)?.toStringAsFixed(2) ?? '0.00'}');
    report.writeln('Fuel Costs: \$${(costs['totalFuelCost'] as double?)?.toStringAsFixed(2) ?? '0.00'}');
    report.writeln('Maintenance Costs: \$${(costs['totalMaintenanceCost'] as double?)?.toStringAsFixed(2) ?? '0.00'}');
    report.writeln('Other Expenses: \$${(costs['totalExpenseCost'] as double?)?.toStringAsFixed(2) ?? '0.00'}');
    report.writeln('Average Cost Per Vehicle: \$${(costs['averageCostPerVehicle'] as double?)?.toStringAsFixed(2) ?? '0.00'}');
    report.writeln();

    // Maintenance Overview
    report.writeln('MAINTENANCE OVERVIEW:');
    report.writeln('-------------------');
    report.writeln('Total Maintenances: ${maintenance['totalMaintenances']}');
    report.writeln('Completed: ${maintenance['completedMaintenances']}');
    report.writeln('Pending: ${maintenance['pendingMaintenances']}');
    report.writeln('Overdue: ${maintenance['overdueMaintenances']}');
    report.writeln();

    // Utilization
    report.writeln('UTILIZATION:');
    report.writeln('-----------');
    report.writeln('Total Fleet Distance: ${(utilization['totalFleetKm'] as double?)?.toStringAsFixed(0) ?? '0'} km');
    report.writeln('Average Distance Per Vehicle: ${(utilization['averageKmPerVehicle'] as double?)?.toStringAsFixed(0) ?? '0'} km');
    report.writeln();

    // Performance
    report.writeln('PERFORMANCE:');
    report.writeln('-----------');
    report.writeln('Fleet Average Efficiency: ${(performance['fleetAverageEfficiency'] as double?)?.toStringAsFixed(2) ?? '0.00'} L/100km');
    
    if (performance['bestEfficiencyVehicle'] != null) {
      final best = performance['bestEfficiencyVehicle'] as Map<String, dynamic>;
      final vehicle = best['vehicle'] as Vehicle;
      report.writeln('Best Efficiency Vehicle: ${vehicle.name} (${(best['efficiency'] as double?)?.toStringAsFixed(2) ?? '0.00'} L/100km)');
    }
    
    if (performance['worstEfficiencyVehicle'] != null) {
      final worst = performance['worstEfficiencyVehicle'] as Map<String, dynamic>;
      final vehicle = worst['vehicle'] as Vehicle;
      report.writeln('Worst Efficiency Vehicle: ${vehicle.name} (${(worst['efficiency'] as double?)?.toStringAsFixed(2) ?? '0.00'} L/100km)');
    }

    return report.toString();
  }
}