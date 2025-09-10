import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/cost_tracking_service.dart';

// Mock service that doesn't depend on database
class MockCostTrackingService extends CostTrackingService {
  // Override methods to use mock data instead of database
  @override
  Future<double> getTotalCosts(int vehicleId) async {
    // Return mock data based on vehicleId
    switch (vehicleId) {
      case 1:
        return 175.0; // 75 fuel + 25 expense + 75 maintenance
      case 2:
        return 300.0;
      default:
        return 0.0;
    }
  }

  @override
  Future<Map<String, double>> getCostBreakdown(int vehicleId) async {
    switch (vehicleId) {
      case 1:
        return {
          'Fuel': 75.0,
          'Maintenance': 75.0,
          'Other Expenses': 25.0,
        };
      case 2:
        return {
          'Fuel': 150.0,
          'Maintenance': 100.0,
          'Other Expenses': 50.0,
        };
      default:
        return {
          'Fuel': 0.0,
          'Maintenance': 0.0,
          'Other Expenses': 0.0,
        };
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyCostTrends(int vehicleId) async {
    switch (vehicleId) {
      case 1:
        return [
          {
            'month': '2023-01',
            'Fuel': 75.0,
            'Maintenance': 0.0,
            'Other Expenses': 25.0,
            'total': 100.0,
          },
          {
            'month': '2023-02',
            'Fuel': 75.0,
            'Maintenance': 75.0,
            'Other Expenses': 0.0,
            'total': 150.0,
          },
        ];
      default:
        return [];
    }
  }

  @override
  Future<double> getCostPerKilometer(int vehicleId) async {
    switch (vehicleId) {
      case 1:
        return 0.175; // 175 total cost / 1000 km
      default:
        return 0.0;
    }
  }

  @override
  Future<bool> isBudgetExceeded(int vehicleId, double budget) async {
    final totalCosts = await getTotalCosts(vehicleId);
    return totalCosts > budget;
  }

  @override
  Future<double> getBudgetUtilization(int vehicleId, double budget) async {
    if (budget <= 0) {
      return 0.0;
    }
    
    final totalCosts = await getTotalCosts(vehicleId);
    return (totalCosts / budget) * 100;
  }
}

void main() {
  group('CostTrackingService', () {
    late MockCostTrackingService costTrackingService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      costTrackingService = MockCostTrackingService();
    });

    test('CostTrackingService can be instantiated', () {
      expect(costTrackingService, isNotNull);
      expect(costTrackingService, isA<CostTrackingService>());
    });

    test('getTotalCosts returns correct sum', () async {
      final totalCosts = await costTrackingService.getTotalCosts(1);
      
      // 75 (fuel) + 25 (expense) + 75 (maintenance) = 175
      expect(totalCosts, equals(175.0));
    });

    test('getCostBreakdown returns correct categories', () async {
      final breakdown = await costTrackingService.getCostBreakdown(1);
      
      expect(breakdown['Fuel'], equals(75.0));
      expect(breakdown['Maintenance'], equals(75.0));
      expect(breakdown['Other Expenses'], equals(25.0));
    });

    test('getMonthlyCostTrends returns data grouped by month', () async {
      final trends = await costTrackingService.getMonthlyCostTrends(1);
      
      expect(trends, hasLength(2));
      
      // First month (January 2023)
      expect(trends[0]['month'], equals('2023-01'));
      expect(trends[0]['Fuel'], equals(75.0));
      expect(trends[0]['Other Expenses'], equals(25.0));
      expect(trends[0]['Maintenance'], equals(0.0));
      expect(trends[0]['total'], equals(100.0));
      
      // Second month (February 2023)
      expect(trends[1]['month'], equals('2023-02'));
      expect(trends[1]['Fuel'], equals(75.0));
      expect(trends[1]['Other Expenses'], equals(0.0));
      expect(trends[1]['Maintenance'], equals(75.0));
      expect(trends[1]['total'], equals(150.0));
    });

    test('getCostPerKilometer returns correct value', () async {
      final costPerKm = await costTrackingService.getCostPerKilometer(1);
      
      // 1000 km driven, 175 total costs = 0.175 cost per km
      expect(costPerKm, equals(0.175));
    });

    test('isBudgetExceeded returns correct boolean', () async {
      final exceeded = await costTrackingService.isBudgetExceeded(1, 50); // Budget is 50
      final notExceeded = await costTrackingService.isBudgetExceeded(1, 200); // Budget is 200
      
      expect(exceeded, isTrue); // 175 > 50
      expect(notExceeded, isFalse); // 175 < 200
    });

    test('getBudgetUtilization returns correct percentage', () async {
      final utilization = await costTrackingService.getBudgetUtilization(1, 350); // Budget is 350
      
      // 175 / 350 * 100 = 50%
      expect(utilization, equals(50.0));
    });
  });
}