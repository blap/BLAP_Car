import 'package:blap_car/models/sync_record.dart';
import 'package:blap_car/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class SyncRecordDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get database async => await _databaseHelper.database;

  // Insert a sync record
  Future<int> insertSyncRecord(SyncRecord syncRecord) async {
    final db = await database;
    return await db.insert('sync_record', syncRecord.toMap());
  }

  // Get all unsynced records
  Future<List<SyncRecord>> getUnsyncedRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_record',
      where: 'synced = ?',
      whereArgs: [0],
    );
    
    return List.generate(maps.length, (i) {
      return SyncRecord.fromMap(maps[i]);
    });
  }

  // Mark records as synced
  Future<int> markRecordsAsSynced(List<int> ids) async {
    final db = await database;
    return await db.update(
      'sync_record',
      {'synced': 1},
      where: 'id IN (${ids.join(',')})',
    );
  }

  // Get all sync records
  Future<List<SyncRecord>> getAllSyncRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sync_record');
    
    return List.generate(maps.length, (i) {
      return SyncRecord.fromMap(maps[i]);
    });
  }

  // Get a sync record by id
  Future<SyncRecord?> getSyncRecordById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sync_record',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return SyncRecord.fromMap(maps.first);
    }
    return null;
  }

  // Update a sync record
  Future<int> updateSyncRecord(SyncRecord syncRecord) async {
    final db = await database;
    return await db.update(
      'sync_record',
      syncRecord.toMap(),
      where: 'id = ?',
      whereArgs: [syncRecord.id],
    );
  }

  // Delete a sync record
  Future<int> deleteSyncRecord(int id) async {
    final db = await database;
    return await db.delete(
      'sync_record',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}