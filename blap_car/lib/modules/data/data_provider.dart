import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:blap_car/services/data_management_service.dart';

class DataProvider with ChangeNotifier {
  final DataManagementService _dataService = DataManagementService();
  
  bool _isExporting = false;
  bool _isImporting = false;
  String _message = '';
  
  bool get isExporting => _isExporting;
  bool get isImporting => _isImporting;
  String get message => _message;

  // Export data to Excel
  Future<void> exportToExcel() async {
    _isExporting = true;
    _message = 'Exporting data to Excel...';
    notifyListeners();

    try {
      final filePath = await _dataService.exportToExcel();
      _message = 'Data exported successfully to: $filePath';
    } catch (e) {
      _message = 'Error exporting data: $e';
      debugPrint('Error exporting to Excel: $e');
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  // Export data to CSV
  Future<void> exportToCsv() async {
    _isExporting = true;
    _message = 'Exporting data to CSV...';
    notifyListeners();

    try {
      final filePath = await _dataService.exportToCsv();
      _message = 'Data exported successfully to: $filePath';
    } catch (e) {
      _message = 'Error exporting data: $e';
      debugPrint('Error exporting to CSV: $e');
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  // Import data from Excel
  Future<void> importFromExcel(String filePath) async {
    _isImporting = true;
    _message = 'Importing data from Excel...';
    notifyListeners();

    try {
      await _dataService.importFromExcel(filePath);
      _message = 'Data imported successfully from: $filePath';
    } catch (e) {
      _message = 'Error importing data: $e';
      debugPrint('Error importing from Excel: $e');
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  // Import data from CSV
  Future<void> importFromCsv(String filePath) async {
    _isImporting = true;
    _message = 'Importing data from CSV...';
    notifyListeners();

    try {
      await _dataService.importFromCsv(filePath);
      _message = 'Data imported successfully from: $filePath';
    } catch (e) {
      _message = 'Error importing data: $e';
      debugPrint('Error importing from CSV: $e');
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }
}