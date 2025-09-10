import 'package:flutter/material.dart';
import 'package:blap_car/modules/reminder/expense_reminder_screen.dart';

class ExpenseReminderWrapperScreen extends StatelessWidget {
  const ExpenseReminderWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we'll use a default vehicleId of 1
    // In a real app, you would select a vehicle first
    return ExpenseReminderListScreen(vehicleId: 1);
  }
}