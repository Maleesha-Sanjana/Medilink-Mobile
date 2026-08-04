import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'emt_tracking_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(6.9271, 79.8612);
  bool _locationLoaded = false;
  
  String? _requestId;
  String _requestStatus = 'locating'; // 'locating', 'pending', 'assigned', 'accepted'
  Map<String, dynamic> _requestData = {};
  StreamSubscription<DocumentSnapshot>? _requestSub;
  bool _hasShownAccepted = false;
  bool _isReassigning = false;

  late AnimationController _rotateCtrl;
  
  // Hardcoded ambulance type for automatic dispatch
  final String _ambulanceType = 'Emergency Ambulance';
  final String _price = 'LKR 5,000';

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _getLocation();
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    _rotateCtrl.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _locationLoaded = true;
      });
      _mapController.move(_currentLocation, 15.0);
      
      // Once location is loaded, automatically submit the request
      _autoSubmitRequest();
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _autoSubmitRequest() async {
    setState(() => _requestStatus = 'creating');
    try {
      final user = FirebaseAuth.instance.currentUser;
      final caseId = 'CASE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-${Random().nextInt(9999).toString().padLeft(4, '0')}';
      
      String? assignedEmtUid = await _getNearestAvailableEmt();

      final doc = await FirebaseFirestore.instance
          .collection('emergency_requests')
          .add({
            'caseId': caseId,
            'uid': user?.uid,
            'patientName': user?.displayName ?? user?.email ?? 'Patient',
            'ambulanceType': _ambulanceType,
            'price': _price,
            'latitude': _currentLocation.latitude,
            'longitude': _currentLocation.longitude,
            'status': assignedEmtUid != null ? 'assigned' : 'pending',
            'assignedEmtUid': assignedEmtUid,
            'rejectedBy': [],
            'createdAt': FieldValue.serverTimestamp(),
          });
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_request_id', doc.id);
      await prefs.setString('active_request_type', _ambulanceType);

      if (!mounted) return;
      
      _requestId = doc.id;
      _listenToRequest();
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _listenToRequest() {
    if (_requestId == null) return;
    
    _requestSub = FirebaseFirestore.instance
        .collection('emergency_requests')
        .doc(_requestId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final data = snapshot.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'pending';

      if (mounted) {
        setState(() {
          _requestData = data;
          _requestStatus = status;
        });
      }

      // Auto-navigate when accepted
      if (status == 'accepted' && !_hasShownAccepted) {
        _hasShownAccepted = true;
        _showAcceptedAndPop();
      } else if (status == 'rejected') {
        _reassignEmt(data);
      }
    });
  }

  Future<String?> _getNearestAvailableEmt({List<dynamic> rejectedBy = const []}) async {
    final tenMinsAgo = DateTime.now().subtract(const Duration(minutes: 10));
    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'emt')
        .get();

    List<Map<String, dynamic>> availableEmts = [];
    for (var doc in usersSnap.docs) {
      if (rejectedBy.contains(doc.id)) continue;
      
      final data = doc.data();
      final lastOnline = data['lastOnlineAt'] as Timestamp?;
      if (lastOnline == null || lastOnline.toDate().isBefore(tenMinsAgo)) continue;
      
      final lat = data['lastLatitude'] as double?;
      final lng = data['lastLongitude'] as double?;
      if (lat == null || lng == null) continue;

      // Check if EMT is currently active on a trip
      final activeTripSnap = await FirebaseFirestore.instance
          .collection('emergency_requests')
          .where('emtUid', isEqualTo: doc.id)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();
      if (activeTripSnap.docs.isNotEmpty) continue;

      availableEmts.add({
        'uid': doc.id,
        'lat': lat,
        'lng': lng,
      });
    }

    if (availableEmts.isEmpty) return null;

    final distance = const Distance();
    availableEmts.sort((a, b) {
      final distA = distance.as(
        LengthUnit.Meter,
        _currentLocation,
        LatLng(a['lat'], a['lng']),
      );
      final distB = distance.as(
        LengthUnit.Meter,
        _currentLocation,
        LatLng(b['lat'], b['lng']),
      );
      return distA.compareTo(distB);
    });

    return availableEmts.first['uid'] as String;
  }

  Future<void> _reassignEmt(Map<String, dynamic> data) async {
    if (_isReassigning || _requestId == null) return;
    _isReassigning = true;
    
    try {
      final rejectedBy = data['rejectedBy'] as List<dynamic>? ?? [];
      String? nextEmtUid = await _getNearestAvailableEmt(rejectedBy: rejectedBy);

      await FirebaseFirestore.instance
          .collection('emergency_requests')
          .doc(_requestId)
          .update({
            'status': nextEmtUid != null ? 'assigned' : 'pending',
            'assignedEmtUid': nextEmtUid,
          });
    } finally {
      _isReassigning = false;
    }
  }

  Future<void> _cancelRequest() async {
    if (_requestId != null) {
      await FirebaseFirestore.instance
          .collection('emergency_requests')
          .doc(_requestId)
          .update({'status': 'cancelled'});
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // prevent accidental back-swipe during emergency
      child: Scaffold(
        body: Stack(
          children: [
            // ── Full screen map ───────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.stj.stj_medilink_plus',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation,
                      width: 48,
                      height: 48,
                      child: const _PulsingMarker(),
                    ),
                  ],
                ),
              ],
            ),

            // ── Back button ───────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: _MapButton(
                onTap: _cancelRequest,
                child: const Icon(Icons.arrow_back, size: 20),
              ),
            ),

            // ── Your location chip ────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3A8C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _locationLoaded ? l.yourLocation : l.locating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Recenter button ───────────────────────────────────
            Positioned(
              bottom: 300,
              right: 16,
              child: _MapButton(
                onTap: () => _mapController.move(_currentLocation, 15),
                child: const Icon(
                  Icons.my_location_rounded,
                  size: 20,
                  color: Color(0xFF2D3A8C),
                ),
              ),
            ),

            // ── Bottom sheet ──────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Title ─────────────────────────────────
                      Text(
                        'Help is on the way!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      Text(
                        'Your $_ambulanceType request has been sent.\nWaiting for an EMT to accept…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Spinning loader ───────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RotationTransition(
                            turns: _rotateCtrl,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red.shade400,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _requestStatus == 'locating' ? 'Locating...' : 'Searching for nearby EMTs…',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Request info card ─────────────────────
                      if (_requestId != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F6FA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.local_hospital_rounded,
                                  color: Colors.red,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _ambulanceType,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Case ID: ${_requestData['caseId'] ?? 'Generating...'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white70 : Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _requestStatus.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.orange.shade700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // ── Cancel button ─────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _cancelRequest,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel Request',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAcceptedAndPop() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5E9),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'EMT Accepted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'An EMT has accepted your request and is on the way to your location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // close dialog
                
                if (mounted && _requestId != null) {
                  // Replace waiting screen with live tracking screen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => EmtTrackingScreen(
                        requestId: _requestId!,
                        ambulanceType: _ambulanceType,
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Track EMT',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing marker ────────────────────────────────────────────────────────────

class _PulsingMarker extends StatefulWidget {
  const _PulsingMarker();

  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40 * _anim.value,
            height: 40 * _anim.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2D3A8C).withValues(alpha: 0.2),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2D3A8C),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map button ────────────────────────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _MapButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
