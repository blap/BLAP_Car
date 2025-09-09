import 'package:blap_car/models/checklist.dart';
import 'package:blap_car/database/checklist_dao.dart';

class ChecklistService {
  final ChecklistDao _checklistDao = ChecklistDao();

  // Checklist methods
  Future<List<Checklist>> getAllChecklists() async {
    return await _checklistDao.getAllChecklists();
  }

  Future<Checklist?> getChecklistById(int id) async {
    return await _checklistDao.getChecklistById(id);
  }

  Future<int> addChecklist(Checklist checklist) async {
    return await _checklistDao.insertChecklist(checklist);
  }

  Future<int> updateChecklist(Checklist checklist) async {
    return await _checklistDao.updateChecklist(checklist);
  }

  Future<int> deleteChecklist(int id) async {
    return await _checklistDao.deleteChecklist(id);
  }

  // ChecklistItem methods
  Future<List<ChecklistItem>> getChecklistItemsByChecklistId(int checklistId) async {
    return await _checklistDao.getChecklistItemsByChecklistId(checklistId);
  }

  Future<ChecklistItem?> getChecklistItemById(int id) async {
    return await _checklistDao.getChecklistItemById(id);
  }

  Future<int> addChecklistItem(ChecklistItem item) async {
    return await _checklistDao.insertChecklistItem(item);
  }

  Future<int> updateChecklistItem(ChecklistItem item) async {
    return await _checklistDao.updateChecklistItem(item);
  }

  Future<int> deleteChecklistItem(int id) async {
    return await _checklistDao.deleteChecklistItem(id);
  }

  // ChecklistCompletion methods
  Future<List<ChecklistCompletion>> getChecklistCompletionsByVehicleId(int vehicleId) async {
    return await _checklistDao.getChecklistCompletionsByVehicleId(vehicleId);
  }

  Future<ChecklistCompletion?> getChecklistCompletionById(int id) async {
    return await _checklistDao.getChecklistCompletionById(id);
  }

  Future<int> addChecklistCompletion(ChecklistCompletion completion) async {
    return await _checklistDao.insertChecklistCompletion(completion);
  }

  // ChecklistItemCompletion methods
  Future<List<ChecklistItemCompletion>> getChecklistItemCompletionsByCompletionId(int completionId) async {
    return await _checklistDao.getChecklistItemCompletionsByCompletionId(completionId);
  }

  Future<int> addChecklistItemCompletion(ChecklistItemCompletion itemCompletion) async {
    return await _checklistDao.insertChecklistItemCompletion(itemCompletion);
  }

  Future<int> updateChecklistItemCompletion(ChecklistItemCompletion itemCompletion) async {
    return await _checklistDao.updateChecklistItemCompletion(itemCompletion);
  }
}