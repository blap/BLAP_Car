import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/refueling/refueling_screen.dart';
import 'package:blap_car/modules/refueling/refueling_provider.dart';
import 'package:blap_car/models/refueling.dart';

class MockRefuelingProvider extends RefuelingProvider {
  List<Refueling> mockRefuelings = [];
  
  @override
  List<Refueling> get refuelings => mockRefuelings;
  
  void setRefuelings(List<Refueling> refuelings) {
    mockRefuelings = refuelings;
    notifyListeners();
  }
}

void main() {
  group('RefuelingScreen Tests', () {
    testWidgets('RefuelingListScreen displays refuelings correctly', (WidgetTester tester) async {
      // Create a mock refueling provider with some refuelings
      final refuelingProvider = MockRefuelingProvider();
      refuelingProvider.setRefuelings([
        Refueling(
          id: 1,
          vehicleId: 1,
          date: DateTime(2023, 1, 15),
          odometer: 10000.0,
          fuelType: 'Gasoline',
          totalCost: 250.0,
        ),
        Refueling(
          id: 2,
          vehicleId: 1,
          date: DateTime(2023, 2, 20),
          odometer: 10500.0,
          fuelType: 'Ethanol',
          totalCost: 200.0,
        ),
      ]);

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<RefuelingProvider>.value(value: refuelingProvider),
            ],
            child: const RefuelingListScreen(vehicleId: 1),
          ),
        ),
      );

      // Verify that the app bar title is correct
      expect(find.text('Refueling Records'), findsOneWidget);

      // Verify that the refuelings are displayed
      expect(find.text('Gasoline - 250.00'), findsOneWidget);
      expect(find.text('Ethanol - 200.00'), findsOneWidget);
      
      // Verify that odometer readings are displayed
      expect(find.text('Odometer: 10000 km'), findsOneWidget);
      expect(find.text('Odometer: 10500 km'), findsOneWidget);
      
      // Verify that dates are displayed
      expect(find.text('2023-01-15'), findsOneWidget);
      expect(find.text('2023-02-20'), findsOneWidget);
    });

    testWidgets('RefuelingListScreen shows add refueling button', (WidgetTester tester) async {
      final refuelingProvider = MockRefuelingProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<RefuelingProvider>.value(value: refuelingProvider),
            ],
            child: const RefuelingListScreen(vehicleId: 1),
          ),
        ),
      );

      // Verify that the add button is present
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('AddRefuelingScreen has correct form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddRefuelingScreen(vehicleId: 1),
        ),
      );

      // Verify that the app bar title is correct
      expect(find.text('Add Refueling'), findsOneWidget);

      // Verify that form fields are present
      expect(find.text('Odometer'), findsOneWidget);
      expect(find.text('Fuel Type'), findsOneWidget);
      expect(find.text('Price per Liter'), findsOneWidget);
      expect(find.text('Liters'), findsOneWidget);
      expect(find.text('Total Cost'), findsOneWidget);
      expect(find.text('Full Tank'), findsOneWidget);
      expect(find.text('Previous Refueling Missing'), findsOneWidget);

      // Verify that save button is present
      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });
}