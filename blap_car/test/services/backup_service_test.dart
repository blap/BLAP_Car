import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/backup_service.dart';

void main() {
  group('BackupService', () {
    late BackupService backupService;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      backupService = BackupService();
    });

    test('BackupService can be instantiated', () {
      expect(backupService, isNotNull);
      expect(backupService, isA<BackupService>());
    });
  });
}