import 'package:flutter/foundation.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/services/maintenance_service.dart';
import 'package:blap_car/services/maintenance_scheduling_service.dart';

class MaintenanceProvider with ChangeNotifier {
  List<Maintenance> _maintenances = [];
  final MaintenanceService _maintenanceService = MaintenanceService();
  final MaintenanceSchedulingService _schedulingService = MaintenanceSchedulingService();

  List<Maintenance> get maintenances => _maintenances;

  // Load all maintenance records for a vehicle
  Future<void> loadMaintenances(int vehicleId) async {
    _maintenances = await _maintenanceService.getMaintenancesByVehicleId(vehicleId);
    notifyListeners();
  }

  // Add a new maintenance record
  Future<void> addMaintenance(Maintenance maintenance) async {
    final id = await _maintenanceService.addMaintenance(maintenance);
    maintenance.id = id;
    _maintenances.add(maintenance);
    notifyListeners();
  }

  // Update a maintenance record
  Future<void> updateMaintenance(Maintenance maintenance) async {
    await _maintenanceService.updateMaintenance(maintenance);
    final index = _maintenances.indexWhere((m) => m.id == maintenance.id);
    if (index != -1) {
      _maintenances[index] = maintenance;
      notifyListeners();
    }
  }

  // Delete a maintenance record
  Future<void> deleteMaintenance(int id) async {
    await _maintenanceService.deleteMaintenance(id);
    _maintenances.removeWhere((maintenance) => maintenance.id == id);
    notifyListeners();
  }

  // Get upcoming maintenances for a vehicle
  Future<List<Maintenance>> getUpcomingMaintenances(int vehicleId, {int days = 30}) async {
    return await _schedulingService.getUpcomingMaintenances(vehicleId, days: days);
  }

  // Get overdue maintenances for a vehicle
  Future<List<Maintenance>> getOverdueMaintenances(int vehicleId) async {
    return await _schedulingService.getOverdueMaintenances(vehicleId);
  }

  // Suggest next maintenance based on vehicle history
  Future<Maintenance?> suggestNextMaintenance(int vehicleId) async {
    return await _schedulingService.suggestNextMaintenance(vehicleId);
  }

  // Automatically schedule maintenance based on intervals
  Future<void> autoScheduleMaintenance(int vehicleId) async {
    await _schedulingService.autoScheduleMaintenance(vehicleId);
    // Reload maintenances after auto-scheduling
    await loadMaintenances(vehicleId);
  }
}