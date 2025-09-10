import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/vehicle/vehicle_provider.dart';
import 'package:blap_car/modules/refueling/refueling_provider.dart';
import 'package:blap_car/modules/expense/expense_provider.dart';
import 'package:blap_car/modules/maintenance/maintenance_provider.dart';
import 'package:blap_car/modules/reminder/expense_reminder_provider.dart';
import 'package:blap_car/modules/reminder/reminder_provider.dart';
import 'package:blap_car/modules/report/report_provider.dart';
import 'package:blap_car/modules/data/data_provider.dart';
import 'package:blap_car/modules/checklist/checklist_provider.dart';
import 'package:blap_car/modules/backup/backup_provider.dart';
import 'package:blap_car/screens/home_dashboard_screen.dart';
import 'package:blap_car/screens/settings_screen.dart';
import 'package:blap_car/screens/backup_screen.dart';
import 'package:blap_car/modules/vehicle/vehicle_list_screen.dart';
import 'package:blap_car/modules/refueling/refueling_wrapper_screen.dart';
import 'package:blap_car/modules/expense/expense_wrapper_screen.dart';
import 'package:blap_car/modules/reminder/expense_reminder_wrapper_screen.dart';
import 'package:blap_car/modules/report/report_wrapper_screen.dart';
import 'package:blap_car/modules/refueling/add_refueling_wrapper_screen.dart';
import 'package:blap_car/modules/expense/add_expense_wrapper_screen.dart';
import 'package:blap_car/modules/reminder/add_expense_reminder_wrapper_screen.dart';
import 'package:blap_car/services/theme_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => RefuelingProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseReminderProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => ChecklistProvider()),
        ChangeNotifierProvider(create: (_) => BackupProvider()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'BLAP Car - Vehicle Fleet Management',
          theme: themeService.themeData,
          home: const HomeDashboardScreen(),
          // Define named routes for navigation
          routes: {
            '/home': (context) => const HomeDashboardScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/backup': (context) => BackupScreen(),
            '/vehicles': (context) => const VehicleListScreen(),
            '/refueling': (context) => const RefuelingWrapperScreen(),
            '/expense': (context) => const ExpenseWrapperScreen(),
            '/reminder': (context) => const ExpenseReminderWrapperScreen(),
            '/report': (context) => const ReportWrapperScreen(),
            '/add-refueling': (context) => const AddRefuelingWrapperScreen(),
            '/add-expense': (context) => const AddExpenseWrapperScreen(),
            '/add-reminder': (context) => const AddExpenseReminderWrapperScreen(),
          },
        );
      },
    );
  }
}