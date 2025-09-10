import 'package:flutter/material.dart';
import 'package:blap_car/modules/expense/expense_screen.dart';

class ExpenseWrapperScreen extends StatelessWidget {
  const ExpenseWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we'll use a default vehicleId of 1
    // In a real app, you would select a vehicle first
    return ExpenseListScreen(vehicleId: 1);
  }
}