import 'package:flutter/foundation.dart';
import 'package:blap_car/models/checklist.dart';
import 'package:blap_car/services/checklist_service.dart';

class ChecklistProvider with ChangeNotifier {
  final ChecklistService _checklistService = ChecklistService();
  
  List<Checklist> _checklists = [];
  List<ChecklistItem> _checklistItems = [];
  List<ChecklistCompletion> _completions = [];
  List<ChecklistItemCompletion> _itemCompletions = [];
  
  List<Checklist> get checklists => _checklists;
  List<ChecklistItem> get checklistItems => _checklistItems;
  List<ChecklistCompletion> get completions => _completions;
  List<ChecklistItemCompletion> get itemCompletions => _itemCompletions;

  // Load all checklists
  Future<void> loadChecklists() async {
    _checklists = await _checklistService.getAllChecklists();
    notifyListeners();
  }

  // Add a new checklist
  Future<void> addChecklist(Checklist checklist) async {
    final id = await _checklistService.addChecklist(checklist);
    checklist.id = id;
    _checklists.add(checklist);
    notifyListeners();
  }

  // Update a checklist
  Future<void> updateChecklist(Checklist checklist) async {
    await _checklistService.updateChecklist(checklist);
    final index = _checklists.indexWhere((c) => c.id == checklist.id);
    if (index != -1) {
      _checklists[index] = checklist;
      notifyListeners();
    }
  }

  // Delete a checklist
  Future<void> deleteChecklist(int id) async {
    await _checklistService.deleteChecklist(id);
    _checklists.removeWhere((checklist) => checklist.id == id);
    notifyListeners();
  }

  // Load checklist items for a checklist
  Future<void> loadChecklistItems(int checklistId) async {
    _checklistItems = await _checklistService.getChecklistItemsByChecklistId(checklistId);
    notifyListeners();
  }

  // Add a new checklist item
  Future<void> addChecklistItem(ChecklistItem item) async {
    final id = await _checklistService.addChecklistItem(item);
    item.id = id;
    _checklistItems.add(item);
    notifyListeners();
  }

  // Update a checklist item
  Future<void> updateChecklistItem(ChecklistItem item) async {
    await _checklistService.updateChecklistItem(item);
    final index = _checklistItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _checklistItems[index] = item;
      notifyListeners();
    }
  }

  // Delete a checklist item
  Future<void> deleteChecklistItem(int id) async {
    await _checklistService.deleteChecklistItem(id);
    _checklistItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Load completions for a vehicle
  Future<void> loadCompletions(int vehicleId) async {
    _completions = await _checklistService.getChecklistCompletionsByVehicleId(vehicleId);
    notifyListeners();
  }

  // Add a new completion
  Future<int> addCompletion(ChecklistCompletion completion) async {
    final id = await _checklistService.addChecklistCompletion(completion);
    completion.id = id;
    _completions.add(completion);
    notifyListeners();
    return id;
  }

  // Load item completions for a completion
  Future<void> loadItemCompletions(int completionId) async {
    _itemCompletions = await _checklistService.getChecklistItemCompletionsByCompletionId(completionId);
    notifyListeners();
  }

  // Add a new item completion
  Future<void> addItemCompletion(ChecklistItemCompletion itemCompletion) async {
    final id = await _checklistService.addChecklistItemCompletion(itemCompletion);
    itemCompletion.id = id;
    _itemCompletions.add(itemCompletion);
    notifyListeners();
  }

  // Update an item completion
  Future<void> updateItemCompletion(ChecklistItemCompletion itemCompletion) async {
    await _checklistService.updateChecklistItemCompletion(itemCompletion);
    final index = _itemCompletions.indexWhere((i) => i.id == itemCompletion.id);
    if (index != -1) {
      _itemCompletions[index] = itemCompletion;
      notifyListeners();
    }
  }
}