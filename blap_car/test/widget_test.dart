import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/main.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';

void main() {
  testWidgets('Home dashboard screen has correct widgets', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app bar title is correct
    expect(find.text('BLAP Car Dashboard'), findsOneWidget);

    // Verify that the quick action buttons are present
    expect(find.text('Add Reminder'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.text('Add Refueling'), findsOneWidget);

    // Verify that the recent activities section is present
    expect(find.text('Recent Activities'), findsOneWidget);

    // Verify that the main FAB is present (there are multiple FABs in total)
    expect(find.byType(FloatingActionButton), findsWidgets);
  });
}