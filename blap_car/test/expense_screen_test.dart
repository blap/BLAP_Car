import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:blap_car/modules/expense/expense_screen.dart';
import 'package:blap_car/modules/expense/expense_provider.dart';
import 'package:blap_car/models/expense.dart';

class MockExpenseProvider extends ExpenseProvider {
  List<Expense> mockExpenses = [];
  
  @override
  List<Expense> get expenses => mockExpenses;
  
  void setExpenses(List<Expense> expenses) {
    mockExpenses = expenses;
    notifyListeners();
  }
}

void main() {
  group('ExpenseScreen Tests', () {
    testWidgets('ExpenseListScreen displays expenses correctly', (WidgetTester tester) async {
      // Create a mock expense provider with some expenses
      final expenseProvider = MockExpenseProvider();
      expenseProvider.setExpenses([
        Expense(
          id: 1,
          vehicleId: 1,
          date: DateTime(2023, 1, 15),
          type: 'Maintenance',
          cost: 150.0,
        ),
        Expense(
          id: 2,
          vehicleId: 1,
          date: DateTime(2023, 2, 20),
          type: 'Fuel',
          cost: 200.0,
        ),
      ]);

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ],
            child: const ExpenseListScreen(vehicleId: 1),
          ),
        ),
      );

      // Verify that the app bar title is correct
      expect(find.text('Expenses'), findsOneWidget);

      // Verify that the expenses are displayed
      expect(find.text('Maintenance - 150.00'), findsOneWidget);
      expect(find.text('Fuel - 200.00'), findsOneWidget);
      
      // Verify that dates are displayed
      expect(find.text('2023-01-15'), findsOneWidget);
      expect(find.text('2023-02-20'), findsOneWidget);
    });

    testWidgets('ExpenseListScreen shows add expense button', (WidgetTester tester) async {
      final expenseProvider = MockExpenseProvider();
      
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<ExpenseProvider>.value(value: expenseProvider),
            ],
            child: const ExpenseListScreen(vehicleId: 1),
          ),
        ),
      );

      // Verify that the add button is present
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('AddExpenseScreen has correct form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AddExpenseScreen(vehicleId: 1),
        ),
      );

      // Verify that the app bar title is correct
      expect(find.text('Add Expense'), findsOneWidget);

      // Verify that form fields are present
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Odometer'), findsOneWidget);
      expect(find.text('Expense Type'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('Location'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Observation'), findsOneWidget);

      // Verify that save button is present
      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });
}