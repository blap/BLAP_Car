import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:blap_car/services/reporting_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportingService _reportingService = ReportingService();
  
  Map<String, dynamic> _generalStats = {};
  Map<String, dynamic> _refuelingStats = {};
  Map<String, dynamic> _expenseStats = {};
  bool _isLoading = false;

  Map<String, dynamic> get generalStats => _generalStats;
  Map<String, dynamic> get refuelingStats => _refuelingStats;
  Map<String, dynamic> get expenseStats => _expenseStats;
  bool get isLoading => _isLoading;

  // Load all statistics for a vehicle
  Future<void> loadStatistics(int vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _generalStats = await _reportingService.calculateGeneralStats(vehicleId);
      _refuelingStats = await _reportingService.calculateFuelEfficiencyStats(vehicleId);
      _expenseStats = await _reportingService.calculateExpenseStats(vehicleId);
    } catch (e) {
      // Handle error
      debugPrint('Error loading statistics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}