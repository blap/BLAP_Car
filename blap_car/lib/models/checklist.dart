class Checklist {
  int? id;
  String name;
  String? description;
  DateTime createdAt;
  DateTime? updatedAt;

  Checklist({
    this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Checklist.fromMap(Map<String, dynamic> map) {
    return Checklist(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }
}

class ChecklistItem {
  int? id;
  int checklistId;
  String name;
  String? description;
  bool isRequired;
  DateTime createdAt;

  ChecklistItem({
    this.id,
    required this.checklistId,
    required this.name,
    this.description,
    required this.isRequired,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'checklist_id': checklistId,
      'name': name,
      'description': description,
      'is_required': isRequired ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'],
      checklistId: map['checklist_id'],
      name: map['name'],
      description: map['description'],
      isRequired: map['is_required'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class ChecklistCompletion {
  int? id;
  int checklistId;
  int vehicleId;
  DateTime completedAt;
  String? notes;

  ChecklistCompletion({
    this.id,
    required this.checklistId,
    required this.vehicleId,
    required this.completedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'checklist_id': checklistId,
      'vehicle_id': vehicleId,
      'completed_at': completedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory ChecklistCompletion.fromMap(Map<String, dynamic> map) {
    return ChecklistCompletion(
      id: map['id'],
      checklistId: map['checklist_id'],
      vehicleId: map['vehicle_id'],
      completedAt: DateTime.parse(map['completed_at']),
      notes: map['notes'],
    );
  }
}

class ChecklistItemCompletion {
  int? id;
  int checklistCompletionId;
  int checklistItemId;
  bool isCompleted;
  String? notes;
  DateTime? completedAt;

  ChecklistItemCompletion({
    this.id,
    required this.checklistCompletionId,
    required this.checklistItemId,
    required this.isCompleted,
    this.notes,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'checklist_completion_id': checklistCompletionId,
      'checklist_item_id': checklistItemId,
      'is_completed': isCompleted ? 1 : 0,
      'notes': notes,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory ChecklistItemCompletion.fromMap(Map<String, dynamic> map) {
    return ChecklistItemCompletion(
      id: map['id'],
      checklistCompletionId: map['checklist_completion_id'],
      checklistItemId: map['checklist_item_id'],
      isCompleted: map['is_completed'] == 1,
      notes: map['notes'],
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
    );
  }
}