import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Manages Agora call signaling via Firestore.
/// Call state is stored in emergency_requests/{requestId} document.
class AgoraService {
  static const String appId = '60d848bb90b5455cae96bba15e98835f';

  // ── TESTING MODE ──────────────────────────────────────────────────────────
  // Temp token is tied to channel name 'test'.
  // All calls use channel 'test' during development.
  // Replace with a token server before going to production.
  static const String _tempToken =
      '007eJxTYAhiCpOdb6b969TST8FP7QPlr0lJXVm/4hx/+MN8e02e7ewKDGYGKRYmFklJlgZJpiampsmJqZZmSUmJhqaplhYWxqZp17++ymwIZGQo12llZWSAQBCfhaEktbiEgQEA5KwevA==';
  static const String testChannel = 'test';

  static String get token => _tempToken;
  // ─────────────────────────────────────────────────────────────────────────

  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  DocumentReference _callRef(String requestId) =>
      _db.collection('emergency_requests').doc(requestId);

  /// Initiate a call
  Future<void> initiateCall({
    required String requestId,
    required String callerName,
    required bool callerIsEmt,
  }) async {
    await _callRef(requestId).update({
      'callState': 'ringing',
      'callInitiatedBy': _uid,
      'callerName': callerName,
      'callerIsEmt': callerIsEmt,
      'callStartedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Accept the incoming call
  Future<void> acceptCall(String requestId) async {
    await _callRef(requestId).update({'callState': 'active'});
  }

  /// End / decline the call
  Future<void> endCall(String requestId) async {
    await _callRef(requestId).update({
      'callState': 'ended',
      'callEndedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream of call state changes for this request
  Stream<Map<String, dynamic>> callStateStream(String requestId) {
    return _callRef(requestId).snapshots().map((snap) {
      final data = snap.data() as Map<String, dynamic>? ?? {};
      return {
        'callState': data['callState'] ?? 'idle',
        'callerName': data['callerName'] ?? '',
        'callerIsEmt': data['callerIsEmt'] ?? false,
        'callInitiatedBy': data['callInitiatedBy'] ?? '',
      };
    });
  }
}
