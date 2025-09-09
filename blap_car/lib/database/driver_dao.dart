import 'package:blap_car/models/driver.dart';
import 'package:blap_car/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DriverDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get database async => await _databaseHelper.database;

  // Insert a driver
  Future<int> insertDriver(Driver driver) async {
    final db = await database;
    return await db.insert('driver', driver.toMap());
  }

  // Get all drivers
  Future<List<Driver>> getAllDrivers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('driver');
    
    return List.generate(maps.length, (i) {
      return Driver.fromMap(maps[i]);
    });
  }

  // Get a driver by id
  Future<Driver?> getDriverById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'driver',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Driver.fromMap(maps.first);
    }
    return null;
  }

  // Update a driver
  Future<int> updateDriver(Driver driver) async {
    final db = await database;
    return await db.update(
      'driver',
      driver.toMap(),
      where: 'id = ?',
      whereArgs: [driver.id],
    );
  }

  // Delete a driver
  Future<int> deleteDriver(int id) async {
    final db = await database;
    return await db.delete(
      'driver',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get drivers by vehicle id
  Future<List<Driver>> getDriversByVehicleId(int vehicleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT d.* FROM driver d
      INNER JOIN vehicle_driver vd ON d.id = vd.driver_id
      WHERE vd.vehicle_id = ?
    ''', [vehicleId]);
    
    return List.generate(maps.length, (i) {
      return Driver.fromMap(maps[i]);
    });
  }

  // Assign driver to vehicle
  Future<int> assignDriverToVehicle(int driverId, int vehicleId) async {
    final db = await database;
    return await db.insert('vehicle_driver', {
      'driver_id': driverId,
      'vehicle_id': vehicleId,
    });
  }

  // Remove driver from vehicle
  Future<int> removeDriverFromVehicle(int driverId, int vehicleId) async {
    final db = await database;
    return await db.delete(
      'vehicle_driver',
      where: 'driver_id = ? AND vehicle_id = ?',
      whereArgs: [driverId, vehicleId],
    );
  }
}