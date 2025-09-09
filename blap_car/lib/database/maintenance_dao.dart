import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class MaintenanceDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get database async => await _databaseHelper.database;

  // Insert a maintenance record
  Future<int> insertMaintenance(Maintenance maintenance) async {
    final db = await database;
    return await db.insert('maintenance', maintenance.toMap());
  }

  // Get all maintenance records
  Future<List<Maintenance>> getAllMaintenances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('maintenance');
    
    return List.generate(maps.length, (i) {
      return Maintenance.fromMap(maps[i]);
    });
  }

  // Get maintenance records by vehicle id
  Future<List<Maintenance>> getMaintenancesByVehicleId(int vehicleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    
    return List.generate(maps.length, (i) {
      return Maintenance.fromMap(maps[i]);
    });
  }

  // Get a maintenance record by id
  Future<Maintenance?> getMaintenanceById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'maintenance',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Maintenance.fromMap(maps.first);
    }
    return null;
  }

  // Update a maintenance record
  Future<int> updateMaintenance(Maintenance maintenance) async {
    final db = await database;
    return await db.update(
      'maintenance',
      maintenance.toMap(),
      where: 'id = ?',
      whereArgs: [maintenance.id],
    );
  }

  // Delete a maintenance record
  Future<int> deleteMaintenance(int id) async {
    final db = await database;
    return await db.delete(
      'maintenance',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}