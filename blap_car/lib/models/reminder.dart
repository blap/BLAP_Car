class Reminder {
  int? id;
  int vehicleId;
  String? type;
  String? description;
  DateTime? date;
  bool? completed;

  Reminder({
    this.id,
    required this.vehicleId,
    this.type,
    this.description,
    this.date,
    this.completed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'type': type,
      'description': description,
      'date': date?.toIso8601String(),
      'completed': completed == true ? 1 : 0,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      type: map['type'],
      description: map['description'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      completed: map['completed'] == 1,
    );
  }
}