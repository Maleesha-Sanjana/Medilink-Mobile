import 'package:cloud_firestore/cloud_firestore.dart';

class Hospital {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;
  final List<String> features;

  const Hospital({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.features = const [],
  });

  factory Hospital.fromMap(String id, Map<String, dynamic> data) {
    return Hospital(
      id: id,
      name: data['name'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      features: List<String>.from(data['features'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'features': features,
    };
  }
}
