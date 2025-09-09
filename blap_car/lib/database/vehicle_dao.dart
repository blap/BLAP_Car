import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class VehicleDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get database async => await _databaseHelper.database;

  // Insert a vehicle
  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.insert('vehicle', vehicle.toMap());
  }

  // Get all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vehicle');
    
    return List.generate(maps.length, (i) {
      return Vehicle.fromMap(maps[i]);
    });
  }

  // Get a vehicle by id
  Future<Vehicle?> getVehicleById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vehicle',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    }
    return null;
  }

  // Update a vehicle
  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      'vehicle',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  // Delete a vehicle
  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete(
      'vehicle',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}