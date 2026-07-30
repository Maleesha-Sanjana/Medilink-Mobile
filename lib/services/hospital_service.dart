import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital.dart';

class HospitalService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createHospital(Hospital hospital) async {
    await _firestore.collection('hospitals').add(hospital.toMap());
  }

  Future<void> updateHospital(String id, Map<String, dynamic> data) async {
    await _firestore.collection('hospitals').doc(id).update(data);
  }

  Future<void> deleteHospital(String id) async {
    await _firestore.collection('hospitals').doc(id).delete();
  }

  Stream<List<Hospital>> streamHospitals() {
    return _firestore
        .collection('hospitals')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Hospital.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<List<Hospital>> getHospitals() async {
    final snap = await _firestore.collection('hospitals').get();
    return snap.docs
        .map((doc) => Hospital.fromMap(doc.id, doc.data()))
        .toList();
  }
}
