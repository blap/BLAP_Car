import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class RefuelingDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get database async => await _databaseHelper.database;

  // Insert a refueling record
  Future<int> insertRefueling(Refueling refueling) async {
    final db = await database;
    return await db.insert('refueling', refueling.toMap());
  }

  // Get all refueling records
  Future<List<Refueling>> getAllRefuelings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('refueling');
    
    return List.generate(maps.length, (i) {
      return Refueling.fromMap(maps[i]);
    });
  }

  // Get refueling records by vehicle id
  Future<List<Refueling>> getRefuelingsByVehicleId(int vehicleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'refueling',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    
    return List.generate(maps.length, (i) {
      return Refueling.fromMap(maps[i]);
    });
  }

  // Get a refueling record by id
  Future<Refueling?> getRefuelingById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'refueling',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Refueling.fromMap(maps.first);
    }
    return null;
  }

  // Update a refueling record
  Future<int> updateRefueling(Refueling refueling) async {
    final db = await database;
    return await db.update(
      'refueling',
      refueling.toMap(),
      where: 'id = ?',
      whereArgs: [refueling.id],
    );
  }

  // Delete a refueling record
  Future<int> deleteRefueling(int id) async {
    final db = await database;
    return await db.delete(
      'refueling',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}