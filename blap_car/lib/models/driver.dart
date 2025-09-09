class Driver {
  int? id;
  String name;
  String? licenseNumber;
  DateTime? licenseExpiryDate;
  String? contactInfo;
  DateTime createdAt;

  Driver({
    this.id,
    required this.name,
    this.licenseNumber,
    this.licenseExpiryDate,
    this.contactInfo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'license_number': licenseNumber,
      'license_expiry_date': licenseExpiryDate?.toIso8601String(),
      'contact_info': contactInfo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'],
      name: map['name'],
      licenseNumber: map['license_number'],
      licenseExpiryDate: map['license_expiry_date'] != null ? DateTime.parse(map['license_expiry_date']) : null,
      contactInfo: map['contact_info'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}