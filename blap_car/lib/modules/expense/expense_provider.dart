import 'package:flutter/foundation.dart';
import 'package:blap_car/models/expense.dart';
import 'package:blap_car/services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  final ExpenseService _expenseService = ExpenseService();

  List<Expense> get expenses => _expenses;

  // Load all expenses for a vehicle
  Future<void> loadExpenses(int vehicleId) async {
    _expenses = await _expenseService.getExpensesByVehicleId(vehicleId);
    notifyListeners();
  }

  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    final id = await _expenseService.addExpense(expense);
    expense.id = id;
    _expenses.add(expense);
    notifyListeners();
  }

  // Update an expense
  Future<void> updateExpense(Expense expense) async {
    await _expenseService.updateExpense(expense);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }
  }

  // Delete an expense
  Future<void> deleteExpense(int id) async {
    await _expenseService.deleteExpense(id);
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }
}