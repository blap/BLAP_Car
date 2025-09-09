import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/models/refueling.dart';

void main() {
  group('Refueling Model Tests', () {
    test('Refueling can be created with required fields', () {
      final date = DateTime.now();
      final refueling = Refueling(
        vehicleId: 1,
        date: date,
        odometer: 10000.0,
      );

      expect(refueling.vehicleId, 1);
      expect(refueling.date, date);
      expect(refueling.odometer, 10000.0);
    });

    test('Refueling can be created with all fields', () {
      final date = DateTime.now();
      final time = DateTime.now();
      final refueling = Refueling(
        id: 1,
        vehicleId: 1,
        date: date,
        time: time,
        odometer: 10000.0,
        liters: 50.0,
        pricePerLiter: 5.0,
        totalCost: 250.0,
        fuelType: 'Gasoline',
        station: 'Shell',
        fullTank: true,
        previousRefuelingMissing: false,
        driver: 'John Doe',
        paymentMethod: 'Credit Card',
        observation: 'Regular refueling',
        attachmentPath: '/path/to/attachment.jpg',
      );

      expect(refueling.id, 1);
      expect(refueling.vehicleId, 1);
      expect(refueling.date, date);
      expect(refueling.time, time);
      expect(refueling.odometer, 10000.0);
      expect(refueling.liters, 50.0);
      expect(refueling.pricePerLiter, 5.0);
      expect(refueling.totalCost, 250.0);
      expect(refueling.fuelType, 'Gasoline');
      expect(refueling.station, 'Shell');
      expect(refueling.fullTank, true);
      expect(refueling.previousRefuelingMissing, false);
      expect(refueling.driver, 'John Doe');
      expect(refueling.paymentMethod, 'Credit Card');
      expect(refueling.observation, 'Regular refueling');
      expect(refueling.attachmentPath, '/path/to/attachment.jpg');
    });

    test('Refueling can be converted to and from map', () {
      final date = DateTime.now();
      final time = DateTime.now();
      final refueling = Refueling(
        id: 1,
        vehicleId: 1,
        date: date,
        time: time,
        odometer: 10000.0,
        liters: 50.0,
        pricePerLiter: 5.0,
        totalCost: 250.0,
        fuelType: 'Gasoline',
        station: 'Shell',
        fullTank: true,
        previousRefuelingMissing: false,
        driver: 'John Doe',
        paymentMethod: 'Credit Card',
        observation: 'Regular refueling',
        attachmentPath: '/path/to/attachment.jpg',
      );

      final map = refueling.toMap();
      final refuelingFromMap = Refueling.fromMap(map);

      expect(refuelingFromMap.id, refueling.id);
      expect(refuelingFromMap.vehicleId, refueling.vehicleId);
      expect(refuelingFromMap.date, refueling.date);
      expect(refuelingFromMap.time, refueling.time);
      expect(refuelingFromMap.odometer, refueling.odometer);
      expect(refuelingFromMap.liters, refueling.liters);
      expect(refuelingFromMap.pricePerLiter, refueling.pricePerLiter);
      expect(refuelingFromMap.totalCost, refueling.totalCost);
      expect(refuelingFromMap.fuelType, refueling.fuelType);
      expect(refuelingFromMap.station, refueling.station);
      expect(refuelingFromMap.fullTank, refueling.fullTank);
      expect(refuelingFromMap.previousRefuelingMissing, refueling.previousRefuelingMissing);
      expect(refuelingFromMap.driver, refueling.driver);
      expect(refuelingFromMap.paymentMethod, refueling.paymentMethod);
      expect(refuelingFromMap.observation, refueling.observation);
      expect(refuelingFromMap.attachmentPath, refueling.attachmentPath);
    });
  });
}