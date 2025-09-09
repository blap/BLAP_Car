import 'package:blap_car/models/refueling.dart';
import 'package:blap_car/database/refueling_dao.dart';

class RefuelingService {
  final RefuelingDao _refuelingDao = RefuelingDao();

  // Get all refuelings
  Future<List<Refueling>> getAllRefuelings() async {
    return await _refuelingDao.getAllRefuelings();
  }

  // Get refuelings by vehicle id
  Future<List<Refueling>> getRefuelingsByVehicleId(int vehicleId) async {
    return await _refuelingDao.getRefuelingsByVehicleId(vehicleId);
  }

  // Get a refueling by id
  Future<Refueling?> getRefuelingById(int id) async {
    return await _refuelingDao.getRefuelingById(id);
  }

  // Add a new refueling
  Future<int> addRefueling(Refueling refueling) async {
    return await _refuelingDao.insertRefueling(refueling);
  }

  // Update a refueling
  Future<int> updateRefueling(Refueling refueling) async {
    return await _refuelingDao.updateRefueling(refueling);
  }

  // Delete a refueling
  Future<int> deleteRefueling(int id) async {
    return await _refuelingDao.deleteRefueling(id);
  }
}