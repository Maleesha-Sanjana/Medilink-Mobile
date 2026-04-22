import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ambulance_vehicle.dart';

class VehicleService {
  final _db = FirebaseFirestore.instance;
  CollectionReference get _col => _db.collection('vehicles');

  Stream<List<AmbulanceVehicle>> streamVehicles() {
    return _col.snapshots().map(
      (snap) => snap.docs
          .map(
            (d) => AmbulanceVehicle.fromMap(
              d.id,
              d.data() as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  Future<void> createVehicle(AmbulanceVehicle v) async {
    await _col.add({...v.toMap(), 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateVehicle(String id, Map<String, dynamic> data) async {
    await _col.doc(id).update(data);
  }

  Future<void> deleteVehicle(String id) async {
    await _col.doc(id).delete();
  }
}
