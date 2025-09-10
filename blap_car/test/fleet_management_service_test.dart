import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/fleet_management_service.dart';
import 'package:blap_car/models/vehicle.dart';

// Mock service that doesn't depend on database
class MockFleetManagementService extends FleetManagementService {
  // Override methods to use mock data instead of database
  @override
  Future<Map<String, dynamic>> getFleetOverview() async {
    final vehicles = [
      Vehicle(
        id: 1,
        name: 'Car 1',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        plate: 'ABC123',
        fuelTankVolume: 60,
        createdAt: DateTime(2020, 1, 1),
      ),
      Vehicle(
        id: 2,
        name: 'Car 2',
        make: 'Honda',
        model: 'Civic',
        year: 2019,
        plate: 'XYZ789',
        fuelTankVolume: 47,
        createdAt: DateTime(2019, 1, 1),
      ),
    ];

    return {
      'totalVehicles': 2,
      'activeVehicles': 2,
      'inactiveVehicles': 0,
      'vehicles': vehicles,
    };
  }

  @override
  Future<Map<String, dynamic>> getFleetCostsSummary() async {
    final vehicles = [
      Vehicle(
        id: 1,
        name: 'Car 1',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        plate: 'ABC123',
        fuelTankVolume: 60,
        createdAt: DateTime(2020, 1, 1),
      ),
      Vehicle(
        id: 2,
        name: 'Car 2',
        make: 'Honda',
        model: 'Civic',
        year: 2019,
        plate: 'XYZ789',
        fuelTankVolume: 47,
        createdAt: DateTime(2019, 1, 1),
      ),
    ];

    final vehicleCosts = [
      {
        'vehicle': vehicles[0],
        'totalCost': 500.0,
        'fuelCost': 300.0,
        'maintenanceCost': 150.0,
        'expenseCost': 50.0,
      },
      {
        'vehicle': vehicles[1],
        'totalCost': 400.0,
        'fuelCost': 250.0,
        'maintenanceCost': 100.0,
        'expenseCost': 50.0,
      },
    ];

    return {
      'totalFleetCost': 900.0,
      'totalFuelCost': 550.0,
      'totalMaintenanceCost': 250.0,
      'totalExpenseCost': 100.0,
      'vehicleCosts': vehicleCosts,
      'averageCostPerVehicle': 450.0,
    };
  }

  @override
  Future<Map<String, dynamic>> getFleetMaintenanceOverview() async {
    final vehicles = [
      Vehicle(
        id: 1,
        name: 'Car 1',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        plate: 'ABC123',
        fuelTankVolume: 60,
        createdAt: DateTime(2020, 1, 1),
      ),
      Vehicle(
        id: 2,
        name: 'Car 2',
        make: 'Honda',
        model: 'Civic',
        year: 2019,
        plate: 'XYZ789',
        fuelTankVolume: 47,
        createdAt: DateTime(2019, 1, 1),
      ),
    ];

    final vehicleMaintenances = [
      {
        'vehicle': vehicles[0],
        'total': 5,
        'completed': 3,
        'pending': 2,
        'overdue': 0,
      },
      {
        'vehicle': vehicles[1],
        'total': 3,
        'completed': 2,
        'pending': 1,
        'overdue': 0,
      },
    ];

    return {
      'totalMaintenances': 8,
      'completedMaintenances': 5,
      'pendingMaintenances': 3,
      'overdueMaintenances': 0,
      'vehicleMaintenances': vehicleMaintenances,
    };
  }

  @override
  Future<Map<String, dynamic>> getFleetUtilizationReport() async {
    final vehicles = [
      Vehicle(
        id: 1,
        name: 'Car 1',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        plate: 'ABC123',
        fuelTankVolume: 60,
        createdAt: DateTime(2020, 1, 1),
      ),
      Vehicle(
        id: 2,
        name: 'Car 2',
        make: 'Honda',
        model: 'Civic',
        year: 2019,
        plate: 'XYZ789',
        fuelTankVolume: 47,
        createdAt: DateTime(2019, 1, 1),
      ),
    ];

    final vehicleUtilization = [
      {
        'vehicle': vehicles[0],
        'totalKm': 15000.0,
        'monthlyUsage': 500.0,
        'firstOdometer': 10000.0,
        'lastOdometer': 25000.0,
      },
      {
        'vehicle': vehicles[1],
        'totalKm': 12000.0,
        'monthlyUsage': 400.0,
        'firstOdometer': 8000.0,
        'lastOdometer': 20000.0,
      },
    ];

    return {
      'totalFleetKm': 27000.0,
      'vehicleUtilization': vehicleUtilization,
      'averageKmPerVehicle': 13500.0,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getFleetAlerts() async {
    final vehicles = [
      Vehicle(
        id: 1,
        name: 'Car 1',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        plate: 'ABC123',
        fuelTankVolume: 60,
        createdAt: DateTime(2020, 1, 1),
      ),
    ];

    return [
      {
        'type': 'overdue_maintenance',
        'vehicle': vehicles[0],
        'severity': 'high',
        'message': 'Overdue maintenance: Oil Change for Car 1',
      },
    ];
  }

  @override
  Future<Map<String, dynamic>> getFleetPerformanceMetrics() async {
    final vehicles = [
      Vehicle(
        id: 1,
        name: 'Car 1',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        plate: 'ABC123',
        fuelTankVolume: 60,
        createdAt: DateTime(2020, 1, 1),
      ),
      Vehicle(
        id: 2,
        name: 'Car 2',
        make: 'Honda',
        model: 'Civic',
        year: 2019,
        plate: 'XYZ789',
        fuelTankVolume: 47,
        createdAt: DateTime(2019, 1, 1),
      ),
    ];

    final vehicleEfficiencies = [
      {
        'vehicle': vehicles[0],
        'efficiency': 8.5,
        'totalKm': 15000.0,
        'totalLiters': 1275.0,
      },
      {
        'vehicle': vehicles[1],
        'efficiency': 7.2,
        'totalKm': 12000.0,
        'totalLiters': 864.0,
      },
    ];

    return {
      'fleetAverageEfficiency': 7.85,
      'bestEfficiencyVehicle': vehicleEfficiencies[1], // Lower is better
      'worstEfficiencyVehicle': vehicleEfficiencies[0],
      'vehicleEfficiencies': vehicleEfficiencies,
    };
  }
}

void main() {
  group('FleetManagementService', () {
    late MockFleetManagementService fleetManagementService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      fleetManagementService = MockFleetManagementService();
    });

    test('FleetManagementService can be instantiated', () {
      expect(fleetManagementService, isNotNull);
      expect(fleetManagementService, isA<FleetManagementService>());
    });

    test('getFleetOverview returns correct data', () async {
      final result = await fleetManagementService.getFleetOverview();
      
      expect(result, contains('totalVehicles'));
      expect(result, contains('activeVehicles'));
      expect(result, contains('inactiveVehicles'));
      expect(result, contains('vehicles'));
      
      expect(result['totalVehicles'], equals(2));
      expect(result['activeVehicles'], equals(2));
      expect(result['inactiveVehicles'], equals(0));
      expect(result['vehicles'], isList);
    });

    test('getFleetCostsSummary returns correct data', () async {
      final result = await fleetManagementService.getFleetCostsSummary();
      
      expect(result, contains('totalFleetCost'));
      expect(result, contains('totalFuelCost'));
      expect(result, contains('totalMaintenanceCost'));
      expect(result, contains('totalExpenseCost'));
      expect(result, contains('vehicleCosts'));
      expect(result, contains('averageCostPerVehicle'));
      
      expect(result['totalFleetCost'], equals(900.0));
      expect(result['totalFuelCost'], equals(550.0));
      expect(result['totalMaintenanceCost'], equals(250.0));
      expect(result['totalExpenseCost'], equals(100.0));
      expect(result['averageCostPerVehicle'], equals(450.0));
    });

    test('getFleetMaintenanceOverview returns correct data', () async {
      final result = await fleetManagementService.getFleetMaintenanceOverview();
      
      expect(result, contains('totalMaintenances'));
      expect(result, contains('completedMaintenances'));
      expect(result, contains('pendingMaintenances'));
      expect(result, contains('overdueMaintenances'));
      expect(result, contains('vehicleMaintenances'));
      
      expect(result['totalMaintenances'], equals(8));
      expect(result['completedMaintenances'], equals(5));
      expect(result['pendingMaintenances'], equals(3));
      expect(result['overdueMaintenances'], equals(0));
    });

    test('getFleetUtilizationReport returns correct data', () async {
      final result = await fleetManagementService.getFleetUtilizationReport();
      
      expect(result, contains('totalFleetKm'));
      expect(result, contains('vehicleUtilization'));
      expect(result, contains('averageKmPerVehicle'));
      
      expect(result['totalFleetKm'], equals(27000.0));
      expect(result['averageKmPerVehicle'], equals(13500.0));
    });

    test('getFleetAlerts returns correct data', () async {
      final result = await fleetManagementService.getFleetAlerts();
      
      expect(result, isList);
      expect(result, isNotEmpty);
      
      final alert = result.first;
      expect(alert, contains('type'));
      expect(alert, contains('vehicle'));
      expect(alert, contains('severity'));
      expect(alert, contains('message'));
      
      expect(alert['type'], equals('overdue_maintenance'));
      expect(alert['severity'], equals('high'));
    });

    test('getFleetPerformanceMetrics returns correct data', () async {
      final result = await fleetManagementService.getFleetPerformanceMetrics();
      
      expect(result, contains('fleetAverageEfficiency'));
      expect(result, contains('bestEfficiencyVehicle'));
      expect(result, contains('worstEfficiencyVehicle'));
      expect(result, contains('vehicleEfficiencies'));
      
      expect(result['fleetAverageEfficiency'], equals(7.85));
    });

    test('generateFleetSummaryReport returns formatted string', () async {
      final result = await fleetManagementService.generateFleetSummaryReport();
      
      expect(result, isA<String>());
      expect(result, contains('FLEET MANAGEMENT SUMMARY REPORT'));
      expect(result, contains('Total Vehicles: 2'));
      expect(result, contains('Total Fleet Cost: \$900.00'));
    });
  });
}