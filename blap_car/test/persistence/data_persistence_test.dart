import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Data Persistence Tests', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({
        'test_key': 'test_value',
        'test_int': 42,
        'test_bool': true,
      });
    });

    test('SharedPreferences can store and retrieve data', () async {
      final prefs = await SharedPreferences.getInstance();
      
      // Test string value
      expect(prefs.getString('test_key'), equals('test_value'));
      
      // Test int value
      expect(prefs.getInt('test_int'), equals(42));
      
      // Test bool value
      expect(prefs.getBool('test_bool'), equals(true));
      
      // Test setting new values
      await prefs.setString('new_key', 'new_value');
      expect(prefs.getString('new_key'), equals('new_value'));
      
      // Test updating existing values
      await prefs.setInt('test_int', 100);
      expect(prefs.getInt('test_int'), equals(100));
    });

    test('SharedPreferences can remove data', () async {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove a key
      await prefs.remove('test_key');
      expect(prefs.getString('test_key'), isNull);
      
      // Clear all data
      await prefs.clear();
      expect(prefs.getString('test_int'), isNull);
      expect(prefs.getBool('test_bool'), isNull);
    });

    test('Data persistence simulation', () async {
      // First "app session"
      final prefs1 = await SharedPreferences.getInstance();
      await prefs1.setString('user_name', 'John Doe');
      await prefs1.setInt('login_count', 1);
      
      // Simulate app restart by getting a new instance
      final prefs2 = await SharedPreferences.getInstance();
      
      // Verify data persists
      expect(prefs2.getString('user_name'), equals('John Doe'));
      expect(prefs2.getInt('login_count'), equals(1));
      
      // Update data in "second session"
      await prefs2.setInt('login_count', 2);
      
      // Verify update persists
      final prefs3 = await SharedPreferences.getInstance();
      expect(prefs3.getInt('login_count'), equals(2));
    });
  });
}