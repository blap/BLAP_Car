import 'package:blap_car/models/maintenance.dart';
import 'package:blap_car/database/maintenance_dao.dart';

class MaintenanceService {
  final MaintenanceDao _maintenanceDao = MaintenanceDao();

  // Get all maintenance records
  Future<List<Maintenance>> getAllMaintenances() async {
    return await _maintenanceDao.getAllMaintenances();
  }

  // Get maintenance records by vehicle id
  Future<List<Maintenance>> getMaintenancesByVehicleId(int vehicleId) async {
    return await _maintenanceDao.getMaintenancesByVehicleId(vehicleId);
  }

  // Get a maintenance record by id
  Future<Maintenance?> getMaintenanceById(int id) async {
    return await _maintenanceDao.getMaintenanceById(id);
  }

  // Add a new maintenance record
  Future<int> addMaintenance(Maintenance maintenance) async {
    return await _maintenanceDao.insertMaintenance(maintenance);
  }

  // Update a maintenance record
  Future<int> updateMaintenance(Maintenance maintenance) async {
    return await _maintenanceDao.updateMaintenance(maintenance);
  }

  // Delete a maintenance record
  Future<int> deleteMaintenance(int id) async {
    return await _maintenanceDao.deleteMaintenance(id);
  }
}