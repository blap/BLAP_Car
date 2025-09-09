import 'package:flutter/foundation.dart';
import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/services/refueling_service.dart';

class RefuelingProvider with ChangeNotifier {
  List<Refueling> _refuelings = [];
  final RefuelingService _refuelingService = RefuelingService();

  List<Refueling> get refuelings => _refuelings;

  // Load all refuelings for a vehicle
  Future<void> loadRefuelings(int vehicleId) async {
    _refuelings = await _refuelingService.getRefuelingsByVehicleId(vehicleId);
    notifyListeners();
  }

  // Add a new refueling
  Future<void> addRefueling(Refueling refueling) async {
    final id = await _refuelingService.addRefueling(refueling);
    refueling.id = id;
    _refuelings.add(refueling);
    notifyListeners();
  }

  // Update a refueling
  Future<void> updateRefueling(Refueling refueling) async {
    await _refuelingService.updateRefueling(refueling);
    final index = _refuelings.indexWhere((r) => r.id == refueling.id);
    if (index != -1) {
      _refuelings[index] = refueling;
      notifyListeners();
    }
  }

  // Delete a refueling
  Future<void> deleteRefueling(int id) async {
    await _refuelingService.deleteRefueling(id);
    _refuelings.removeWhere((refueling) => refueling.id == id);
    notifyListeners();
  }
}