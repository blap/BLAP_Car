import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/unit_test_service.dart';

void main() {
  group('UnitTestService', () {
    late UnitTestService unitTestService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      unitTestService = UnitTestService();
    });

    test('UnitTestService can be instantiated', () {
      expect(unitTestService, isNotNull);
      expect(unitTestService, isA<UnitTestService>());
    });

    test('generateModelUnitTest creates valid test code', () async {
      final fields = [
        'int? id',
        'required int vehicleId',
        'String? type',
        'DateTime? date',
        'double? cost',
      ];
      
      final result = await unitTestService.generateModelUnitTest('TestModel', fields);
      
      expect(result, isA<String>());
      expect(result, contains('import \'package:flutter_test/flutter_test.dart\';'));
      expect(result, contains('TestModel Model Tests'));
      expect(result, contains('TestModel can be created with required fields'));
      expect(result, contains('TestModel can be created with all fields'));
      expect(result, contains('TestModel can be converted to and from map'));
      expect(result, contains('vehicleId: 1'));
      expect(result, contains('expect(TestModel.vehicleId, isNotNull);'));
    });

    test('generateServiceUnitTest creates valid test code', () async {
      final methods = [
        'getData',
        'saveData',
        'deleteData',
      ];
      
      final result = await unitTestService.generateServiceUnitTest('TestService', methods);
      
      expect(result, isA<String>());
      expect(result, contains('import \'package:flutter_test/flutter_test.dart\';'));
      expect(result, contains('TestService Tests'));
      expect(result, contains('TestService can be instantiated'));
      expect(result, contains('getData method works correctly'));
      expect(result, contains('saveData method works correctly'));
      expect(result, contains('deleteData method works correctly'));
    });

    test('getExistingTestFiles returns list of files', () async {
      final result = await unitTestService.getExistingTestFiles();
      
      expect(result, isA<List<String>>());
      // We can't assert specific content since it depends on the file system
    });
  });
}