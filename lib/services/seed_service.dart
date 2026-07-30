import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  static Future<void> seedDummyHospitals() async {
    final hospitals = [
      {'name': 'Kandy General Hospital', 'latitude': 7.2906, 'longitude': 80.6337},
      {'name': 'Teaching Hospital Karapitiya (Galle)', 'latitude': 6.0535, 'longitude': 80.2210},
      {'name': 'Jaffna Teaching Hospital', 'latitude': 9.6615, 'longitude': 80.0255},
      {'name': 'Provincial General Hospital Badulla', 'latitude': 6.9934, 'longitude': 81.0550},
    ];

    final firestore = FirebaseFirestore.instance;
    for (var h in hospitals) {
      await firestore.collection('hospitals').add(h);
    }
  }
}
