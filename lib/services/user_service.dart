import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  // ── Create user doc on signup (default role: patient) ────────────────────
  Future<void> createUser({
    required String uid,
    required String email,
    String? phone,
    String role = 'patient',
    String? displayName,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'role': role,
      'phone': phone ?? '',
      'displayName': displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Fetch single user ─────────────────────────────────────────────────────
  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(uid, doc.data()!);
  }

  // ── Update user details ───────────────────────────────────────────────────
  Future<void> updateUser(
    String uid, {
    String? displayName,
    String? phone,
    String? email,
    String? role,
  }) async {
    final data = <String, dynamic>{};
    if (displayName != null) data['displayName'] = displayName;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (role != null) data['role'] = role;
    await _db.collection('users').doc(uid).update(data);
  }

  // ── Delete user doc ───────────────────────────────────────────────────────
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // ── Stream all users by role ──────────────────────────────────────────────
  Stream<List<AppUser>> streamUsersByRole(String role) {
    return _db
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList(),
        );
  }
}
