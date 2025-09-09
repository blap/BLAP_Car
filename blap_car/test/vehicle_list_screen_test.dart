import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/vehicle/vehicle_list_screen.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';
import 'package:blap_car/models/vehicle.dart';

class MockVehicleProvider extends VehicleProvider {
  List<Vehicle> mockVehicles = [];
  
  @override
  List<Vehicle> get vehicles => mockVehicles;
  
  void setVehicles(List<Vehicle> vehicles) {
    mockVehicles = vehicles;
    notifyListeners();
  }
}

void main() {
  group('VehicleListScreen Tests', () {
    testWidgets('VehicleListScreen displays vehicles correctly', (WidgetTester tester) async {
      // Create a mock vehicle provider with some vehicles
      final vehicleProvider = MockVehicleProvider();
      vehicleProvider.setVehicles([
        Vehicle(
          id: 1,
          name: 'Test Car 1',
          make: 'Toyota',
          model: 'Camry',
          year: 2020,
          plate: 'ABC123',
          createdAt: DateTime.now(),
        ),
        Vehicle(
          id: 2,
          name: 'Test Car 2',
          make: 'Honda',
          model: 'Civic',
          year: 2019,
          plate: 'XYZ789',
          createdAt: DateTime.now(),
        ),
      ]);

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<VehicleProvider>.value(value: vehicleProvider),
            ],
            child: const VehicleListScreen(),
          ),
        ),
      );

      // Verify that the app bar title is correct
      expect(find.text('Vehicles'), findsOneWidget);

      // Verify that the vehicles are displayed
      expect(find.text('Test Car 1'), findsOneWidget);
      expect(find.text('Test Car 2'), findsOneWidget);
      
      // Verify that vehicle details are displayed
      expect(find.text('Toyota Camry (2020)'), findsOneWidget);
      expect(find.text('Honda Civic (2019)'), findsOneWidget);
      
      // Verify that license plates are displayed
      expect(find.text('ABC123'), findsOneWidget);
      expect(find.text('XYZ789'), findsOneWidget);
    });

    testWidgets('VehicleListScreen shows add vehicle button', (WidgetTester tester) async {
      final vehicleProvider = MockVehicleProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<VehicleProvider>.value(value: vehicleProvider),
            ],
            child: const VehicleListScreen(),
          ),
        ),
      );

      // Verify that the add button is present
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('AddVehicleScreen has correct form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddVehicleScreen(),
        ),
      );

      // Verify that the app bar title is correct
      expect(find.text('Add Vehicle'), findsOneWidget);

      // Verify that form fields are present
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Make'), findsOneWidget);
      expect(find.text('Model'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
      expect(find.text('License Plate'), findsOneWidget);
      expect(find.text('Fuel Tank Volume'), findsOneWidget);
      expect(find.text('VIN'), findsOneWidget);
      expect(find.text('RENAVAM'), findsOneWidget);
      expect(find.text('Initial Odometer'), findsOneWidget);

      // Verify that save button is present
      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });
}