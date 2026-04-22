class Driver {
  final String id;
  final String name;
  final String phone;
  final String licenseNumber;
  final String? assignedVehicle;
  final String? notes;

  const Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.licenseNumber,
    this.assignedVehicle,
    this.notes,
  });

  factory Driver.fromMap(String id, Map<String, dynamic> map) => Driver(
    id: id,
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    licenseNumber: map['licenseNumber'] ?? '',
    assignedVehicle: map['assignedVehicle'],
    notes: map['notes'],
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'licenseNumber': licenseNumber,
    'assignedVehicle': assignedVehicle ?? '',
    'notes': notes ?? '',
  };
}
