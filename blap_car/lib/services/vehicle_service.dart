import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/database/vehicle_dao.dart';

class VehicleService {
  final VehicleDao _vehicleDao = VehicleDao();

  // Get all vehicles
  Future<List<Vehicle>> getAllVehicles() async {
    return await _vehicleDao.getAllVehicles();
  }

  // Get a vehicle by id
  Future<Vehicle?> getVehicleById(int id) async {
    return await _vehicleDao.getVehicleById(id);
  }

  // Add a new vehicle
  Future<int> addVehicle(Vehicle vehicle) async {
    return await _vehicleDao.insertVehicle(vehicle);
  }

  // Update a vehicle
  Future<int> updateVehicle(Vehicle vehicle) async {
    return await _vehicleDao.updateVehicle(vehicle);
  }

  // Delete a vehicle
  Future<int> deleteVehicle(int id) async {
    return await _vehicleDao.deleteVehicle(id);
  }
}