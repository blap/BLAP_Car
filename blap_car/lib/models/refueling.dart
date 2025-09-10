class Refueling {
  int? id;
  int vehicleId;
  DateTime date;
  DateTime? time;
  double odometer;
  double? liters;
  double? pricePerLiter;
  double? totalCost;
  String? fuelType;
  String? station;
  bool? fullTank;
  bool? previousRefuelingMissing;
  // Removed driver field
  String? paymentMethod;
  String? observation;
  String? attachmentPath;

  Refueling({
    this.id,
    required this.vehicleId,
    required this.date,
    this.time,
    required this.odometer,
    this.liters,
    this.pricePerLiter,
    this.totalCost,
    this.fuelType,
    this.station,
    this.fullTank,
    this.previousRefuelingMissing,
    // Removed driver field
    this.paymentMethod,
    this.observation,
    this.attachmentPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'date': date.toIso8601String(),
      'time': time?.toIso8601String(),
      'odometer': odometer,
      'liters': liters,
      'price_per_liter': pricePerLiter,
      'total_cost': totalCost,
      'fuel_type': fuelType,
      'station': station,
      'full_tank': fullTank == true ? 1 : 0,
      'previous_refueling_missing': previousRefuelingMissing == true ? 1 : 0,
      // Removed driver field
      'payment_method': paymentMethod,
      'observation': observation,
      'attachment_path': attachmentPath,
    };
  }

  factory Refueling.fromMap(Map<String, dynamic> map) {
    return Refueling(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      date: DateTime.parse(map['date']),
      time: map['time'] != null ? DateTime.parse(map['time']) : null,
      odometer: map['odometer'],
      liters: map['liters'],
      pricePerLiter: map['price_per_liter'],
      totalCost: map['total_cost'],
      fuelType: map['fuel_type'],
      station: map['station'],
      fullTank: map['full_tank'] == 1,
      previousRefuelingMissing: map['previous_refueling_missing'] == 1,
      // Removed driver field
      paymentMethod: map['payment_method'],
      observation: map['observation'],
      attachmentPath: map['attachment_path'],
    );
  }
}