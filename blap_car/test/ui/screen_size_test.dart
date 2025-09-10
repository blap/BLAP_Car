import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/main.dart';

void main() {
  group('UI Screen Size Tests', () {
    testWidgets('App can be instantiated', (WidgetTester tester) async {
      // This test just verifies that the app can be created without errors
      expect(() => MyApp(), returnsNormally);
    });
  });
}