import 'package:flutter/foundation.dart';
import 'package:blap_car/services/backup_service.dart';
import 'package:blap_car/models/backup.dart';

class BackupProvider with ChangeNotifier {
  final BackupService _backupService = BackupService();
  List<Backup> _backups = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Backup> get backups => _backups;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load all backups
  Future<void> loadBackups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _backups = await _backupService.getAllBackups();
    } catch (e) {
      _errorMessage = 'Failed to load backups: $e';
      debugPrint('Error loading backups: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new backup
  Future<bool> createBackup(String name, {String? description}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final backup = await _backupService.createBackup(name, description: description);
      _backups.insert(0, backup); // Add to the beginning of the list
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create backup: $e';
      debugPrint('Error creating backup: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Restore from a backup
  Future<bool> restoreBackup(String filePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _backupService.restoreBackup(filePath);
      if (!success) {
        _errorMessage = 'Failed to restore backup';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Failed to restore backup: $e';
      debugPrint('Error restoring backup: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a backup
  Future<bool> deleteBackup(Backup backup) async {
    try {
      final success = await _backupService.deleteBackup(backup.filePath);
      if (success) {
        _backups.remove(backup);
        notifyListeners();
      } else {
        _errorMessage = 'Failed to delete backup';
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete backup: $e';
      debugPrint('Error deleting backup: $e');
      notifyListeners();
      return false;
    }
  }
}