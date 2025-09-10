import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Notification Preferences', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    tearDown(() {
      // Clean up any resources after each test
    });

    test('should save and load notification preferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      // Test default values
      expect(prefs.getBool('notifications_enabled'), null);
      expect(prefs.getBool('reminders_enabled'), null);
      expect(prefs.getBool('fuel_cost_alerts_enabled'), null);
      expect(prefs.getBool('maintenance_due_alerts_enabled'), null);
      expect(prefs.getBool('expense_threshold_alerts_enabled'), null);
      expect(prefs.getString('notification_sound'), null);
      expect(prefs.getString('notification_priority'), null);
      
      // Save values
      await prefs.setBool('notifications_enabled', true);
      await prefs.setBool('reminders_enabled', true);
      await prefs.setBool('fuel_cost_alerts_enabled', false);
      await prefs.setBool('maintenance_due_alerts_enabled', true);
      await prefs.setBool('expense_threshold_alerts_enabled', false);
      await prefs.setString('notification_sound', 'Ringtone');
      await prefs.setString('notification_priority', 'High');
      
      // Load values
      expect(prefs.getBool('notifications_enabled'), true);
      expect(prefs.getBool('reminders_enabled'), true);
      expect(prefs.getBool('fuel_cost_alerts_enabled'), false);
      expect(prefs.getBool('maintenance_due_alerts_enabled'), true);
      expect(prefs.getBool('expense_threshold_alerts_enabled'), false);
      expect(prefs.getString('notification_sound'), 'Ringtone');
      expect(prefs.getString('notification_priority'), 'High');
    });
  });
  
  group('Advanced Configuration Options', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    tearDown(() {
      // Clean up any resources after each test
    });

    test('should save and load advanced configuration options', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      
      // Test default values
      expect(prefs.getString('default_export_format'), null);
      expect(prefs.getString('chart_visualization_style'), null);
      expect(prefs.getBool('data_compression_enabled'), null);
      expect(prefs.getBool('advanced_reminder_algorithms_enabled'), null);
      expect(prefs.getBool('auto_data_cleanup_enabled'), null);
      expect(prefs.getString('data_retention_period'), null);
      
      // Save values
      await prefs.setString('default_export_format', 'CSV');
      await prefs.setString('chart_visualization_style', 'Bar');
      await prefs.setBool('data_compression_enabled', true);
      await prefs.setBool('advanced_reminder_algorithms_enabled', true);
      await prefs.setBool('auto_data_cleanup_enabled', false);
      await prefs.setString('data_retention_period', '90 days');
      
      // Load values
      expect(prefs.getString('default_export_format'), 'CSV');
      expect(prefs.getString('chart_visualization_style'), 'Bar');
      expect(prefs.getBool('data_compression_enabled'), true);
      expect(prefs.getBool('advanced_reminder_algorithms_enabled'), true);
      expect(prefs.getBool('auto_data_cleanup_enabled'), false);
      expect(prefs.getString('data_retention_period'), '90 days');
    });
  });
}