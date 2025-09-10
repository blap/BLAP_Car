class Expense {
  int? id;
  int vehicleId;
  String? type;
  String? description;
  double? cost;
  DateTime date;
  DateTime? time;
  double? odometer;
  String? location;
  // Removed driver field
  String? paymentMethod;
  String? observation;
  String? attachmentPath;
  String? category;

  Expense({
    this.id,
    required this.vehicleId,
    this.type,
    this.description,
    this.cost,
    required this.date,
    this.time,
    this.odometer,
    this.location,
    // Removed driver parameter
    this.paymentMethod,
    this.observation,
    this.attachmentPath,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'type': type,
      'description': description,
      'cost': cost,
      'date': date.toIso8601String(),
      'time': time?.toIso8601String(),
      'odometer': odometer,
      'location': location,
      // Removed driver from map
      'payment_method': paymentMethod,
      'observation': observation,
      'attachment_path': attachmentPath,
      'category': category,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      type: map['type'],
      description: map['description'],
      cost: map['cost'],
      date: DateTime.parse(map['date']),
      time: map['time'] != null ? DateTime.parse(map['time']) : null,
      odometer: map['odometer'],
      location: map['location'],
      // Removed driver from map
      paymentMethod: map['payment_method'],
      observation: map['observation'],
      attachmentPath: map['attachment_path'],
      category: map['category'],
    );
  }
}