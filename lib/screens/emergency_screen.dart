import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../l10n/app_localizations.dart';
import 'waiting_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(6.9271, 79.8612);
  bool _locationLoaded = false;
  int _selectedVehicle = 0;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  List<_AmbulanceType> _buildVehicles(AppLocalizations l) => [
    _AmbulanceType(
      name: l.basicAmbulance,
      icon: Icons.emergency_rounded,
      capacity: l.capacity2,
      price: 'LKR 3,500',
      stars: '98.4',
      color: const Color(0xFF2D3A8C),
    ),
    _AmbulanceType(
      name: l.advancedAmbulance,
      icon: Icons.local_hospital_rounded,
      capacity: l.capacity1,
      price: 'LKR 6,200',
      stars: '112.1',
      color: Colors.red,
    ),
    _AmbulanceType(
      name: l.icuAmbulance,
      icon: Icons.monitor_heart_rounded,
      capacity: l.capacity1,
      price: 'LKR 12,800',
      stars: '87.3',
      color: Colors.orange,
    ),
    _AmbulanceType(
      name: l.neonatalAmbulance,
      icon: Icons.child_care_rounded,
      capacity: l.capacityInfant,
      price: 'LKR 9,500',
      stars: '74.6',
      color: Colors.teal,
    ),
  ];

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
      _mapController.move(_currentLocation, 15);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicles = _buildVehicles(l);

    return Scaffold(
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
              onTap: () => Navigator.pop(context),
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
                  const SizedBox(height: 12),

                  // ── Vehicle selector ──────────────────────────
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vehicles.length,
                      itemBuilder: (context, i) {
                        final v = vehicles[i];
                        final selected = _selectedVehicle == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedVehicle = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 110,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF2D3A8C)
                                  : isDark
                                  ? const Color(0xFF2A2A2A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF2D3A8C)
                                    : Colors.grey.shade300,
                                width: selected ? 2 : 1,
                              ),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF2D3A8C,
                                        ).withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  v.icon,
                                  size: 28,
                                  color: selected ? Colors.white : v.color,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  v.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: selected
                                        ? Colors.white
                                        : isDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  v.capacity,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: selected
                                        ? Colors.white70
                                        : Colors.grey,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  v.price,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF2D3A8C),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 11,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      v.stars,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: selected
                                            ? Colors.white70
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Book Now button ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => _confirmBooking(context, l, vehicles),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3A8C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l.requestAmbulance(vehicles[_selectedVehicle].name),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking(
    BuildContext context,
    AppLocalizations l,
    List<_AmbulanceType> vehicles,
  ) {
    final v = vehicles[_selectedVehicle];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.emergency_rounded, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text(
              l.confirmRequest,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.ambulanceType(v.name)),
            Text(l.price(v.price)),
            const SizedBox(height: 8),
            Text(
              l.dispatchMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitRequest(context, l, v);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3A8C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRequest(
    BuildContext context,
    AppLocalizations l,
    _AmbulanceType v,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final doc = await FirebaseFirestore.instance
          .collection('emergency_requests')
          .add({
            'uid': user?.uid,
            'patientName': user?.displayName ?? user?.email ?? 'Patient',
            'ambulanceType': v.name,
            'price': v.price,
            'latitude': _currentLocation.latitude,
            'longitude': _currentLocation.longitude,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          });
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                WaitingScreen(requestId: doc.id, ambulanceType: v.name),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

// ── Ambulance type model ──────────────────────────────────────────────────────

class _AmbulanceType {
  final String name;
  final IconData icon;
  final String capacity;
  final String price;
  final String stars;
  final Color color;

  const _AmbulanceType({
    required this.name,
    required this.icon,
    required this.capacity,
    required this.price,
    required this.stars,
    required this.color,
  });
}
