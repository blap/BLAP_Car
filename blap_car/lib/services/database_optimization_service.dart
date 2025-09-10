import 'package:blap_car/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:blap_car/services/error_handling_service.dart';

class DatabaseOptimizationService {
  static final DatabaseOptimizationService _instance = DatabaseOptimizationService._internal();
  factory DatabaseOptimizationService() => _instance;
  DatabaseOptimizationService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ErrorHandlingService _errorHandlingService = ErrorHandlingService();

  Future<Database> get database async => await _databaseHelper.database;

  // Batch operations for better performance when doing multiple operations
  Future<void> executeBatch(List<BatchOperation> operations) async {
    return _errorHandlingService.safeAsyncCall(() async {
      final db = await database;
      await db.transaction((txn) async {
        final batch = txn.batch();
        
        for (final operation in operations) {
          switch (operation.type) {
            case BatchOperationType.insert:
              batch.insert(operation.table, operation.values);
              break;
            case BatchOperationType.update:
              batch.update(
                operation.table,
                operation.values,
                where: operation.where,
                whereArgs: operation.whereArgs,
              );
              break;
            case BatchOperationType.delete:
              batch.delete(
                operation.table,
                where: operation.where,
                whereArgs: operation.whereArgs,
              );
              break;
          }
        }
        
        await batch.commit();
      });
    });
  }

  // Optimized query with pagination
  Future<List<Map<String, dynamic>>> queryWithPagination(
    String table, {
    int offset = 0,
    int limit = 50,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    return _errorHandlingService.safeAsyncCall(() async {
      final db = await database;
      return await db.query(
        table,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    }, (error, stackTrace) async {
      _errorHandlingService.handleError(error, stackTrace, 'DatabaseOptimizationService.queryWithPagination');
      return <Map<String, dynamic>>[];
    });
  }

  // Optimized query with joins for related data
  Future<List<Map<String, dynamic>>> queryWithJoin(
    String table1,
    String table2,
    String joinCondition, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    return _errorHandlingService.safeAsyncCall(() async {
      final db = await database;
      
      final columnList = columns?.join(', ') ?? '*';
      final whereClause = where != null ? 'WHERE $where' : '';
      final orderClause = orderBy != null ? 'ORDER BY $orderBy' : '';
      final limitClause = limit != null ? 'LIMIT $limit' : '';
      
      final query = '''
        SELECT $columnList
        FROM $table1
        JOIN $table2 ON $joinCondition
        $whereClause
        $orderClause
        $limitClause
      ''';
      
      return await db.rawQuery(query, whereArgs ?? []);
    }, (error, stackTrace) async {
      _errorHandlingService.handleError(error, stackTrace, 'DatabaseOptimizationService.queryWithJoin');
      return <Map<String, dynamic>>[];
    });
  }

  // Create indexes for better query performance
  Future<void> createIndex(String table, String column, {String? indexName, bool unique = false}) async {
    return _errorHandlingService.safeAsyncCall(() async {
      final db = await database;
      final name = indexName ?? '${table}_${column}_idx';
      final uniqueClause = unique ? 'UNIQUE' : '';
      
      await db.execute('CREATE $uniqueClause INDEX IF NOT EXISTS $name ON $table ($column)');
    });
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    return _errorHandlingService.safeAsyncCall(() async {
      final db = await database;
      
      // Get table information
      final tables = await db.rawQuery('''
        SELECT name, sql 
        FROM sqlite_master 
        WHERE type='table' AND name NOT LIKE 'sqlite_%'
      ''');
      
      // Get row counts for each table
      final Map<String, int> tableCounts = {};
      for (final table in tables) {
        final tableName = table['name'] as String;
        final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
        tableCounts[tableName] = countResult.first['count'] as int;
      }
      
      return {
        'tableCount': tables.length,
        'tables': tables.map((t) => t['name'] as String).toList(),
        'tableCounts': tableCounts,
      };
    }, (error, stackTrace) async {
      _errorHandlingService.handleError(error, stackTrace, 'DatabaseOptimizationService.getDatabaseStats');
      return <String, dynamic>{};
    });
  }

  // Vacuum database to optimize storage
  Future<void> vacuumDatabase() async {
    return _errorHandlingService.safeAsyncCall(() async {
      final db = await database;
      await db.execute('VACUUM');
    });
  }

  // Analyze database for optimization suggestions
  Future<List<String>> analyzeDatabase() async {
    return _errorHandlingService.safeAsyncCall(() async {
      final suggestions = <String>[];
      
      // Check if common indexes exist
      final commonIndexes = {
        'vehicle': ['name', 'make', 'model'],
        'refueling': ['vehicle_id', 'date'],
        'expense': ['vehicle_id', 'date'],
        'maintenance': ['vehicle_id', 'date'],
      };
      
      // In a real implementation, we would check if these indexes exist
      // For now, we'll just suggest creating them
      for (final table in commonIndexes.keys) {
        for (final column in commonIndexes[table]!) {
          suggestions.add('Consider creating an index on $table.$column for better query performance');
        }
      }
      
      return suggestions;
    }, (error, stackTrace) async {
      _errorHandlingService.handleError(error, stackTrace, 'DatabaseOptimizationService.analyzeDatabase');
      return <String>[];
    });
  }
}

// Helper classes for batch operations
enum BatchOperationType { insert, update, delete }

class BatchOperation {
  final BatchOperationType type;
  final String table;
  final Map<String, Object?> values;
  final String? where;
  final List<Object?>? whereArgs;

  BatchOperation.insert(this.table, this.values) 
    : type = BatchOperationType.insert,
      where = null,
      whereArgs = null;

  BatchOperation.update(this.table, this.values, this.where, this.whereArgs) 
    : type = BatchOperationType.update;

  BatchOperation.delete(this.table, this.where, this.whereArgs) 
    : type = BatchOperationType.delete,
      values = const {};
}