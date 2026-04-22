class AmbulanceVehicle {
  final String id;
  final String vehicleNumber;
  final String type; // Basic, Advanced, ICU, Neonatal
  final String status; // available, on_duty, maintenance
  final String? notes;

  const AmbulanceVehicle({
    required this.id,
    required this.vehicleNumber,
    required this.type,
    required this.status,
    this.notes,
  });

  factory AmbulanceVehicle.fromMap(String id, Map<String, dynamic> map) {
    return AmbulanceVehicle(
      id: id,
      vehicleNumber: map['vehicleNumber'] ?? '',
      type: map['type'] ?? 'Basic',
      status: map['status'] ?? 'available',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() => {
    'vehicleNumber': vehicleNumber,
    'type': type,
    'status': status,
    'notes': notes ?? '',
  };
}
