import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/models/driver.dart';

void main() {
  group('Driver Model Tests', () {
    test('Driver can be created with required fields', () {
      final createdAt = DateTime.now();
      final driver = Driver(
        name: 'John Doe',
        createdAt: createdAt,
      );

      expect(driver.name, 'John Doe');
      expect(driver.createdAt, createdAt);
    });

    test('Driver can be created with all fields', () {
      final createdAt = DateTime.now();
      final licenseExpiryDate = DateTime.now().add(Duration(days: 365));
      final driver = Driver(
        id: 1,
        name: 'John Doe',
        licenseNumber: 'D123456789',
        licenseExpiryDate: licenseExpiryDate,
        contactInfo: 'john.doe@example.com',
        createdAt: createdAt,
      );

      expect(driver.id, 1);
      expect(driver.name, 'John Doe');
      expect(driver.licenseNumber, 'D123456789');
      expect(driver.licenseExpiryDate, licenseExpiryDate);
      expect(driver.contactInfo, 'john.doe@example.com');
      expect(driver.createdAt, createdAt);
    });

    test('Driver can be converted to and from map', () {
      final createdAt = DateTime.now();
      final licenseExpiryDate = DateTime.now().add(Duration(days: 365));
      final driver = Driver(
        id: 1,
        name: 'John Doe',
        licenseNumber: 'D123456789',
        licenseExpiryDate: licenseExpiryDate,
        contactInfo: 'john.doe@example.com',
        createdAt: createdAt,
      );

      final map = driver.toMap();
      final driverFromMap = Driver.fromMap(map);

      expect(driverFromMap.id, driver.id);
      expect(driverFromMap.name, driver.name);
      expect(driverFromMap.licenseNumber, driver.licenseNumber);
      expect(driverFromMap.licenseExpiryDate, driver.licenseExpiryDate);
      expect(driverFromMap.contactInfo, driver.contactInfo);
      expect(driverFromMap.createdAt, driver.createdAt);
    });
  });
}