import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/models/reminder.dart';

void main() {
  group('Reminder Model Tests', () {
    test('Reminder can be created with required fields', () {
      final reminder = Reminder(
        vehicleId: 1,
      );

      expect(reminder.vehicleId, 1);
    });

    test('Reminder can be created with all fields', () {
      final date = DateTime.now();
      final reminder = Reminder(
        id: 1,
        vehicleId: 1,
        type: 'Maintenance',
        description: 'Oil change reminder',
        date: date,
        completed: false,
      );

      expect(reminder.id, 1);
      expect(reminder.vehicleId, 1);
      expect(reminder.type, 'Maintenance');
      expect(reminder.description, 'Oil change reminder');
      expect(reminder.date, date);
      expect(reminder.completed, false);
    });

    test('Reminder can be converted to and from map', () {
      final date = DateTime.now();
      final reminder = Reminder(
        id: 1,
        vehicleId: 1,
        type: 'Maintenance',
        description: 'Oil change reminder',
        date: date,
        completed: true,
      );

      final map = reminder.toMap();
      final reminderFromMap = Reminder.fromMap(map);

      expect(reminderFromMap.id, reminder.id);
      expect(reminderFromMap.vehicleId, reminder.vehicleId);
      expect(reminderFromMap.type, reminder.type);
      expect(reminderFromMap.description, reminder.description);
      expect(reminderFromMap.date, reminder.date);
      expect(reminderFromMap.completed, reminder.completed);
    });

    test('Reminder completed field is correctly converted to map', () {
      final reminderTrue = Reminder(
        vehicleId: 1,
        completed: true,
      );

      final reminderFalse = Reminder(
        vehicleId: 1,
        completed: false,
      );

      final mapTrue = reminderTrue.toMap();
      final mapFalse = reminderFalse.toMap();

      expect(mapTrue['completed'], 1);
      expect(mapFalse['completed'], 0);
    });
  });
}