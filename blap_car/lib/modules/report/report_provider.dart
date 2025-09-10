import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:blap_car/services/reporting_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportingService _reportingService = ReportingService();
  
  Map<String, dynamic> _generalStats = {};
  Map<String, dynamic> _refuelingStats = {};
  Map<String, dynamic> _expenseStats = {};
  List<Map<String, dynamic>> _fuelConsumptionTrend = [];
  List<Map<String, dynamic>> _costPerLiterTrend = [];
  List<Map<String, dynamic>> _expenseTrend = [];
  Map<String, double> _expenseTypeDistribution = {};
  bool _isLoading = false;

  Map<String, dynamic> get generalStats => _generalStats;
  Map<String, dynamic> get refuelingStats => _refuelingStats;
  Map<String, dynamic> get expenseStats => _expenseStats;
  List<Map<String, dynamic>> get fuelConsumptionTrend => _fuelConsumptionTrend;
  List<Map<String, dynamic>> get costPerLiterTrend => _costPerLiterTrend;
  List<Map<String, dynamic>> get expenseTrend => _expenseTrend;
  Map<String, double> get expenseTypeDistribution => _expenseTypeDistribution;
  bool get isLoading => _isLoading;

  // Load all statistics for a vehicle
  Future<void> loadStatistics(int vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _generalStats = await _reportingService.calculateGeneralStats(vehicleId);
      _refuelingStats = await _reportingService.calculateFuelEfficiencyStats(vehicleId);
      _expenseStats = await _reportingService.calculateExpenseStats(vehicleId);
      
      // Load trend data
      _fuelConsumptionTrend = await _reportingService.getFuelConsumptionTrend(vehicleId);
      _costPerLiterTrend = await _reportingService.getCostPerLiterTrend(vehicleId);
      _expenseTrend = await _reportingService.getExpenseTrend(vehicleId);
      _expenseTypeDistribution = await _reportingService.getExpenseTypeDistribution(vehicleId);
    } catch (e) {
      // Handle error
      debugPrint('Error loading statistics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}