import 'package:flutter_test/flutter_test.dart';
import 'package:blap_car/models/checklist.dart';

void main() {
  group('Checklist Model Tests', () {
    test('Checklist can be created with required fields', () {
      final createdAt = DateTime.now();
      final checklist = Checklist(
        name: 'Pre-trip Inspection',
        createdAt: createdAt,
      );

      expect(checklist.name, 'Pre-trip Inspection');
      expect(checklist.createdAt, createdAt);
    });

    test('Checklist can be created with all fields', () {
      final createdAt = DateTime.now();
      final updatedAt = DateTime.now().add(Duration(hours: 1));
      final checklist = Checklist(
        id: 1,
        name: 'Pre-trip Inspection',
        description: 'Checklist for pre-trip vehicle inspection',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(checklist.id, 1);
      expect(checklist.name, 'Pre-trip Inspection');
      expect(checklist.description, 'Checklist for pre-trip vehicle inspection');
      expect(checklist.createdAt, createdAt);
      expect(checklist.updatedAt, updatedAt);
    });

    test('Checklist can be converted to and from map', () {
      final createdAt = DateTime.now();
      final updatedAt = DateTime.now().add(Duration(hours: 1));
      final checklist = Checklist(
        id: 1,
        name: 'Pre-trip Inspection',
        description: 'Checklist for pre-trip vehicle inspection',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = checklist.toMap();
      final checklistFromMap = Checklist.fromMap(map);

      expect(checklistFromMap.id, checklist.id);
      expect(checklistFromMap.name, checklist.name);
      expect(checklistFromMap.description, checklist.description);
      expect(checklistFromMap.createdAt, checklist.createdAt);
      expect(checklistFromMap.updatedAt, checklist.updatedAt);
    });
  });

  group('ChecklistItem Model Tests', () {
    test('ChecklistItem can be created with required fields', () {
      final createdAt = DateTime.now();
      final item = ChecklistItem(
        checklistId: 1,
        name: 'Check engine oil',
        isRequired: true,
        createdAt: createdAt,
      );

      expect(item.checklistId, 1);
      expect(item.name, 'Check engine oil');
      expect(item.isRequired, true);
      expect(item.createdAt, createdAt);
    });

    test('ChecklistItem can be created with all fields', () {
      final createdAt = DateTime.now();
      final item = ChecklistItem(
        id: 1,
        checklistId: 1,
        name: 'Check engine oil',
        description: 'Check engine oil level and condition',
        isRequired: true,
        createdAt: createdAt,
      );

      expect(item.id, 1);
      expect(item.checklistId, 1);
      expect(item.name, 'Check engine oil');
      expect(item.description, 'Check engine oil level and condition');
      expect(item.isRequired, true);
      expect(item.createdAt, createdAt);
    });

    test('ChecklistItem can be converted to and from map', () {
      final createdAt = DateTime.now();
      final item = ChecklistItem(
        id: 1,
        checklistId: 1,
        name: 'Check engine oil',
        description: 'Check engine oil level and condition',
        isRequired: true,
        createdAt: createdAt,
      );

      final map = item.toMap();
      final itemFromMap = ChecklistItem.fromMap(map);

      expect(itemFromMap.id, item.id);
      expect(itemFromMap.checklistId, item.checklistId);
      expect(itemFromMap.name, item.name);
      expect(itemFromMap.description, item.description);
      expect(itemFromMap.isRequired, item.isRequired);
      expect(itemFromMap.createdAt, item.createdAt);
    });
  });

  group('ChecklistCompletion Model Tests', () {
    test('ChecklistCompletion can be created with required fields', () {
      final completedAt = DateTime.now();
      final completion = ChecklistCompletion(
        checklistId: 1,
        vehicleId: 1,
        completedAt: completedAt,
      );

      expect(completion.checklistId, 1);
      expect(completion.vehicleId, 1);
      expect(completion.completedAt, completedAt);
    });

    test('ChecklistCompletion can be created with all fields', () {
      final completedAt = DateTime.now();
      final completion = ChecklistCompletion(
        id: 1,
        checklistId: 1,
        vehicleId: 1,
        completedAt: completedAt,
        notes: 'All items checked and completed',
      );

      expect(completion.id, 1);
      expect(completion.checklistId, 1);
      expect(completion.vehicleId, 1);
      expect(completion.completedAt, completedAt);
      expect(completion.notes, 'All items checked and completed');
    });

    test('ChecklistCompletion can be converted to and from map', () {
      final completedAt = DateTime.now();
      final completion = ChecklistCompletion(
        id: 1,
        checklistId: 1,
        vehicleId: 1,
        completedAt: completedAt,
        notes: 'All items checked and completed',
      );

      final map = completion.toMap();
      final completionFromMap = ChecklistCompletion.fromMap(map);

      expect(completionFromMap.id, completion.id);
      expect(completionFromMap.checklistId, completion.checklistId);
      expect(completionFromMap.vehicleId, completion.vehicleId);
      expect(completionFromMap.completedAt, completion.completedAt);
      expect(completionFromMap.notes, completion.notes);
    });
  });

  group('ChecklistItemCompletion Model Tests', () {
    test('ChecklistItemCompletion can be created with required fields', () {
      final itemCompletion = ChecklistItemCompletion(
        checklistCompletionId: 1,
        checklistItemId: 1,
        isCompleted: true,
      );

      expect(itemCompletion.checklistCompletionId, 1);
      expect(itemCompletion.checklistItemId, 1);
      expect(itemCompletion.isCompleted, true);
    });

    test('ChecklistItemCompletion can be created with all fields', () {
      final completedAt = DateTime.now();
      final itemCompletion = ChecklistItemCompletion(
        id: 1,
        checklistCompletionId: 1,
        checklistItemId: 1,
        isCompleted: true,
        notes: 'Item completed successfully',
        completedAt: completedAt,
      );

      expect(itemCompletion.id, 1);
      expect(itemCompletion.checklistCompletionId, 1);
      expect(itemCompletion.checklistItemId, 1);
      expect(itemCompletion.isCompleted, true);
      expect(itemCompletion.notes, 'Item completed successfully');
      expect(itemCompletion.completedAt, completedAt);
    });

    test('ChecklistItemCompletion can be converted to and from map', () {
      final completedAt = DateTime.now();
      final itemCompletion = ChecklistItemCompletion(
        id: 1,
        checklistCompletionId: 1,
        checklistItemId: 1,
        isCompleted: true,
        notes: 'Item completed successfully',
        completedAt: completedAt,
      );

      final map = itemCompletion.toMap();
      final itemCompletionFromMap = ChecklistItemCompletion.fromMap(map);

      expect(itemCompletionFromMap.id, itemCompletion.id);
      expect(itemCompletionFromMap.checklistCompletionId, itemCompletion.checklistCompletionId);
      expect(itemCompletionFromMap.checklistItemId, itemCompletion.checklistItemId);
      expect(itemCompletionFromMap.isCompleted, itemCompletion.isCompleted);
      expect(itemCompletionFromMap.notes, itemCompletion.notes);
      expect(itemCompletionFromMap.completedAt, itemCompletion.completedAt);
    });
  });
}