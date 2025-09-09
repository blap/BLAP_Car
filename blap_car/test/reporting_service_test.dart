import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/reporting_service.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/models/vehicle.dart';

class MockRefuelingDao {
  List<Refueling> refuelings = [];
  
  Future<List<Refueling>> getRefuelingsByVehicleId(int vehicleId) async {
    return refuelings.where((r) => r.vehicleId == vehicleId).toList();
  }
}

class MockExpenseDao {
  List<Expense> expenses = [];
  
  Future<List<Expense>> getExpensesByVehicleId(int vehicleId) async {
    return expenses.where((e) => e.vehicleId == vehicleId).toList();
  }
}

class MockVehicleDao {
  List<Vehicle> vehicles = [];
  
  Future<List<Vehicle>> getAllVehicles() async {
    return vehicles;
  }
}

// Create a testable version of ReportingService
class TestReportingService extends ReportingService {
  final MockRefuelingDao mockRefuelingDao;
  final MockExpenseDao mockExpenseDao;
  final MockVehicleDao mockVehicleDao;
  
  TestReportingService(this.mockRefuelingDao, this.mockExpenseDao, this.mockVehicleDao);
  
  // Override the getters to return mock DAOs
  @override
  Future<List<Refueling>> getRefuelingsByVehicleId(int vehicleId) async {
    return await mockRefuelingDao.getRefuelingsByVehicleId(vehicleId);
  }
  
  @override
  Future<List<Expense>> getExpensesByVehicleId(int vehicleId) async {
    return await mockExpenseDao.getExpensesByVehicleId(vehicleId);
  }
  
  @override
  Future<List<Vehicle>> getAllVehicles() async {
    return await mockVehicleDao.getAllVehicles();
  }
}

void main() {
  group('ReportingService Tests', () {
    late TestReportingService reportingService;
    late MockRefuelingDao mockRefuelingDao;
    late MockExpenseDao mockExpenseDao;
    late MockVehicleDao mockVehicleDao;

    setUp(() {
      mockRefuelingDao = MockRefuelingDao();
      mockExpenseDao = MockExpenseDao();
      mockVehicleDao = MockVehicleDao();
      reportingService = TestReportingService(mockRefuelingDao, mockExpenseDao, mockVehicleDao);
    });

    test('calculateFuelEfficiencyStats returns correct data when no refuelings', () async {
      mockRefuelingDao.refuelings = [];
      
      final stats = await reportingService.calculateFuelEfficiencyStats(1);
      
      expect(stats['totalRefuelings'], 0);
      expect(stats['totalCost'], 0.0);
      expect(stats['totalLiters'], 0.0);
      expect(stats['totalDistance'], 0.0);
      expect(stats['averageConsumption'], 0.0);
      expect(stats['costPerKm'], 0.0);
    });

    test('calculateExpenseStats returns correct data when no expenses', () async {
      mockExpenseDao.expenses = [];
      
      final stats = await reportingService.calculateExpenseStats(1);
      
      expect(stats['totalExpenses'], 0);
      expect(stats['totalCost'], 0.0);
    });

    test('calculateGeneralStats returns correct data when no records', () async {
      mockRefuelingDao.refuelings = [];
      mockExpenseDao.expenses = [];
      
      final stats = await reportingService.calculateGeneralStats(1);
      
      expect(stats['totalRecords'], 0);
      expect(stats['totalCost'], 0.0);
      expect(stats['totalDistance'], 0.0);
      expect(stats['averageDailyCost'], 0.0);
      expect(stats['costPerKm'], 0.0);
    });
    
    test('calculateFuelEfficiencyStats calculates correct values', () async {
      final date1 = DateTime.now().subtract(Duration(days: 2));
      final date2 = DateTime.now().subtract(Duration(days: 1));
      
      mockRefuelingDao.refuelings = [
        Refueling(
          id: 1,
          vehicleId: 1,
          date: date1,
          odometer: 10000,
          liters: 50,
          totalCost: 250,
        ),
        Refueling(
          id: 2,
          vehicleId: 1,
          date: date2,
          odometer: 10500,
          liters: 45,
          totalCost: 225,
        ),
      ];
      
      final stats = await reportingService.calculateFuelEfficiencyStats(1);
      
      expect(stats['totalRefuelings'], 2);
      // Only the second refueling's cost is counted in the fuel efficiency calculation
      // because we calculate consumption between refueling events
      expect(stats['totalCost'], 225.0);
      expect(stats['totalLiters'], 45.0);
      expect(stats['totalDistance'], 500.0);
      expect(stats['averageConsumption'], 500.0 / 45.0);
    });
  });
}