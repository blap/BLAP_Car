import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/reminder_service.dart';
import 'package:blap_car/models/reminder.dart';
import 'package:blap_car/models/expense_reminder.dart';

void main() {
  group('ReminderService Tests', () {
    late ReminderService reminderService;

    setUp(() {
      reminderService = ReminderService();
    });

    test('ReminderService can be instantiated', () {
      expect(reminderService, isNotNull);
      expect(reminderService, isA<ReminderService>());
    });

    test('Reminder model can be created and converted to map', () {
      final reminder = Reminder(
        id: 1,
        vehicleId: 1,
        type: 'Maintenance',
        description: 'Oil change',
        date: DateTime(2023, 6, 15),
        completed: false,
      );

      expect(reminder.id, equals(1));
      expect(reminder.vehicleId, equals(1));
      expect(reminder.type, equals('Maintenance'));
      expect(reminder.description, equals('Oil change'));
      expect(reminder.completed, equals(false));

      final map = reminder.toMap();
      expect(map['id'], equals(1));
      expect(map['vehicle_id'], equals(1));
      expect(map['type'], equals('Maintenance'));
      expect(map['description'], equals('Oil change'));
      expect(map['completed'], equals(0)); // false = 0
    });

    test('ExpenseReminder model can be created and converted to map', () {
      final reminder = ExpenseReminder(
        id: 1,
        vehicleId: 1,
        expenseType: 'Insurance',
        isRecurring: true,
        triggerDateEnabled: true,
        triggerDate: DateTime(2023, 6, 15),
        triggerKmEnabled: false,
        createdAt: DateTime(2023, 1, 1),
      );

      expect(reminder.id, equals(1));
      expect(reminder.vehicleId, equals(1));
      expect(reminder.expenseType, equals('Insurance'));
      expect(reminder.isRecurring, equals(true));
      expect(reminder.triggerDateEnabled, equals(true));

      final map = reminder.toMap();
      expect(map['id'], equals(1));
      expect(map['vehicle_id'], equals(1));
      expect(map['expense_type'], equals('Insurance'));
      expect(map['is_recurring'], equals(1)); // true = 1
      expect(map['trigger_date_enabled'], equals(1)); // true = 1
    });
  });
}