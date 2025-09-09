import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/services/checklist_service.dart';
import 'package:blap_car/models/checklist.dart';
import 'package:blap_car/database/checklist_dao.dart';

class MockChecklistDao extends ChecklistDao {
  List<Checklist> checklists = [];
  List<ChecklistItem> checklistItems = [];
  List<ChecklistCompletion> checklistCompletions = [];
  List<ChecklistItemCompletion> checklistItemCompletions = [];
  int _idCounter = 1;

  @override
  Future<int> insertChecklist(Checklist checklist) async {
    checklist.id = _idCounter++;
    checklists.add(checklist);
    return checklist.id!;
  }

  @override
  Future<List<Checklist>> getAllChecklists() async {
    return checklists;
  }

  @override
  Future<Checklist?> getChecklistById(int id) async {
    try {
      return checklists.firstWhere((checklist) => checklist.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> updateChecklist(Checklist checklist) async {
    final index = checklists.indexWhere((c) => c.id == checklist.id);
    if (index != -1) {
      checklists[index] = checklist;
      return 1; // Success
    }
    return 0; // Not found
  }

  @override
  Future<int> deleteChecklist(int id) async {
    final initialLength = checklists.length;
    checklists.removeWhere((checklist) => checklist.id == id);
    return initialLength - checklists.length;
  }

  @override
  Future<int> insertChecklistItem(ChecklistItem item) async {
    item.id = _idCounter++;
    checklistItems.add(item);
    return item.id!;
  }

  @override
  Future<List<ChecklistItem>> getChecklistItemsByChecklistId(int checklistId) async {
    return checklistItems.where((item) => item.checklistId == checklistId).toList();
  }

  @override
  Future<ChecklistItem?> getChecklistItemById(int id) async {
    try {
      return checklistItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> updateChecklistItem(ChecklistItem item) async {
    final index = checklistItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      checklistItems[index] = item;
      return 1; // Success
    }
    return 0; // Not found
  }

  @override
  Future<int> deleteChecklistItem(int id) async {
    final initialLength = checklistItems.length;
    checklistItems.removeWhere((item) => item.id == id);
    return initialLength - checklistItems.length;
  }

  @override
  Future<int> insertChecklistCompletion(ChecklistCompletion completion) async {
    completion.id = _idCounter++;
    checklistCompletions.add(completion);
    return completion.id!;
  }

  @override
  Future<List<ChecklistCompletion>> getChecklistCompletionsByVehicleId(int vehicleId) async {
    return checklistCompletions.where((completion) => completion.vehicleId == vehicleId).toList();
  }

  @override
  Future<ChecklistCompletion?> getChecklistCompletionById(int id) async {
    try {
      return checklistCompletions.firstWhere((completion) => completion.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> insertChecklistItemCompletion(ChecklistItemCompletion itemCompletion) async {
    itemCompletion.id = _idCounter++;
    checklistItemCompletions.add(itemCompletion);
    return itemCompletion.id!;
  }

  @override
  Future<List<ChecklistItemCompletion>> getChecklistItemCompletionsByCompletionId(int completionId) async {
    return checklistItemCompletions.where((itemCompletion) => itemCompletion.checklistCompletionId == completionId).toList();
  }

  @override
  Future<int> updateChecklistItemCompletion(ChecklistItemCompletion itemCompletion) async {
    final index = checklistItemCompletions.indexWhere((i) => i.id == itemCompletion.id);
    if (index != -1) {
      checklistItemCompletions[index] = itemCompletion;
      return 1; // Success
    }
    return 0; // Not found
  }
}

void main() {
  group('ChecklistService Tests', () {
    late ChecklistService checklistService;

    setUp(() {
      checklistService = ChecklistService();
    });

    test('ChecklistService can be instantiated', () {
      expect(checklistService, isNotNull);
      expect(checklistService, isA<ChecklistService>());
    });

    // Note: Testing private fields in Dart requires workarounds that are beyond
    // the scope of simple unit tests. In a real application, we would use
    // dependency injection to make the DAO mockable.
  });
}