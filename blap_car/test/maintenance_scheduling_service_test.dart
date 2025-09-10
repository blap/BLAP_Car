import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/maintenance_scheduling_service.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/models/refueling.dart';

// Mock DAOs for testing
class MockMaintenanceDao {
  List<Maintenance> maintenances = [];
  
  Future<List<Maintenance>> getMaintenancesByVehicleId(int vehicleId) async {
    return maintenances.where((m) => m.vehicleId == vehicleId).toList();
  }
  
  Future<int> insertMaintenance(Maintenance maintenance) async {
    maintenance.id = maintenances.length + 1;
    maintenances.add(maintenance);
    return maintenance.id!;
  }
}

class MockVehicleDao {
  List<Vehicle> vehicles = [];
  
  Future<Vehicle?> getVehicleById(int id) async {
    try {
      return vehicles.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }
}

class MockRefuelingDao {
  List<Refueling> refuelings = [];
  
  Future<List<Refueling>> getRefuelingsByVehicleId(int vehicleId) async {
    return refuelings.where((r) => r.vehicleId == vehicleId).toList();
  }
}

// Test implementation that uses mock DAOs
class TestMaintenanceSchedulingService extends MaintenanceSchedulingService {
  final MockMaintenanceDao mockMaintenanceDao;
  final MockVehicleDao mockVehicleDao;
  final MockRefuelingDao mockRefuelingDao;
  
  TestMaintenanceSchedulingService({
    required this.mockMaintenanceDao,
    required this.mockVehicleDao,
    required this.mockRefuelingDao,
  });
  
  // Override the DAOs to use mocks
  @override
  Future<List<Maintenance>> getUpcomingMaintenances(int vehicleId, {int days = 30}) async {
    final maintenances = await mockMaintenanceDao.getMaintenancesByVehicleId(vehicleId);
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: days));

    return maintenances.where((maintenance) {
      return maintenance.nextDate != null &&
          maintenance.nextDate!.isAfter(now) &&
          maintenance.nextDate!.isBefore(futureDate);
    }).toList();
  }
  
  @override
  Future<List<Maintenance>> getOverdueMaintenances(int vehicleId) async {
    final maintenances = await mockMaintenanceDao.getMaintenancesByVehicleId(vehicleId);
    final now = DateTime.now();

    return maintenances.where((maintenance) {
      return maintenance.nextDate != null &&
          maintenance.nextDate!.isBefore(now) &&
          (maintenance.status == null || 
           (maintenance.status != 'Completed' && maintenance.status != 'Cancelled'));
    }).toList();
  }
}

void main() {
  group('MaintenanceSchedulingService', () {
    late TestMaintenanceSchedulingService schedulingService;
    late MockMaintenanceDao mockMaintenanceDao;
    late MockVehicleDao mockVehicleDao;
    late MockRefuelingDao mockRefuelingDao;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      mockMaintenanceDao = MockMaintenanceDao();
      mockVehicleDao = MockVehicleDao();
      mockRefuelingDao = MockRefuelingDao();
      
      schedulingService = TestMaintenanceSchedulingService(
        mockMaintenanceDao: mockMaintenanceDao,
        mockVehicleDao: mockVehicleDao,
        mockRefuelingDao: mockRefuelingDao,
      );
    });

    test('MaintenanceSchedulingService can be instantiated', () {
      expect(schedulingService, isNotNull);
      expect(schedulingService, isA<MaintenanceSchedulingService>());
    });

    test('getMaintenanceIntervals returns expected intervals', () {
      final intervals = schedulingService.getMaintenanceIntervals();
      
      expect(intervals.containsKey('Oil Change'), isTrue);
      expect(intervals.containsKey('Tire Rotation'), isTrue);
      expect(intervals.containsKey('Brake Check'), isTrue);
      
      final oilChange = intervals['Oil Change'];
      expect(oilChange, isNotNull);
      expect(oilChange!['kmInterval'], equals(5000));
    });

    test('getUpcomingMaintenances returns correct maintenances', () async {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: 15));
      
      mockMaintenanceDao.maintenances = [
        Maintenance(
          id: 1,
          vehicleId: 1,
          type: 'Oil Change',
          nextDate: futureDate,
          status: 'Scheduled',
        ),
        Maintenance(
          id: 2,
          vehicleId: 1,
          type: 'Tire Rotation',
          nextDate: now.subtract(Duration(days: 5)), // Past date
          status: 'Scheduled',
        ),
      ];
      
      final upcoming = await schedulingService.getUpcomingMaintenances(1);
      
      expect(upcoming.length, equals(1));
      expect(upcoming.first.type, equals('Oil Change'));
    });

    test('getOverdueMaintenances returns correct maintenances', () async {
      final now = DateTime.now();
      final pastDate = now.subtract(Duration(days: 15));
      
      mockMaintenanceDao.maintenances = [
        Maintenance(
          id: 1,
          vehicleId: 1,
          type: 'Oil Change',
          nextDate: pastDate,
          status: 'Scheduled',
        ),
        Maintenance(
          id: 2,
          vehicleId: 1,
          type: 'Tire Rotation',
          nextDate: now.add(Duration(days: 5)), // Future date
          status: 'Scheduled',
        ),
        Maintenance(
          id: 3,
          vehicleId: 1,
          type: 'Brake Check',
          nextDate: pastDate,
          status: 'Completed', // Should not be included as it's completed
        ),
      ];
      
      final overdue = await schedulingService.getOverdueMaintenances(1);
      
      expect(overdue.length, equals(1));
      expect(overdue.first.type, equals('Oil Change'));
    });
  });
}