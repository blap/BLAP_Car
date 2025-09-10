import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/recent_activity_service.dart';
import 'package:blap_car/models/recent_activity.dart';

void main() {
  group('RecentActivityService Tests', () {
    late RecentActivityService recentActivityService;

    setUp(() {
      recentActivityService = RecentActivityService();
    });

    test('RecentActivityService can be instantiated', () {
      expect(recentActivityService, isNotNull);
      expect(recentActivityService, isA<RecentActivityService>());
    });

    test('RecentActivity model can be created and converted to map', () {
      final activity = RecentActivity(
        id: 1,
        type: 'Refueling',
        description: 'Diesel refueling at Shell',
        date: DateTime(2023, 1, 15),
        cost: 50.0,
        vehicleName: 'Toyota Camry',
      );

      expect(activity.id, equals(1));
      expect(activity.type, equals('Refueling'));
      expect(activity.description, equals('Diesel refueling at Shell'));
      expect(activity.cost, equals(50.0));
      expect(activity.vehicleName, equals('Toyota Camry'));

      final map = activity.toMap();
      expect(map['id'], equals(1));
      expect(map['type'], equals('Refueling'));
      expect(map['description'], equals('Diesel refueling at Shell'));
      expect(map['cost'], equals(50.0));
      expect(map['vehicleName'], equals('Toyota Camry'));
    });

    test('RecentActivity can be created from map', () {
      final map = {
        'id': 2,
        'type': 'Expense',
        'description': 'Tire replacement',
        'date': '2023-02-20T10:30:00.000',
        'cost': 200.0,
        'vehicleName': 'Honda Civic',
      };

      final activity = RecentActivity.fromMap(map);
      expect(activity.id, equals(2));
      expect(activity.type, equals('Expense'));
      expect(activity.description, equals('Tire replacement'));
      expect(activity.date, equals(DateTime(2023, 2, 20, 10, 30)));
      expect(activity.cost, equals(200.0));
      expect(activity.vehicleName, equals('Honda Civic'));
    });
  });
}