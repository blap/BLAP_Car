import 'package:blap_car/modules/base/base_provider.dart';
import 'package:blap_car/models/vehicle.dart';
import 'package:blap_car/services/vehicle_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VehicleState {
  final List<Vehicle> vehicles;
  final Vehicle? activeVehicle;
  
  VehicleState({required this.vehicles, this.activeVehicle});
}

class VehicleProvider extends BaseProvider {
  List<Vehicle> _vehicles = [];
  Vehicle? _activeVehicle;
  final VehicleService _vehicleService = VehicleService();

  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get activeVehicle => _activeVehicle;
  VehicleState get vehicleState => VehicleState(vehicles: _vehicles, activeVehicle: _activeVehicle);

  // Load all vehicles
  Future<void> loadVehicles() async {
    await executeAsync(() async {
      _vehicles = await _vehicleService.getAllVehicles();
      
      // Load the active vehicle from shared preferences
      if (_vehicles.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final activeVehicleId = prefs.getInt('active_vehicle_id');
        
        if (activeVehicleId != null) {
          _activeVehicle = _vehicles.firstWhere(
            (vehicle) => vehicle.id == activeVehicleId,
            orElse: () => _vehicles.first,
          );
        } else {
          // If no active vehicle is set, use the first one
          _activeVehicle = _vehicles.first;
        }
      } else {
        _activeVehicle = null;
      }
      
      return vehicleState;
    }, loadingMessage: 'Loading vehicles...');
  }

  // Set the active vehicle
  Future<void> setActiveVehicle(Vehicle vehicle) async {
    await executeAsync(() async {
      _activeVehicle = vehicle;
      
      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_vehicle_id', vehicle.id!);
      
      return vehicleState;
    }, loadingMessage: 'Setting active vehicle...');
  }

  // Add a new vehicle
  Future<void> addVehicle(Vehicle vehicle) async {
    await executeAsync(() async {
      final id = await _vehicleService.addVehicle(vehicle);
      vehicle.id = id;
      _vehicles.add(vehicle);
      
      // If this is the first vehicle, set it as active
      if (_vehicles.length == 1) {
        _activeVehicle = vehicle;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('active_vehicle_id', vehicle.id!);
      }
      
      return vehicleState;
    }, loadingMessage: 'Adding vehicle...');
  }

  // Update a vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    await executeAsync(() async {
      await _vehicleService.updateVehicle(vehicle);
      final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _vehicles[index] = vehicle;
      }
      
      return vehicleState;
    }, loadingMessage: 'Updating vehicle...');
  }

  // Delete a vehicle
  Future<void> deleteVehicle(int id) async {
    await executeAsync(() async {
      await _vehicleService.deleteVehicle(id);
      _vehicles.removeWhere((vehicle) => vehicle.id == id);
      
      // If we deleted the active vehicle, select another one
      if (_activeVehicle?.id == id) {
        if (_vehicles.isNotEmpty) {
          _activeVehicle = _vehicles.first;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('active_vehicle_id', _activeVehicle!.id!);
        } else {
          _activeVehicle = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('active_vehicle_id');
        }
      }
      
      return vehicleState;
    }, loadingMessage: 'Deleting vehicle...');
  }
}