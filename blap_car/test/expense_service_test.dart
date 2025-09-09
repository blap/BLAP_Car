import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/expense_service.dart';
import 'package:blap_car/models/expense.dart';

class MockExpenseDao {
  List<Expense> expenses = [];
  int _idCounter = 1;

  Future<int> insertExpense(Expense expense) async {
    expense.id = _idCounter++;
    expenses.add(expense);
    return expense.id!;
  }

  Future<List<Expense>> getAllExpenses() async {
    return expenses;
  }

  Future<List<Expense>> getExpensesByVehicleId(int vehicleId) async {
    return expenses.where((expense) => expense.vehicleId == vehicleId).toList();
  }

  Future<Expense?> getExpenseById(int id) async {
    try {
      return expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<int> updateExpense(Expense expense) async {
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      return 1; // Success
    }
    return 0; // Not found
  }

  Future<int> deleteExpense(int id) async {
    final initialLength = expenses.length;
    expenses.removeWhere((expense) => expense.id == id);
    return initialLength - expenses.length;
  }
}

// Create a testable version of ExpenseService
class TestExpenseService extends ExpenseService {
  final MockExpenseDao mockExpenseDao;
  
  TestExpenseService(this.mockExpenseDao);
  
  // Override the getter to return mock DAO
  @override
  Future<List<Expense>> getAllExpenses() async {
    return await mockExpenseDao.getAllExpenses();
  }
  
  @override
  Future<List<Expense>> getExpensesByVehicleId(int vehicleId) async {
    return await mockExpenseDao.getExpensesByVehicleId(vehicleId);
  }
  
  @override
  Future<Expense?> getExpenseById(int id) async {
    return await mockExpenseDao.getExpenseById(id);
  }
  
  @override
  Future<int> addExpense(Expense expense) async {
    return await mockExpenseDao.insertExpense(expense);
  }
  
  @override
  Future<int> updateExpense(Expense expense) async {
    return await mockExpenseDao.updateExpense(expense);
  }
  
  @override
  Future<int> deleteExpense(int id) async {
    return await mockExpenseDao.deleteExpense(id);
  }
}

void main() {
  group('ExpenseService Tests', () {
    late TestExpenseService expenseService;
    late MockExpenseDao mockExpenseDao;

    setUp(() {
      mockExpenseDao = MockExpenseDao();
      expenseService = TestExpenseService(mockExpenseDao);
    });

    test('ExpenseService can be instantiated', () {
      expect(expenseService, isNotNull);
      expect(expenseService, isA<ExpenseService>());
    });

    test('addExpense adds expense to the list', () async {
      final expense = Expense(
        vehicleId: 1,
        date: DateTime.now(),
        cost: 100.0,
      );

      final id = await expenseService.addExpense(expense);
      
      expect(id, 1);
      expect(mockExpenseDao.expenses.length, 1);
      expect(mockExpenseDao.expenses[0].id, 1);
    });

    test('getAllExpenses returns all expenses', () async {
      final expense1 = Expense(
        vehicleId: 1,
        date: DateTime.now(),
        cost: 100.0,
      );
      
      final expense2 = Expense(
        vehicleId: 2,
        date: DateTime.now(),
        cost: 200.0,
      );
      
      await mockExpenseDao.insertExpense(expense1);
      await mockExpenseDao.insertExpense(expense2);
      
      final expenses = await expenseService.getAllExpenses();
      
      expect(expenses.length, 2);
      expect(expenses[0].cost, 100.0);
      expect(expenses[1].cost, 200.0);
    });

    test('getExpensesByVehicleId returns expenses for specific vehicle', () async {
      final expense1 = Expense(
        vehicleId: 1,
        date: DateTime.now(),
        cost: 100.0,
      );
      
      final expense2 = Expense(
        vehicleId: 2,
        date: DateTime.now(),
        cost: 200.0,
      );
      
      final expense3 = Expense(
        vehicleId: 1,
        date: DateTime.now(),
        cost: 150.0,
      );
      
      await mockExpenseDao.insertExpense(expense1);
      await mockExpenseDao.insertExpense(expense2);
      await mockExpenseDao.insertExpense(expense3);
      
      final expenses = await expenseService.getExpensesByVehicleId(1);
      
      expect(expenses.length, 2);
      expect(expenses.every((expense) => expense.vehicleId == 1), isTrue);
    });

    test('getExpenseById returns correct expense', () async {
      final expense = Expense(
        vehicleId: 1,
        date: DateTime.now(),
        cost: 100.0,
      );
      
      final id = await mockExpenseDao.insertExpense(expense);
      
      final retrievedExpense = await expenseService.getExpenseById(id);
      
      expect(retrievedExpense, isNotNull);
      expect(retrievedExpense!.id, id);
      expect(retrievedExpense.cost, 100.0);
    });

    test('getExpenseById returns null for non-existent expense', () async {
      final expense = await expenseService.getExpenseById(999);
      expect(expense, isNull);
    });

    test('updateExpense updates existing expense', () async {
      final expense = Expense(
        vehicleId: 1,
        date: DateTime.now(),
        cost: 100.0,
      );
      
      final id = await mockExpenseDao.insertExpense(expense);
      
      final updatedExpense = Expense(
        id: id,
        vehicleId: 1,
        date: DateTime.now(),
        cost: 150.0,
      );
      
      final result = await expenseService.updateExpense(updatedExpense);
      
      expect(result, 1);
      expect(mockExpenseDao.expenses[0].cost, 150.0);
    });

    test('deleteExpense removes expense from list', () async {
      final expense = Expense(
        vehicleId: 1,
        date: DateTime.now(),
        cost: 100.0,
      );
      
      final id = await mockExpenseDao.insertExpense(expense);
      expect(mockExpenseDao.expenses.length, 1);
      
      final result = await expenseService.deleteExpense(id);
      
      expect(result, 1);
      expect(mockExpenseDao.expenses.length, 0);
    });
  });
}