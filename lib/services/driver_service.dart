import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver.dart';

class DriverService {
  final _col = FirebaseFirestore.instance.collection('drivers');

  Stream<List<Driver>> streamDrivers() {
    return _col.snapshots().map(
      (snap) => snap.docs.map((d) => Driver.fromMap(d.id, d.data())).toList(),
    );
  }

  Future<void> createDriver(Driver d) async {
    await _col.add({...d.toMap(), 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateDriver(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  Future<void> deleteDriver(String id) async {
    await _col.doc(id).delete();
  }
}
