import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/main.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';
import 'package:blap_car/modules/refueling/refueling_provider.dart';
import 'package:blap_car/modules/expense/expense_provider.dart';
import 'package:blap_car/modules/reminder/expense_reminder_provider.dart';
import 'package:blap_car/modules/report/report_provider.dart';
import 'package:blap_car/modules/data/data_provider.dart';
import 'package:blap_car/modules/checklist/checklist_provider.dart';
import 'package:blap_car/modules/maintenance/maintenance_provider.dart';
import 'package:blap_car/services/theme_service.dart';

void main() {
  testWidgets('Home dashboard screen has correct widgets', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VehicleProvider()),
          ChangeNotifierProvider(create: (_) => RefuelingProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseProvider()),
          ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
          ChangeNotifierProvider(create: (_) => ExpenseReminderProvider()),
          ChangeNotifierProvider(create: (_) => ReportProvider()),
          ChangeNotifierProvider(create: (_) => DataProvider()),
          ChangeNotifierProvider(create: (_) => ChecklistProvider()),
          ChangeNotifierProvider(create: (_) => ThemeService()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app bar is present by looking for the settings icon
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // When no vehicles are registered, we should see the "Add Your First Vehicle" button
    expect(find.text('Add Your First Vehicle'), findsOneWidget);
    
    // We should also see the "Recent Activities" section
    expect(find.text('Recent Activities'), findsOneWidget);
    
    // We should see the "Reports" section
    expect(find.text('Reports'), findsOneWidget);

    // Verify that we have buttons (IconButton) in the app bar
    expect(find.byType(IconButton), findsWidgets);
  });
}