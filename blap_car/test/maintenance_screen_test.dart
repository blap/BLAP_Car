import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/maintenance/maintenance_screen.dart';
import 'package:blap_car/modules/maintenance/maintenance_provider.dart';
import 'package:blap_car/models/maintenance.dart';

class MockMaintenanceProvider extends MaintenanceProvider {
  List<Maintenance> mockMaintenances = [];
  
  @override
  List<Maintenance> get maintenances => mockMaintenances;
  
  void setMaintenances(List<Maintenance> maintenances) {
    mockMaintenances = maintenances;
    notifyListeners();
  }
}

void main() {
  group('MaintenanceScreen Tests', () {
    testWidgets('MaintenanceListScreen displays maintenances correctly', (WidgetTester tester) async {
      // Create a mock maintenance provider with some maintenances
      final maintenanceProvider = MockMaintenanceProvider();
      maintenanceProvider.setMaintenances([
        Maintenance(
          id: 1,
          vehicleId: 1,
          type: 'Oil Change',
          description: 'Regular oil change',
          cost: 150.0,
          date: DateTime(2023, 1, 15),
          nextDate: DateTime(2023, 7, 15),
          odometer: 10000,
          status: 'Completed',
        ),
        Maintenance(
          id: 2,
          vehicleId: 1,
          type: 'Tire Rotation',
          description: 'Rotate all tires',
          cost: 50.0,
          date: DateTime(2023, 2, 20),
          nextDate: DateTime(2023, 8, 20),
          odometer: 10500,
          status: 'Pending',
        ),
      ]);

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<MaintenanceProvider>.value(value: maintenanceProvider),
            ],
            child: const MaintenanceListScreen(vehicleId: 1),
          ),
        ),
      );

      // Verify that the app bar title is correct
      expect(find.text('Maintenance'), findsOneWidget);

      // Verify that the maintenances are displayed
      expect(find.text('Oil Change - 150.00'), findsOneWidget);
      expect(find.text('Tire Rotation - 50.00'), findsOneWidget);
      
      // Verify that status is displayed
      expect(find.text('Status: Completed'), findsOneWidget);
      expect(find.text('Status: Pending'), findsOneWidget);
      
      // Verify that dates are displayed
      expect(find.text('2023-01-15'), findsOneWidget);
      expect(find.text('2023-02-20'), findsOneWidget);
    });

    testWidgets('MaintenanceListScreen shows add maintenance button', (WidgetTester tester) async {
      final maintenanceProvider = MockMaintenanceProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<MaintenanceProvider>.value(value: maintenanceProvider),
            ],
            child: const MaintenanceListScreen(vehicleId: 1),
          ),
        ),
      );

      // Verify that the add button is present
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('AddMaintenanceScreen has correct form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddMaintenanceScreen(vehicleId: 1),
        ),
      );

      // Verify that the app bar title is correct
      expect(find.text('Add Maintenance'), findsOneWidget);

      // Verify that form fields are present
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Next Date'), findsOneWidget);
      expect(find.text('Odometer'), findsOneWidget);
      expect(find.text('Maintenance Type'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);

      // Verify that save button is present
      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });
}