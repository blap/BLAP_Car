class Vehicle {
  int? id;
  String name;
  String? make;
  String? model;
  int? year;
  String? plate;
  double? fuelTankVolume;
  String? vin;
  String? renavam;
  double? initialOdometer;
  DateTime createdAt;

  Vehicle({
    this.id,
    required this.name,
    this.make,
    this.model,
    this.year,
    this.plate,
    this.fuelTankVolume,
    this.vin,
    this.renavam,
    this.initialOdometer,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'plate': plate,
      'fuel_tank_volume': fuelTankVolume,
      'vin': vin,
      'renavam': renavam,
      'initial_odometer': initialOdometer,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      name: map['name'],
      make: map['make'],
      model: map['model'],
      year: map['year'],
      plate: map['plate'],
      fuelTankVolume: map['fuel_tank_volume'],
      vin: map['vin'],
      renavam: map['renavam'],
      initialOdometer: map['initial_odometer'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}