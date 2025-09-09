import 'package:flutter/foundation.dart';
import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/services/vehicle_service.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _vehicles = [];
  final VehicleService _vehicleService = VehicleService();

  List<Vehicle> get vehicles => _vehicles;

  // Load all vehicles
  Future<void> loadVehicles() async {
    _vehicles = await _vehicleService.getAllVehicles();
    notifyListeners();
  }

  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    final id = await _vehicleService.addVehicle(vehicle);
    vehicle.id = id;
    _vehicles.add(vehicle);
    notifyListeners();
  }

  // Update a vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _vehicleService.updateVehicle(vehicle);
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      notifyListeners();
    }
  }

  // Delete a vehicle
  Future<void> deleteVehicle(int id) async {
    await _vehicleService.deleteVehicle(id);
    _vehicles.removeWhere((vehicle) => vehicle.id == id);
    notifyListeners();
  }
}