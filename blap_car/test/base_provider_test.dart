import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/modules/base/base_provider.dart';

void main() {
  group('BaseProvider', () {
    late BaseProvider baseProvider;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      baseProvider = BaseProvider();
    });

    test('BaseProvider can be instantiated', () {
      expect(baseProvider, isNotNull);
      expect(baseProvider, isA<BaseProvider>());
    });

    test('Initial state is InitialState', () {
      expect(baseProvider.state, isA<InitialState>());
      expect(baseProvider.isLoading, isFalse);
      expect(baseProvider.hasError, isFalse);
      expect(baseProvider.isSuccess, isFalse);
    });

    test('setState updates the state correctly', () {
      baseProvider.setState(LoadingState());
      expect(baseProvider.state, isA<LoadingState>());
      expect(baseProvider.isLoading, isTrue);
      expect(baseProvider.hasError, isFalse);
      expect(baseProvider.isSuccess, isFalse);
    });

    test('setLoading updates to LoadingState', () {
      baseProvider.setLoading('Loading data...');
      expect(baseProvider.state, isA<LoadingState>());
      expect(baseProvider.isLoading, isTrue);
      expect((baseProvider.state as LoadingState).message, equals('Loading data...'));
    });

    test('setSuccess updates to SuccessState', () {
      final testData = {'name': 'Test', 'value': 42};
      baseProvider.setSuccess(testData);
      expect(baseProvider.state, isA<SuccessState>());
      expect(baseProvider.isSuccess, isTrue);
      expect((baseProvider.state as SuccessState).data, equals(testData));
    });

    test('setError updates to ErrorState', () {
      baseProvider.setError('Test error');
      expect(baseProvider.state, isA<ErrorState>());
      expect(baseProvider.hasError, isTrue);
      expect((baseProvider.state as ErrorState).message, equals('Test error'));
    });

    test('executeAsync handles successful operations', () async {
      final result = await baseProvider.executeAsync(() async {
        await Future.delayed(Duration(milliseconds: 10));
        return 'Success';
      });

      expect(result, equals('Success'));
      expect(baseProvider.state, isA<SuccessState>());
      expect((baseProvider.state as SuccessState).data, equals('Success'));
    });

    test('executeAsync handles errors', () async {
      final result = await baseProvider.executeAsync(() async {
        await Future.delayed(Duration(milliseconds: 10));
        throw Exception('Test error');
      });

      expect(result, isNull);
      expect(baseProvider.state, isA<ErrorState>());
      expect((baseProvider.state as ErrorState).message, contains('Test error'));
    });

    test('executeSync handles successful operations', () {
      final result = baseProvider.executeSync(() {
        return 'Success';
      });

      expect(result, equals('Success'));
      expect(baseProvider.state, isA<SuccessState>());
      expect((baseProvider.state as SuccessState).data, equals('Success'));
    });

    test('executeSync handles errors', () {
      final result = baseProvider.executeSync(() {
        throw Exception('Test error');
      });

      expect(result, isNull);
      expect(baseProvider.state, isA<ErrorState>());
      expect((baseProvider.state as ErrorState).message, contains('Test error'));
    });
  });

  group('State Classes', () {
    test('InitialState can be instantiated', () {
      final state = InitialState();
      expect(state, isA<InitialState>());
    });

    test('LoadingState can be instantiated', () {
      final state = LoadingState(message: 'Loading...');
      expect(state, isA<LoadingState>());
      expect(state.message, equals('Loading...'));
    });

    test('SuccessState can be instantiated', () {
      final data = {'test': 'data'};
      final state = SuccessState(data);
      expect(state, isA<SuccessState>());
      expect(state.data, equals(data));
    });

    test('ErrorState can be instantiated', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final state = ErrorState('Error message', error: error, stackTrace: stackTrace);
      expect(state, isA<ErrorState>());
      expect(state.message, equals('Error message'));
      expect(state.error, equals(error));
      expect(state.stackTrace, equals(stackTrace));
    });
  });
}