class Maintenance {
  int? id;
  int vehicleId;
  String? type;
  String? description;
  double? cost;
  DateTime? date;
  DateTime? nextDate;
  int? odometer;
  String? status;

  Maintenance({
    this.id,
    required this.vehicleId,
    this.type,
    this.description,
    this.cost,
    this.date,
    this.nextDate,
    this.odometer,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'type': type,
      'description': description,
      'cost': cost,
      'date': date?.toIso8601String(),
      'next_date': nextDate?.toIso8601String(),
      'odometer': odometer,
      'status': status,
    };
  }

  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      type: map['type'],
      description: map['description'],
      cost: map['cost'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      nextDate: map['next_date'] != null ? DateTime.parse(map['next_date']) : null,
      odometer: map['odometer'],
      status: map['status'],
    );
  }
}