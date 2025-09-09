import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/models/vehicle.dart';

void main() {
  group('Vehicle Model Tests', () {
    test('Vehicle can be created with required fields', () {
      final vehicle = Vehicle(
        name: 'Test Car',
        createdAt: DateTime.now(),
      );

      expect(vehicle.name, 'Test Car');
      expect(vehicle.createdAt, isNotNull);
    });

    test('Vehicle can be created with all fields', () {
      final createdAt = DateTime.now();
      final vehicle = Vehicle(
        id: 1,
        name: 'Test Car',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        plate: 'ABC123',
        fuelTankVolume: 60.0,
        vin: '1234567890',
        renavam: 'REN123456',
        initialOdometer: 10000.0,
        createdAt: createdAt,
      );

      expect(vehicle.id, 1);
      expect(vehicle.name, 'Test Car');
      expect(vehicle.make, 'Toyota');
      expect(vehicle.model, 'Camry');
      expect(vehicle.year, 2020);
      expect(vehicle.plate, 'ABC123');
      expect(vehicle.fuelTankVolume, 60.0);
      expect(vehicle.vin, '1234567890');
      expect(vehicle.renavam, 'REN123456');
      expect(vehicle.initialOdometer, 10000.0);
      expect(vehicle.createdAt, createdAt);
    });

    test('Vehicle can be converted to and from map', () {
      final createdAt = DateTime.now();
      final vehicle = Vehicle(
        id: 1,
        name: 'Test Car',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        plate: 'ABC123',
        fuelTankVolume: 60.0,
        vin: '1234567890',
        renavam: 'REN123456',
        initialOdometer: 10000.0,
        createdAt: createdAt,
      );

      final map = vehicle.toMap();
      final vehicleFromMap = Vehicle.fromMap(map);

      expect(vehicleFromMap.id, vehicle.id);
      expect(vehicleFromMap.name, vehicle.name);
      expect(vehicleFromMap.make, vehicle.make);
      expect(vehicleFromMap.model, vehicle.model);
      expect(vehicleFromMap.year, vehicle.year);
      expect(vehicleFromMap.plate, vehicle.plate);
      expect(vehicleFromMap.fuelTankVolume, vehicle.fuelTankVolume);
      expect(vehicleFromMap.vin, vehicle.vin);
      expect(vehicleFromMap.renavam, vehicle.renavam);
      expect(vehicleFromMap.initialOdometer, vehicle.initialOdometer);
      expect(vehicleFromMap.createdAt, vehicle.createdAt);
    });
  });
}