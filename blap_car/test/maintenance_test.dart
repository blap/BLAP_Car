import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/models/maintenance.dart';

void main() {
  group('Maintenance Model Tests', () {
    test('Maintenance can be created with required fields', () {
      final maintenance = Maintenance(
        vehicleId: 1,
      );

      expect(maintenance.vehicleId, 1);
    });

    test('Maintenance can be created with all fields', () {
      final date = DateTime.now();
      final nextDate = DateTime.now().add(Duration(days: 30));
      final maintenance = Maintenance(
        id: 1,
        vehicleId: 1,
        type: 'Oil Change',
        description: 'Regular oil change',
        cost: 150.0,
        date: date,
        nextDate: nextDate,
        odometer: 10000,
        status: 'Pending',
      );

      expect(maintenance.id, 1);
      expect(maintenance.vehicleId, 1);
      expect(maintenance.type, 'Oil Change');
      expect(maintenance.description, 'Regular oil change');
      expect(maintenance.cost, 150.0);
      expect(maintenance.date, date);
      expect(maintenance.nextDate, nextDate);
      expect(maintenance.odometer, 10000);
      expect(maintenance.status, 'Pending');
    });

    test('Maintenance can be converted to and from map', () {
      final date = DateTime.now();
      final nextDate = DateTime.now().add(Duration(days: 30));
      final maintenance = Maintenance(
        id: 1,
        vehicleId: 1,
        type: 'Oil Change',
        description: 'Regular oil change',
        cost: 150.0,
        date: date,
        nextDate: nextDate,
        odometer: 10000,
        status: 'Pending',
      );

      final map = maintenance.toMap();
      final maintenanceFromMap = Maintenance.fromMap(map);

      expect(maintenanceFromMap.id, maintenance.id);
      expect(maintenanceFromMap.vehicleId, maintenance.vehicleId);
      expect(maintenanceFromMap.type, maintenance.type);
      expect(maintenanceFromMap.description, maintenance.description);
      expect(maintenanceFromMap.cost, maintenance.cost);
      expect(maintenanceFromMap.date, maintenance.date);
      expect(maintenanceFromMap.nextDate, maintenance.nextDate);
      expect(maintenanceFromMap.odometer, maintenance.odometer);
      expect(maintenanceFromMap.status, maintenance.status);
    });
  });
}