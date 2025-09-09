import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/models/expense.dart';

void main() {
  group('Expense Model Tests', () {
    test('Expense can be created with required fields', () {
      final date = DateTime.now();
      final expense = Expense(
        vehicleId: 1,
        date: date,
      );

      expect(expense.vehicleId, 1);
      expect(expense.date, date);
    });

    test('Expense can be created with all fields', () {
      final date = DateTime.now();
      final time = DateTime.now();
      final expense = Expense(
        id: 1,
        vehicleId: 1,
        type: 'Maintenance',
        description: 'Oil change',
        cost: 150.0,
        date: date,
        time: time,
        odometer: 10000.0,
        location: 'Garage',
        driver: 'John Doe',
        paymentMethod: 'Credit Card',
        observation: 'Regular maintenance',
        attachmentPath: '/path/to/attachment.jpg',
        category: 'Repair',
      );

      expect(expense.id, 1);
      expect(expense.vehicleId, 1);
      expect(expense.type, 'Maintenance');
      expect(expense.description, 'Oil change');
      expect(expense.cost, 150.0);
      expect(expense.date, date);
      expect(expense.time, time);
      expect(expense.odometer, 10000.0);
      expect(expense.location, 'Garage');
      expect(expense.driver, 'John Doe');
      expect(expense.paymentMethod, 'Credit Card');
      expect(expense.observation, 'Regular maintenance');
      expect(expense.attachmentPath, '/path/to/attachment.jpg');
      expect(expense.category, 'Repair');
    });

    test('Expense can be converted to and from map', () {
      final date = DateTime.now();
      final time = DateTime.now();
      final expense = Expense(
        id: 1,
        vehicleId: 1,
        type: 'Maintenance',
        description: 'Oil change',
        cost: 150.0,
        date: date,
        time: time,
        odometer: 10000.0,
        location: 'Garage',
        driver: 'John Doe',
        paymentMethod: 'Credit Card',
        observation: 'Regular maintenance',
        attachmentPath: '/path/to/attachment.jpg',
        category: 'Repair',
      );

      final map = expense.toMap();
      final expenseFromMap = Expense.fromMap(map);

      expect(expenseFromMap.id, expense.id);
      expect(expenseFromMap.vehicleId, expense.vehicleId);
      expect(expenseFromMap.type, expense.type);
      expect(expenseFromMap.description, expense.description);
      expect(expenseFromMap.cost, expense.cost);
      expect(expenseFromMap.date, expense.date);
      expect(expenseFromMap.time, expense.time);
      expect(expenseFromMap.odometer, expense.odometer);
      expect(expenseFromMap.location, expense.location);
      expect(expenseFromMap.driver, expense.driver);
      expect(expenseFromMap.paymentMethod, expense.paymentMethod);
      expect(expenseFromMap.observation, expense.observation);
      expect(expenseFromMap.attachmentPath, expense.attachmentPath);
      expect(expenseFromMap.category, expense.category);
    });
  });
}