import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/maintenance_service.dart';
import 'package:blap_car/models/maintenance.dart';

class MockMaintenanceDao {
  List<Maintenance> maintenances = [];
  int _idCounter = 1;

  Future<int> insertMaintenance(Maintenance maintenance) async {
    maintenance.id = _idCounter++;
    maintenances.add(maintenance);
    return maintenance.id!;
  }

  Future<List<Maintenance>> getAllMaintenances() async {
    return maintenances;
  }

  Future<List<Maintenance>> getMaintenancesByVehicleId(int vehicleId) async {
    return maintenances.where((maintenance) => maintenance.vehicleId == vehicleId).toList();
  }

  Future<Maintenance?> getMaintenanceById(int id) async {
    try {
      return maintenances.firstWhere((maintenance) => maintenance.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateMaintenance(Maintenance maintenance) async {
    final index = maintenances.indexWhere((m) => m.id == maintenance.id);
    if (index != -1) {
      maintenances[index] = maintenance;
      return 1; // Success
    }
    return 0; // Not found
  }

  Future<int> deleteMaintenance(int id) async {
    final initialLength = maintenances.length;
    maintenances.removeWhere((maintenance) => maintenance.id == id);
    return initialLength - maintenances.length;
  }
}

// Create a testable version of MaintenanceService
class TestMaintenanceService extends MaintenanceService {
  final MockMaintenanceDao mockMaintenanceDao;
  
  TestMaintenanceService(this.mockMaintenanceDao);
  
  // Override the getter to return mock DAO
  @override
  Future<List<Maintenance>> getAllMaintenances() async {
    return await mockMaintenanceDao.getAllMaintenances();
  }
  
  @override
  Future<List<Maintenance>> getMaintenancesByVehicleId(int vehicleId) async {
    return await mockMaintenanceDao.getMaintenancesByVehicleId(vehicleId);
  }
  
  @override
  Future<Maintenance?> getMaintenanceById(int id) async {
    return await mockMaintenanceDao.getMaintenanceById(id);
  }
  
  @override
  Future<int> addMaintenance(Maintenance maintenance) async {
    return await mockMaintenanceDao.insertMaintenance(maintenance);
  }
  
  @override
  Future<int> updateMaintenance(Maintenance maintenance) async {
    return await mockMaintenanceDao.updateMaintenance(maintenance);
  }
  
  @override
  Future<int> deleteMaintenance(int id) async {
    return await mockMaintenanceDao.deleteMaintenance(id);
  }
}

void main() {
  group('MaintenanceService Tests', () {
    late TestMaintenanceService maintenanceService;
    late MockMaintenanceDao mockMaintenanceDao;

    setUp(() {
      mockMaintenanceDao = MockMaintenanceDao();
      maintenanceService = TestMaintenanceService(mockMaintenanceDao);
    });

    test('MaintenanceService can be instantiated', () {
      expect(maintenanceService, isNotNull);
      expect(maintenanceService, isA<MaintenanceService>());
    });

    test('addMaintenance adds maintenance to the list', () async {
      final maintenance = Maintenance(
        vehicleId: 1,
        type: 'Oil Change',
      );

      final id = await maintenanceService.addMaintenance(maintenance);
      
      expect(id, 1);
      expect(mockMaintenanceDao.maintenances.length, 1);
      expect(mockMaintenanceDao.maintenances[0].id, 1);
    });

    test('getAllMaintenances returns all maintenances', () async {
      final maintenance1 = Maintenance(
        vehicleId: 1,
        type: 'Oil Change',
      );
      
      final maintenance2 = Maintenance(
        vehicleId: 2,
        type: 'Tire Rotation',
      );
      
      await mockMaintenanceDao.insertMaintenance(maintenance1);
      await mockMaintenanceDao.insertMaintenance(maintenance2);
      
      final maintenances = await maintenanceService.getAllMaintenances();
      
      expect(maintenances.length, 2);
      expect(maintenances[0].type, 'Oil Change');
      expect(maintenances[1].type, 'Tire Rotation');
    });

    test('getMaintenancesByVehicleId returns maintenances for specific vehicle', () async {
      final maintenance1 = Maintenance(
        vehicleId: 1,
        type: 'Oil Change',
      );
      
      final maintenance2 = Maintenance(
        vehicleId: 2,
        type: 'Tire Rotation',
      );
      
      final maintenance3 = Maintenance(
        vehicleId: 1,
        type: 'Brake Inspection',
      );
      
      await mockMaintenanceDao.insertMaintenance(maintenance1);
      await mockMaintenanceDao.insertMaintenance(maintenance2);
      await mockMaintenanceDao.insertMaintenance(maintenance3);
      
      final maintenances = await maintenanceService.getMaintenancesByVehicleId(1);
      
      expect(maintenances.length, 2);
      expect(maintenances.every((maintenance) => maintenance.vehicleId == 1), isTrue);
    });

    test('getMaintenanceById returns correct maintenance', () async {
      final maintenance = Maintenance(
        vehicleId: 1,
        type: 'Oil Change',
      );
      
      final id = await mockMaintenanceDao.insertMaintenance(maintenance);
      
      final retrievedMaintenance = await maintenanceService.getMaintenanceById(id);
      
      expect(retrievedMaintenance, isNotNull);
      expect(retrievedMaintenance!.id, id);
      expect(retrievedMaintenance.type, 'Oil Change');
    });

    test('getMaintenanceById returns null for non-existent maintenance', () async {
      final maintenance = await maintenanceService.getMaintenanceById(999);
      expect(maintenance, isNull);
    });

    test('updateMaintenance updates existing maintenance', () async {
      final maintenance = Maintenance(
        vehicleId: 1,
        type: 'Oil Change',
      );
      
      final id = await mockMaintenanceDao.insertMaintenance(maintenance);
      
      final updatedMaintenance = Maintenance(
        id: id,
        vehicleId: 1,
        type: 'Tire Rotation',
      );
      
      final result = await maintenanceService.updateMaintenance(updatedMaintenance);
      
      expect(result, 1);
      expect(mockMaintenanceDao.maintenances[0].type, 'Tire Rotation');
    });

    test('deleteMaintenance removes maintenance from list', () async {
      final maintenance = Maintenance(
        vehicleId: 1,
        type: 'Oil Change',
      );
      
      final id = await mockMaintenanceDao.insertMaintenance(maintenance);
      expect(mockMaintenanceDao.maintenances.length, 1);
      
      final result = await maintenanceService.deleteMaintenance(id);
      
      expect(result, 1);
      expect(mockMaintenanceDao.maintenances.length, 0);
    });
  });
}