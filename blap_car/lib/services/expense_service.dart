import 'package:blap_car/models/expense.dart';
import 'package:blap_car/database/expense_dao.dart';

class ExpenseService {
  final ExpenseDao _expenseDao = ExpenseDao();

  // Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    return await _expenseDao.getAllExpenses();
  }

  // Get expenses by vehicle id
  Future<List<Expense>> getExpensesByVehicleId(int vehicleId) async {
    return await _expenseDao.getExpensesByVehicleId(vehicleId);
  }

  // Get an expense by id
  Future<Expense?> getExpenseById(int id) async {
    return await _expenseDao.getExpenseById(id);
  }

  // Add a new expense
  Future<int> addExpense(Expense expense) async {
    return await _expenseDao.insertExpense(expense);
  }

  // Update an expense
  Future<int> updateExpense(Expense expense) async {
    return await _expenseDao.updateExpense(expense);
  }

  // Delete an expense
  Future<int> deleteExpense(int id) async {
    return await _expenseDao.deleteExpense(id);
  }
}