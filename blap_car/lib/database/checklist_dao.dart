import 'package:blap_car/models/checklist.dart';
import 'package:blap_car/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ChecklistDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<Database> get database async => await _databaseHelper.database;

  // Checklist methods
  Future<int> insertChecklist(Checklist checklist) async {
    final db = await database;
    return await db.insert('checklist', checklist.toMap());
  }

  Future<List<Checklist>> getAllChecklists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('checklist');
    
    return List.generate(maps.length, (i) {
      return Checklist.fromMap(maps[i]);
    });
  }

  Future<Checklist?> getChecklistById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checklist',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Checklist.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateChecklist(Checklist checklist) async {
    final db = await database;
    return await db.update(
      'checklist',
      checklist.toMap(),
      where: 'id = ?',
      whereArgs: [checklist.id],
    );
  }

  Future<int> deleteChecklist(int id) async {
    final db = await database;
    return await db.delete(
      'checklist',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ChecklistItem methods
  Future<int> insertChecklistItem(ChecklistItem item) async {
    final db = await database;
    return await db.insert('checklist_item', item.toMap());
  }

  Future<List<ChecklistItem>> getChecklistItemsByChecklistId(int checklistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checklist_item',
      where: 'checklist_id = ?',
      whereArgs: [checklistId],
    );
    
    return List.generate(maps.length, (i) {
      return ChecklistItem.fromMap(maps[i]);
    });
  }

  Future<ChecklistItem?> getChecklistItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checklist_item',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return ChecklistItem.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateChecklistItem(ChecklistItem item) async {
    final db = await database;
    return await db.update(
      'checklist_item',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteChecklistItem(int id) async {
    final db = await database;
    return await db.delete(
      'checklist_item',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ChecklistCompletion methods
  Future<int> insertChecklistCompletion(ChecklistCompletion completion) async {
    final db = await database;
    return await db.insert('checklist_completion', completion.toMap());
  }

  Future<List<ChecklistCompletion>> getChecklistCompletionsByVehicleId(int vehicleId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checklist_completion',
      where: 'vehicle_id = ?',
      whereArgs: [vehicleId],
    );
    
    return List.generate(maps.length, (i) {
      return ChecklistCompletion.fromMap(maps[i]);
    });
  }

  Future<ChecklistCompletion?> getChecklistCompletionById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checklist_completion',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return ChecklistCompletion.fromMap(maps.first);
    }
    return null;
  }

  // ChecklistItemCompletion methods
  Future<int> insertChecklistItemCompletion(ChecklistItemCompletion itemCompletion) async {
    final db = await database;
    return await db.insert('checklist_item_completion', itemCompletion.toMap());
  }

  Future<List<ChecklistItemCompletion>> getChecklistItemCompletionsByCompletionId(int completionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checklist_item_completion',
      where: 'checklist_completion_id = ?',
      whereArgs: [completionId],
    );
    
    return List.generate(maps.length, (i) {
      return ChecklistItemCompletion.fromMap(maps[i]);
    });
  }

  Future<int> updateChecklistItemCompletion(ChecklistItemCompletion itemCompletion) async {
    final db = await database;
    return await db.update(
      'checklist_item_completion',
      itemCompletion.toMap(),
      where: 'id = ?',
      whereArgs: [itemCompletion.id],
    );
  }
}