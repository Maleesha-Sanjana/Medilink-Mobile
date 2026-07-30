import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../theme/theme_toggle_button.dart';
import '../../theme/language_toggle_button.dart';
import '../../l10n/app_localizations.dart';
import '../login_screen.dart';
import '../chat_screen.dart';
import '../patient_care_report_screen.dart';
import '../collect_payment_screen.dart';

class EmtDashboard extends StatefulWidget {
  const EmtDashboard({super.key});

  @override
  State<EmtDashboard> createState() => _EmtDashboardState();
}

class _EmtDashboardState extends State<EmtDashboard> {
  final MapController _mapController = MapController();
  static const LatLng _defaultCenter = LatLng(6.9271, 79.8612);

  String? _selectedRequestId;
  Timer? _locationTimer;
  Timer? _availabilityTimer;

  @override
  void initState() {
    super.initState();
    _startAvailabilityPublishing();
  }

  void _startAvailabilityPublishing() {
    _publishAvailability();
    _availabilityTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _publishAvailability();
    });
  }

  Future<void> _publishAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'lastLatitude': pos.latitude,
            'lastLongitude': pos.longitude,
            'lastOnlineAt': FieldValue.serverTimestamp(),
          });
    } catch (_) {}
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _availabilityTimer?.cancel();
    super.dispose();
  }

  void _focusRequest(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      _mapController.move(LatLng(lat, lng), 16);
      setState(() => _selectedRequestId = doc.id);
    }
  }

  Future<void> _acceptRequest(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    // Fetch EMT's profile to get name and phone
    String emtName = user?.displayName ?? user?.email ?? 'EMT';
    String emtPhone = '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();
      if (doc.exists) {
        emtName = doc.data()?['displayName'] ?? emtName;
        emtPhone = doc.data()?['phone'] ?? '';
      }
    } catch (_) {}

    await FirebaseFirestore.instance
        .collection('emergency_requests')
        .doc(docId)
        .update({
          'status': 'accepted',
          'emtUid': user?.uid,
          'emtName': emtName,
          'emtPhone': emtPhone,
        });
        
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_request_id', docId);
    
    // We also need the ambulance type if it's there
    try {
      final reqDoc = await FirebaseFirestore.instance.collection('emergency_requests').doc(docId).get();
      if (reqDoc.exists) {
        await prefs.setString('active_request_type', reqDoc.data()?['ambulanceType'] ?? 'Basic');
      }
    } catch (_) {}

    setState(() => _selectedRequestId = null);
    _startPublishingLocation(docId);
  }

  void _startPublishingLocation(String docId) {
    _locationTimer?.cancel();
    // Publish immediately, then every 5 seconds
    _publishLocation(docId);
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _publishLocation(docId);
    });
  }

  Future<void> _publishLocation(String docId) async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      await FirebaseFirestore.instance
          .collection('emergency_requests')
          .doc(docId)
          .update({
            'emtLat': pos.latitude,
            'emtLng': pos.longitude,
            'emtUpdatedAt': FieldValue.serverTimestamp(),
          });
    } catch (_) {}
  }

  Future<void> _rejectRequest(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('emergency_requests')
        .doc(docId)
        .update({
          'status': 'rejected',
          'rejectedBy': FieldValue.arrayUnion([user?.uid]),
        });
    setState(() => _selectedRequestId = null);
  }

  Future<void> _markArrived(String docId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection('emergency_requests')
        .doc(docId)
        .update({'status': 'arrived'});
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PatientCareReportScreen(
            requestId: docId,
            initialData: data,
          ),
        ),
      );
    }
  }

  Future<void> _showHandoverDialog(BuildContext context, String docId, Map<String, dynamic> data) async {
    final docCtrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arrived to Hospital'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the name of the receiving doctor or nurse:'),
            const SizedBox(height: 12),
            TextField(
              controller: docCtrl,
              decoration: const InputDecoration(
                labelText: 'Doctor/Nurse Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (docCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              
              final timestamp = DateTime.now();
              await FirebaseFirestore.instance.collection('emergency_requests').doc(docId).update({
                'handoverDoctor': docCtrl.text.trim(),
                'handoverTime': timestamp,
              });
              
              final updatedData = Map<String, dynamic>.from(data)
                ..['handoverDoctor'] = docCtrl.text.trim()
                ..['handoverTime'] = timestamp;

              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CollectPaymentScreen(
                      requestId: docId,
                      initialData: updatedData,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'STJ MediLink',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1A237E),
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: Text(
                  '\u207A',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          const ThemeToggleButton(),
          const LanguageToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l.signOut,
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergency_requests')
            .where('status', whereIn: ['accepted', 'transporting'])
            .where(
              'emtUid',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
            )
            .limit(1)
            .snapshots(),
        builder: (context, activeSnap) {
          final activeDocs = activeSnap.data?.docs ?? [];
          final bool hasActiveRequest = activeDocs.isNotEmpty;
          final doc = hasActiveRequest ? activeDocs.first : null;
          final data = hasActiveRequest ? doc!.data() as Map<String, dynamic> : null;

          return Column(
            children: [
              // ── Accepted request chat bar (if EMT has an active job) ──
              if (hasActiveRequest && doc != null && data != null)
                Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active Case: ${data['caseId'] ?? 'N/A'}\n${data['status'] == 'transporting' ? 'To Hospital' : 'Patient: ${data['patientName'] ?? 'Patient'}'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    // Map button
                    _ActionChip(
                      icon: Icons.directions_rounded,
                      label: 'Map',
                      color: Colors.blue,
                      onTap: () async {
                        final isTransporting = data['status'] == 'transporting';
                        final lat = isTransporting ? (data['destinationLat'] as num?)?.toDouble() : (data['latitude'] as num?)?.toDouble();
                        final lng = isTransporting ? (data['destinationLng'] as num?)?.toDouble() : (data['longitude'] as num?)?.toDouble();
                        if (lat != null && lng != null) {
                          final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    // Chat button
                    _ActionChip(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chat',
                      color: const Color(0xFF2D3A8C),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            requestId: doc.id,
                            myName: data['emtName'] ?? 'EMT',
                            isEmt: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Arrived/Handover button
                    _ActionChip(
                      icon: data['status'] == 'transporting' ? Icons.local_hospital_rounded : Icons.location_on,
                      label: data['status'] == 'transporting' ? 'Arrived to Hosp' : 'Arrived',
                      color: data['status'] == 'transporting' ? Colors.green : Colors.orange.shade700,
                      onTap: () => data['status'] == 'transporting' 
                          ? _showHandoverDialog(context, doc.id, data)
                          : _markArrived(doc.id, data),
                    ),
                  ],
                ),
              ),
              // ── Main map body ──────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('emergency_requests')
                  .where('status', isEqualTo: 'assigned')
                  .where('assignedEmtUid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                // Show errors so we can debug
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Error loading requests:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Sort client-side by createdAt descending (avoids composite index)
                final docs = hasActiveRequest ? <DocumentSnapshot>[] : [...(snapshot.data?.docs ?? [])];
                docs.sort((a, b) {
                  final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
                  final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
                  if (aTs == null && bTs == null) return 0;
                  if (aTs == null) return 1;
                  if (bTs == null) return -1;
                  return bTs.compareTo(aTs);
                });

                // Auto-pan to the first request when it arrives
                if (docs.isNotEmpty && _selectedRequestId == null) {
                  final first = docs.first.data() as Map<String, dynamic>;
                  final lat = (first['latitude'] as num?)?.toDouble();
                  final lng = (first['longitude'] as num?)?.toDouble();
                  if (lat != null && lng != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _mapController.move(LatLng(lat, lng), 15);
                    });
                  }
                }

                // Build markers from pending requests
                final markers = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final lat = (data['latitude'] as num?)?.toDouble() ?? 0;
                  final lng = (data['longitude'] as num?)?.toDouble() ?? 0;
                  final isSelected = doc.id == _selectedRequestId;
                  return Marker(
                    point: LatLng(lat, lng),
                    width: isSelected ? 60 : 48,
                    height: isSelected ? 60 : 48,
                    child: GestureDetector(
                      onTap: () => _focusRequest(doc),
                      child: _PatientMarker(isSelected: isSelected),
                    ),
                  );
                }).toList();

                return Stack(
                  children: [
                    // ── Full-screen map ─────────────────────────────
                    FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: _defaultCenter,
                        initialZoom: 13,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.stj.stj_medilink_plus',
                        ),
                        MarkerLayer(markers: markers),
                      ],
                    ),

                    // ── No requests overlay ─────────────────────────
                    if (docs.isEmpty && !hasActiveRequest)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emergency_rounded,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l.welcomeDriver,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'No active emergency requests',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Request count badge ─────────────────────────
                    if (docs.isNotEmpty)
                      Positioned(
                        top: 12,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.emergency_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${docs.length} Emergency${docs.length > 1 ? ' Requests' : ' Request'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Requests list panel ─────────────────────────
                    if (docs.isNotEmpty)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 280),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A1A)
                                : Colors.white,
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // drag handle
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  12,
                                  16,
                                  8,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.emergency_rounded,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Active Requests',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  itemCount: docs.length,
                                  itemBuilder: (context, i) {
                                    final doc = docs[i];
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final isSelected =
                                        doc.id == _selectedRequestId;
                                    return _RequestCard(
                                      data: data,
                                      isSelected: isSelected,
                                      isDark: isDark,
                                      onTap: () => _focusRequest(doc),
                                      onAccept: () => _acceptRequest(doc.id),
                                      onReject: () => _rejectRequest(doc.id),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ), // closes Expanded (main map body)
        ],
      ); // closes Column (body)
        },
      ), // closes StreamBuilder
    );
  }
}

// ── Request card ──────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.data,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['patientName'] ?? 'Patient';
    final type = data['ambulanceType'] ?? 'EMT';
    final price = data['price'] ?? '';
    final ts = data['createdAt'] as Timestamp?;
    final timeStr = ts != null ? _formatTime(ts.toDate()) : 'Just now';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.red.withValues(alpha: 0.08)
              : isDark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Red pulsing dot
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency_rounded,
                color: Colors.red,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$type • $price',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Case ID: ${data['caseId'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  Text(
                    timeStr,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

// ── Patient location marker (red pulsing) ─────────────────────────────────────

class _PatientMarker extends StatefulWidget {
  final bool isSelected;
  const _PatientMarker({required this.isSelected});

  @override
  State<_PatientMarker> createState() => _PatientMarkerState();
}

class _PatientMarkerState extends State<_PatientMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 0.5,
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
          // Outer pulse ring
          Container(
            width: (widget.isSelected ? 56 : 44) * _anim.value,
            height: (widget.isSelected ? 56 : 44) * _anim.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(
                alpha: 0.18 * (1 - _anim.value + 0.4),
              ),
            ),
          ),
          // Inner dot
          Container(
            width: widget.isSelected ? 22 : 18,
            height: widget.isSelected ? 22 : 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action chip button ────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
