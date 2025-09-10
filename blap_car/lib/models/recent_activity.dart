class RecentActivity {
  final int id;
  final String type;
  final String description;
  final DateTime date;
  final double? cost;
  final String vehicleName;

  RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.date,
    this.cost,
    required this.vehicleName,
  });

  // Convert to map for display purposes
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'date': date.toIso8601String(),
      'cost': cost,
      'vehicleName': vehicleName,
    };
  }

  // Create from map (useful for testing)
  factory RecentActivity.fromMap(Map<String, dynamic> map) {
    return RecentActivity(
      id: map['id'] as int,
      type: map['type'] as String,
      description: map['description'] as String,
      date: DateTime.parse(map['date'] as String),
      cost: map['cost'] as double?,
      vehicleName: map['vehicleName'] as String,
    );
  }

  @override
  String toString() {
    return 'RecentActivity{id: $id, type: $type, description: $description, date: $date, cost: $cost, vehicleName: $vehicleName}';
  }
}