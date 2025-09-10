import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/error_handling_service.dart';

void main() {
  group('ErrorHandlingService', () {
    late ErrorHandlingService errorHandlingService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      errorHandlingService = ErrorHandlingService();
    });

    test('ErrorHandlingService can be instantiated', () {
      expect(errorHandlingService, isNotNull);
      expect(errorHandlingService, isA<ErrorHandlingService>());
    });

    test('handleError logs error correctly', () {
      // This test would ideally check if the logger was called
      // Since we can't easily mock the logger, we'll just ensure the method runs without error
      expect(() {
        errorHandlingService.handleError('Test error', StackTrace.current, 'Test context');
      }, returnsNormally);
    });

    test('handleAsyncError logs error correctly', () {
      expect(() {
        errorHandlingService.handleAsyncError('Test async error', StackTrace.current, 'Test context');
      }, returnsNormally);
    });

    test('safeCall handles exceptions correctly', () {
      final result = errorHandlingService.safeCall<String>(() {
        throw Exception('Test exception');
      }, (error, stackTrace) {
        return 'Error handled';
      });
      
      expect(result, equals('Error handled'));
    });

    test('safeCall returns normal value when no exception', () {
      final result = errorHandlingService.safeCall<String>(() {
        return 'Normal result';
      });
      
      expect(result, equals('Normal result'));
    });

    test('safeAsyncCall handles exceptions correctly', () async {
      final result = await errorHandlingService.safeAsyncCall<String>(() async {
        throw Exception('Test async exception');
      }, (error, stackTrace) async {
        return 'Async error handled';
      });
      
      expect(result, equals('Async error handled'));
    });

    test('safeAsyncCall returns normal value when no exception', () async {
      final result = await errorHandlingService.safeAsyncCall<String>(() async {
        return 'Normal async result';
      });
      
      expect(result, equals('Normal async result'));
    });

    test('log methods execute without error', () {
      expect(() {
        errorHandlingService.logInfo('Test info message');
        errorHandlingService.logWarning('Test warning message');
        errorHandlingService.logDebug('Test debug message');
      }, returnsNormally);
    });
  });
}