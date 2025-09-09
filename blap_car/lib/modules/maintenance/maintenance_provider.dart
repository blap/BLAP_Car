import 'package:flutter/foundation.dart';
import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/services/maintenance_service.dart';

class MaintenanceProvider with ChangeNotifier {
  List<Maintenance> _maintenances = [];
  final MaintenanceService _maintenanceService = MaintenanceService();

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
}