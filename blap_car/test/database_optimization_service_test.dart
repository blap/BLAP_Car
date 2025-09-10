import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/database_optimization_service.dart';

void main() {
  group('DatabaseOptimizationService', () {
    late DatabaseOptimizationService databaseOptimizationService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      databaseOptimizationService = DatabaseOptimizationService();
    });

    test('DatabaseOptimizationService can be instantiated', () {
      expect(databaseOptimizationService, isNotNull);
      expect(databaseOptimizationService, isA<DatabaseOptimizationService>());
    });

    test('BatchOperation can be created for insert', () {
      final operation = BatchOperation.insert('test_table', {'name': 'Test', 'value': 1.0});
      expect(operation.type, equals(BatchOperationType.insert));
      expect(operation.table, equals('test_table'));
      expect(operation.values['name'], equals('Test'));
    });

    test('BatchOperation can be created for update', () {
      final operation = BatchOperation.update(
        'test_table', 
        {'name': 'Updated Test'}, 
        'id = ?', 
        [1]
      );
      expect(operation.type, equals(BatchOperationType.update));
      expect(operation.table, equals('test_table'));
      expect(operation.values['name'], equals('Updated Test'));
      expect(operation.where, equals('id = ?'));
      expect(operation.whereArgs, equals([1]));
    });

    test('BatchOperation can be created for delete', () {
      final operation = BatchOperation.delete('test_table', 'id = ?', [1]);
      expect(operation.type, equals(BatchOperationType.delete));
      expect(operation.table, equals('test_table'));
      expect(operation.where, equals('id = ?'));
      expect(operation.whereArgs, equals([1]));
    });
  });
}