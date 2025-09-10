import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('BLAP Car App', () {
    FlutterDriver? driver;

    setUpAll(() async {
      // Connect to the Flutter driver before running any tests
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      // Close the connection to the driver after the tests have completed
      driver?.close();
    });

    test('app launches and displays dashboard', () async {
      // Wait for the app to load
      await driver?.waitFor(find.text('BLAP Car Dashboard'));
      
      // Verify that the dashboard is displayed
      expect(await driver?.getText(find.text('BLAP Car Dashboard')), 'BLAP Car Dashboard');
    });
  });
}