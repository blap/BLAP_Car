import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ThemeService Tests', () {
    late ThemeService themeService;

    setUp(() {
      themeService = ThemeService();
    });

    test('ThemeService can be instantiated', () {
      expect(themeService, isNotNull);
      expect(themeService, isA<ThemeService>());
    });
  });
}