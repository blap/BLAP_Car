import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/sync_service.dart';

void main() {
  group('SyncService', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    test('SyncService can be instantiated', () {
      final syncService = SyncService();
      expect(syncService, isNotNull);
      expect(syncService, isA<SyncService>());
    });
  });
}
