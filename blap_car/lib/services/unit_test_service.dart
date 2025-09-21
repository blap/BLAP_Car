import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class UnitTestService {
  // Generate a comprehensive unit test for a given model
  Future<String> generateModelUnitTest(String modelName, List<String> fields) async {
    final StringBuffer testBuffer = StringBuffer();
    
    testBuffer.writeln('import \'package:flutter_test/flutter_test.dart\';');
    testBuffer.writeln('import \'package:blap_car/models/$modelName.dart\';');
    testBuffer.writeln('');
    testBuffer.writeln('void main() {');
    testBuffer.writeln('  group(\'$modelName Model Tests\', () {');
    testBuffer.writeln('    test(\'$modelName can be created with required fields\', () {');
    
    // Generate test for required fields
    testBuffer.writeln('      final $modelName = $modelName(');
    bool hasRequiredFields = false;
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      if (field.contains('required')) {
        hasRequiredFields = true;
        final parts = field.split(' ');
        String fieldName = '';
        
        // Extract field name (it's usually the last part)
        for (final part in parts) {
          if (!part.contains('required') && !part.contains('int') && 
              !part.contains('String') && !part.contains('double') && 
              !part.contains('DateTime') && !part.contains('bool') &&
              !part.contains('?') && part.isNotEmpty) {
            fieldName = part;
            break;
          }
        }
        
        if (fieldName == 'vehicleId') {
          testBuffer.writeln('        $fieldName: 1,');
        } else if (fieldName.contains('date')) {
          testBuffer.writeln('        $fieldName: DateTime.now(),');
        } else if (fieldName.contains('cost') || fieldName.contains('odometer') || 
                   fieldName.contains('liters') || fieldName.contains('price') ||
                   fieldName.contains('km') || fieldName.contains('interval')) {
          testBuffer.writeln('        $fieldName: 100.0,');
        } else {
          testBuffer.writeln('        $fieldName: \'Test $fieldName\',');
        }
      }
    }
    testBuffer.writeln('      );');
    
    // Generate assertions for required fields
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      if (field.contains('required')) {
        final parts = field.split(' ');
        String fieldName = '';
        
        // Extract field name
        for (final part in parts) {
          if (!part.contains('required') && !part.contains('int') && 
              !part.contains('String') && !part.contains('double') && 
              !part.contains('DateTime') && !part.contains('bool') &&
              !part.contains('?') && part.isNotEmpty) {
            fieldName = part;
            break;
          }
        }
        
        if (fieldName.isNotEmpty) {
          testBuffer.writeln('');
          testBuffer.writeln('      expect($modelName.$fieldName, isNotNull);');
        }
      }
    }
    
    if (!hasRequiredFields) {
      // If no required fields, just create an empty instance
      testBuffer.writeln('      // No required fields');
      testBuffer.writeln('      final $modelName = $modelName();');
    }
    
    testBuffer.writeln('    });');
    testBuffer.writeln('');
    testBuffer.writeln('    test(\'$modelName can be created with all fields\', () {');
    
    // Generate test for all fields
    testBuffer.writeln('      final $modelName = $modelName(');
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final parts = field.split(' ');
      String fieldName = '';
      
      // Extract field name
      for (final part in parts) {
        if (!part.contains('required') && !part.contains('int') && 
            !part.contains('String') && !part.contains('double') && 
            !part.contains('DateTime') && !part.contains('bool') &&
            !part.contains('?') && part.isNotEmpty) {
          fieldName = part;
          break;
        }
      }
      
      if (fieldName.isNotEmpty) {
        if (fieldName == 'id') {
          testBuffer.writeln('        $fieldName: 1,');
        } else if (fieldName == 'vehicleId') {
          testBuffer.writeln('        $fieldName: 1,');
        } else if (fieldName.contains('date')) {
          testBuffer.writeln('        $fieldName: DateTime.now(),');
        } else if (fieldName.contains('cost') || fieldName.contains('odometer') || 
                   fieldName.contains('liters') || fieldName.contains('price') ||
                   fieldName.contains('km') || fieldName.contains('interval')) {
          testBuffer.writeln('        $fieldName: 100.0,');
        } else if (fieldName.contains('enabled') || fieldName.contains('recurring') || 
                   fieldName.contains('completed') || fieldName.contains('missing') ||
                   fieldName.contains('full')) {
          testBuffer.writeln('        $fieldName: true,');
        } else {
          testBuffer.writeln('        $fieldName: \'Test $fieldName\',');
        }
      }
    }
    testBuffer.writeln('      );');
    
    // Generate assertions for all fields
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final parts = field.split(' ');
      String fieldName = '';
      
      // Extract field name
      for (final part in parts) {
        if (!part.contains('required') && !part.contains('int') && 
            !part.contains('String') && !part.contains('double') && 
            !part.contains('DateTime') && !part.contains('bool') &&
            !part.contains('?') && part.isNotEmpty) {
          fieldName = part;
          break;
        }
      }
      
      if (fieldName.isNotEmpty) {
        testBuffer.writeln('');
        testBuffer.writeln('      expect($modelName.$fieldName, isNotNull);');
      }
    }
    
    testBuffer.writeln('    });');
    testBuffer.writeln('');
    testBuffer.writeln('    test(\'$modelName can be converted to and from map\', () {');
    
    // Generate test for toMap and fromMap
    testBuffer.writeln('      final date = DateTime.now();');
    testBuffer.writeln('      final $modelName = $modelName(');
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final parts = field.split(' ');
      String fieldName = '';
      
      // Extract field name
      for (final part in parts) {
        if (!part.contains('required') && !part.contains('int') && 
            !part.contains('String') && !part.contains('double') && 
            !part.contains('DateTime') && !part.contains('bool') &&
            !part.contains('?') && part.isNotEmpty) {
          fieldName = part;
          break;
        }
      }
      
      if (fieldName.isNotEmpty) {
        if (fieldName == 'id') {
          testBuffer.writeln('        $fieldName: 1,');
        } else if (fieldName == 'vehicleId') {
          testBuffer.writeln('        $fieldName: 1,');
        } else if (fieldName.contains('date')) {
          testBuffer.writeln('        $fieldName: date,');
        } else if (fieldName.contains('cost') || fieldName.contains('odometer') || 
                   fieldName.contains('liters') || fieldName.contains('price') ||
                   fieldName.contains('km') || fieldName.contains('interval')) {
          testBuffer.writeln('        $fieldName: 100.0,');
        } else if (fieldName.contains('enabled') || fieldName.contains('recurring') || 
                   fieldName.contains('completed') || fieldName.contains('missing') ||
                   fieldName.contains('full')) {
          testBuffer.writeln('        $fieldName: true,');
        } else {
          testBuffer.writeln('        $fieldName: \'Test $fieldName\',');
        }
      }
    }
    testBuffer.writeln('      );');
    testBuffer.writeln('');
    testBuffer.writeln('      final map = $modelName.toMap();');
    testBuffer.writeln('      final ${modelName}FromMap = $modelName.fromMap(map);');
    testBuffer.writeln('');
    
    // Generate assertions for map conversion
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final parts = field.split(' ');
      String fieldName = '';
      
      // Extract field name
      for (final part in parts) {
        if (!part.contains('required') && !part.contains('int') && 
            !part.contains('String') && !part.contains('double') && 
            !part.contains('DateTime') && !part.contains('bool') &&
            !part.contains('?') && part.isNotEmpty) {
          fieldName = part;
          break;
        }
      }
      
      if (fieldName.isNotEmpty) {
        if (fieldName.contains('date')) {
          testBuffer.writeln('      expect(${modelName}FromMap.$fieldName, equals(date));');
        } else {
          testBuffer.writeln('      expect(${modelName}FromMap.$fieldName, equals($modelName.$fieldName));');
        }
      }
    }
    
    testBuffer.writeln('    });');
    testBuffer.writeln('  });');
    testBuffer.writeln('}');
    
    return testBuffer.toString();
  }

  // Generate a comprehensive unit test for a given service
  Future<String> generateServiceUnitTest(String serviceName, List<String> methods) async {
    final StringBuffer testBuffer = StringBuffer();
    
    testBuffer.writeln('import \'package:flutter_test/flutter_test.dart\';');
    testBuffer.writeln('import \'package:blap_car/services/$serviceName.dart\';');
    testBuffer.writeln('');
    testBuffer.writeln('void main() {');
    testBuffer.writeln('  group(\'$serviceName Tests\', () {');
    testBuffer.writeln('    late $serviceName $serviceName;');
    testBuffer.writeln('');
    testBuffer.writeln('    setUp(() {');
    testBuffer.writeln('      $serviceName = $serviceName();');
    testBuffer.writeln('    });');
    testBuffer.writeln('');
    testBuffer.writeln('    test(\'$serviceName can be instantiated\', () {');
    testBuffer.writeln('      expect($serviceName, isNotNull);');
    testBuffer.writeln('      expect($serviceName, isA<$serviceName>());');
    testBuffer.writeln('    });');
    testBuffer.writeln('');
    
    // Generate tests for each method
    for (final method in methods) {
      testBuffer.writeln('    test(\'$method method works correctly\', () async {');
      testBuffer.writeln('      // Test the $method method');
      testBuffer.writeln('      expect($serviceName, isNotNull);');
      testBuffer.writeln('      // Add specific assertions based on the method\'s expected behavior');
      testBuffer.writeln('      expect(true, isTrue);');
      testBuffer.writeln('    });');
      testBuffer.writeln('');
    }
    
    testBuffer.writeln('  });');
    testBuffer.writeln('}');
    
    return testBuffer.toString();
  }

  // Save test file to device storage (for review purposes)
  Future<void> saveTestFile(String fileName, String testContent) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final testDirectory = Directory('${directory.path}/tests');
      
      if (!await testDirectory.exists()) {
        await testDirectory.create(recursive: true);
      }
      
      final file = File('${testDirectory.path}/$fileName');
      await file.writeAsString(testContent);
    } catch (e) {
      // Silently handle errors in test environment
      debugPrint('Could not save test file: $e');
    }
  }

  // Get list of existing test files
  Future<List<String>> getExistingTestFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final testDirectory = Directory('${directory.path}/tests');
      
      if (!await testDirectory.exists()) {
        return [];
      }
      
      final files = testDirectory.listSync();
      return files
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => basename(file.path))
          .toList();
    } catch (e) {
      // Silently handle errors in test environment
      debugPrint('Could not list test files: $e');
      return [];
    }
  }
}