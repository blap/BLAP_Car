import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/models/expense_reminder.dart';

void main() {
  group('ExpenseReminder Model Tests', () {
    test('ExpenseReminder can be created with required fields', () {
      final createdAt = DateTime.now();
      final reminder = ExpenseReminder(
        vehicleId: 1,
        createdAt: createdAt,
      );

      expect(reminder.vehicleId, 1);
      expect(reminder.createdAt, createdAt);
    });

    test('ExpenseReminder can be created with all fields', () {
      final createdAt = DateTime.now();
      final updatedAt = DateTime.now().add(Duration(hours: 1));
      final triggerDate = DateTime.now().add(Duration(days: 30));
      final reminder = ExpenseReminder(
        id: 1,
        vehicleId: 1,
        expenseType: 'Insurance',
        isRecurring: true,
        triggerKmEnabled: true,
        triggerKm: 15000.0,
        triggerDateEnabled: true,
        triggerDate: triggerDate,
        recurringKmEnabled: true,
        recurringKmInterval: 10000,
        recurringTimeEnabled: true,
        recurringDaysInterval: 0,
        recurringMonthsInterval: 12,
        recurringYearsInterval: 0,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(reminder.id, 1);
      expect(reminder.vehicleId, 1);
      expect(reminder.expenseType, 'Insurance');
      expect(reminder.isRecurring, true);
      expect(reminder.triggerKmEnabled, true);
      expect(reminder.triggerKm, 15000.0);
      expect(reminder.triggerDateEnabled, true);
      expect(reminder.triggerDate, triggerDate);
      expect(reminder.recurringKmEnabled, true);
      expect(reminder.recurringKmInterval, 10000);
      expect(reminder.recurringTimeEnabled, true);
      expect(reminder.recurringDaysInterval, 0);
      expect(reminder.recurringMonthsInterval, 12);
      expect(reminder.recurringYearsInterval, 0);
      expect(reminder.createdAt, createdAt);
      expect(reminder.updatedAt, updatedAt);
    });

    test('ExpenseReminder can be converted to and from map', () {
      final createdAt = DateTime.now();
      final updatedAt = DateTime.now().add(Duration(hours: 1));
      final triggerDate = DateTime.now().add(Duration(days: 30));
      final reminder = ExpenseReminder(
        id: 1,
        vehicleId: 1,
        expenseType: 'Insurance',
        isRecurring: true,
        triggerKmEnabled: true,
        triggerKm: 15000.0,
        triggerDateEnabled: true,
        triggerDate: triggerDate,
        recurringKmEnabled: true,
        recurringKmInterval: 10000,
        recurringTimeEnabled: true,
        recurringDaysInterval: 0,
        recurringMonthsInterval: 12,
        recurringYearsInterval: 0,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = reminder.toMap();
      final reminderFromMap = ExpenseReminder.fromMap(map);

      expect(reminderFromMap.id, reminder.id);
      expect(reminderFromMap.vehicleId, reminder.vehicleId);
      expect(reminderFromMap.expenseType, reminder.expenseType);
      expect(reminderFromMap.isRecurring, reminder.isRecurring);
      expect(reminderFromMap.triggerKmEnabled, reminder.triggerKmEnabled);
      expect(reminderFromMap.triggerKm, reminder.triggerKm);
      expect(reminderFromMap.triggerDateEnabled, reminder.triggerDateEnabled);
      expect(reminderFromMap.triggerDate, reminder.triggerDate);
      expect(reminderFromMap.recurringKmEnabled, reminder.recurringKmEnabled);
      expect(reminderFromMap.recurringKmInterval, reminder.recurringKmInterval);
      expect(reminderFromMap.recurringTimeEnabled, reminder.recurringTimeEnabled);
      expect(reminderFromMap.recurringDaysInterval, reminder.recurringDaysInterval);
      expect(reminderFromMap.recurringMonthsInterval, reminder.recurringMonthsInterval);
      expect(reminderFromMap.recurringYearsInterval, reminder.recurringYearsInterval);
      expect(reminderFromMap.createdAt, reminder.createdAt);
      expect(reminderFromMap.updatedAt, reminder.updatedAt);
    });
  });
}