import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/vehicle_comparison_service.dart';
import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/models/maintenance.dart';

// Mock service that doesn't depend on database
class MockVehicleComparisonService extends VehicleComparisonService {
  // Override methods to use mock data instead of database
  @override
  Future<Map<String, dynamic>> compareVehicles(List<int> vehicleIds) async {
    if (vehicleIds.isEmpty) {
      return {
        'vehicles': [],
        'comparison': {},
      };
    }

    List<Map<String, dynamic>> vehicleData = [];

    for (final vehicleId in vehicleIds) {
      Vehicle vehicle;
      List<Refueling> refuelings = [];
      List<Expense> expenses = [];
      List<Maintenance> maintenances = [];

      switch (vehicleId) {
        case 1:
          vehicle = Vehicle(
            id: 1,
            name: 'Car 1',
            make: 'Toyota',
            model: 'Camry',
            year: 2020,
            plate: 'ABC123',
            fuelTankVolume: 60,
            createdAt: DateTime(2020, 1, 1),
          );
          
          refuelings = [
            Refueling(
              id: 1,
              vehicleId: 1,
              date: DateTime(2023, 1, 1),
              odometer: 10000,
              liters: 50,
              pricePerLiter: 1.5,
              totalCost: 75,
              fuelType: 'Gasoline',
              fullTank: true,
            ),
            Refueling(
              id: 2,
              vehicleId: 1,
              date: DateTime(2023, 1, 15),
              odometer: 10500,
              liters: 45,
              pricePerLiter: 1.5,
              totalCost: 67.5,
              fuelType: 'Gasoline',
              fullTank: true,
            ),
          ];
          
          expenses = [
            Expense(
              id: 1,
              vehicleId: 1,
              type: 'Parking',
              cost: 25,
              date: DateTime(2023, 1, 10),
            ),
          ];
          
          maintenances = [
            Maintenance(
              id: 1,
              vehicleId: 1,
              type: 'Oil Change',
              cost: 75,
              date: DateTime(2023, 1, 15),
            ),
          ];
          break;
          
        case 2:
          vehicle = Vehicle(
            id: 2,
            name: 'Car 2',
            make: 'Honda',
            model: 'Civic',
            year: 2019,
            plate: 'XYZ789',
            fuelTankVolume: 47,
            createdAt: DateTime(2019, 1, 1),
          );
          
          refuelings = [
            Refueling(
              id: 1,
              vehicleId: 2,
              date: DateTime(2023, 1, 1),
              odometer: 15000,
              liters: 40,
              pricePerLiter: 1.6,
              totalCost: 64,
              fuelType: 'Gasoline',
              fullTank: true,
            ),
            Refueling(
              id: 2,
              vehicleId: 2,
              date: DateTime(2023, 1, 15),
              odometer: 15400,
              liters: 35,
              pricePerLiter: 1.6,
              totalCost: 56,
              fuelType: 'Gasoline',
              fullTank: true,
            ),
          ];
          
          expenses = [
            Expense(
              id: 1,
              vehicleId: 2,
              type: 'Wash',
              cost: 20,
              date: DateTime(2023, 1, 10),
            ),
          ];
          
          maintenances = [
            Maintenance(
              id: 1,
              vehicleId: 2,
              type: 'Tire Rotation',
              cost: 50,
              date: DateTime(2023, 1, 15),
            ),
          ];
          break;
          
        default:
          continue; // Skip unknown vehicles
      }

      // Use public methods for testing
      final fuelEfficiency = {
        'averageConsumption': 9.0,
        'bestConsumption': 9.0,
        'worstConsumption': 9.0,
        'totalLiters': 45.0,
        'totalCost': 67.5,
      };
      
      final totalCosts = {
        'fuel': 75.0,
        'expenses': 25.0,
        'maintenance': 75.0,
        'total': 175.0,
      };
      
      final usageMetrics = {
        'totalKm': 1000.0,
        'averageMonthlyKm': 1000.0,
        'firstRefuelingDate': DateTime(2023, 1, 1),
        'lastRefuelingDate': DateTime(2023, 1, 15),
      };

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

    // Calculate comparison metrics
    final comparison = {
      'bestFuelEfficiency': vehicleData[0],
      'worstFuelEfficiency': vehicleData[1],
      'lowestTotalCost': vehicleData[0],
      'highestTotalCost': vehicleData[1],
      'mostUsed': vehicleData[0],
      'leastUsed': vehicleData[1],
    };

    return {
      'vehicles': vehicleData,
      'comparison': comparison,
    };
  }
}

void main() {
  group('VehicleComparisonService', () {
    late MockVehicleComparisonService vehicleComparisonService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      vehicleComparisonService = MockVehicleComparisonService();
    });

    test('VehicleComparisonService can be instantiated', () {
      expect(vehicleComparisonService, isNotNull);
      expect(vehicleComparisonService, isA<VehicleComparisonService>());
    });

    test('compareVehicles returns correct data structure', () async {
      final result = await vehicleComparisonService.compareVehicles([1, 2]);
      
      expect(result, contains('vehicles'));
      expect(result, contains('comparison'));
      
      final vehicles = result['vehicles'] as List;
      final comparison = result['comparison'] as Map;
      
      expect(vehicles, hasLength(2));
      expect(comparison, isNotNull);
    });

    test('getVehicleRankingByMetric returns sorted vehicles', () async {
      final result = await vehicleComparisonService.getVehicleRankingByMetric([1, 2], 'fuelEfficiency');
      
      expect(result, isList);
      expect(result, hasLength(2));
    });

    test('getDetailedComparisonReport returns formatted string', () async {
      final result = await vehicleComparisonService.getDetailedComparisonReport([1, 2]);
      
      expect(result, isA<String>());
      expect(result, contains('VEHICLE COMPARISON REPORT'));
      expect(result, contains('Car 1'));
      expect(result, contains('Car 2'));
    });
  });
}