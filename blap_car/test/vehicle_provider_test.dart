import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';
import 'package:blap_car/models/vehicle.dart';

void main() {
  group('VehicleProvider', () {
    late VehicleProvider vehicleProvider;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      vehicleProvider = VehicleProvider();
    });

    test('VehicleProvider can be instantiated', () {
      expect(vehicleProvider, isNotNull);
      expect(vehicleProvider, isA<VehicleProvider>());
    });

    test('Initial state is correct', () {
      expect(vehicleProvider.vehicles, isEmpty);
      expect(vehicleProvider.activeVehicle, isNull);
      expect(vehicleProvider.vehicleState.vehicles, isEmpty);
      expect(vehicleProvider.vehicleState.activeVehicle, isNull);
    });

    test('VehicleState can be created', () {
      final vehicles = [Vehicle(name: 'Test Vehicle', createdAt: DateTime.now())];
      final state = VehicleState(vehicles: vehicles, activeVehicle: vehicles.first);
      
      expect(state.vehicles, equals(vehicles));
      expect(state.activeVehicle, equals(vehicles.first));
    });

    test('Base provider functionality works', () {
      expect(vehicleProvider.isLoading, isFalse);
      expect(vehicleProvider.hasError, isFalse);
      expect(vehicleProvider.isSuccess, isFalse);
      
      vehicleProvider.setLoading('Loading...');
      expect(vehicleProvider.isLoading, isTrue);
      
      vehicleProvider.setSuccess('Test data');
      expect(vehicleProvider.isSuccess, isTrue);
      
      vehicleProvider.setError('Test error');
      expect(vehicleProvider.hasError, isTrue);
    });
  });
}