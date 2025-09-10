import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';
import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/modules/base/base_provider.dart';

void main() {
  group('Vehicle Integration Tests', () {
    late VehicleProvider vehicleProvider;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      vehicleProvider = VehicleProvider();
    });

    test('VehicleProvider state management works correctly', () async {
      // Test initial state
      expect(vehicleProvider.state, isA<InitialState>());
      expect(vehicleProvider.vehicles, isEmpty);
      expect(vehicleProvider.activeVehicle, isNull);

      // Test loading state
      vehicleProvider.setLoading('Loading vehicles');
      expect(vehicleProvider.state, isA<LoadingState>());
      expect(vehicleProvider.isLoading, isTrue);
      expect((vehicleProvider.state as LoadingState).message, equals('Loading vehicles'));

      // Test success state with vehicle data
      final testVehicle = Vehicle(
        name: 'Test Vehicle',
        make: 'Test Make',
        model: 'Test Model',
        year: 2023,
        createdAt: DateTime.now(),
      );
      
      vehicleProvider.setSuccess([testVehicle]);
      expect(vehicleProvider.state, isA<SuccessState>());
      expect(vehicleProvider.isSuccess, isTrue);
      expect((vehicleProvider.state as SuccessState).data, isA<List>());
      
      final vehicles = (vehicleProvider.state as SuccessState).data as List;
      expect(vehicles, isNotEmpty);
      expect(vehicles.first, isA<Vehicle>());
    });

    test('VehicleState encapsulates vehicle data correctly', () {
      final testVehicle = Vehicle(
        name: 'Test Vehicle',
        make: 'Test Make',
        model: 'Test Model',
        year: 2023,
        createdAt: DateTime.now(),
      );
      
      final vehicleState = VehicleState(
        vehicles: [testVehicle],
        activeVehicle: testVehicle,
      );
      
      expect(vehicleState.vehicles, equals([testVehicle]));
      expect(vehicleState.activeVehicle, equals(testVehicle));
    });
  });
}