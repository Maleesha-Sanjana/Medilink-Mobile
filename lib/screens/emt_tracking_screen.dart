import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Shown to the patient after EMT accepts.
/// Displays a live map with the patient's location (red) and
/// the EMT's moving location (blue), updated every 5 s from Firestore.
class EmtTrackingScreen extends StatefulWidget {
  final String requestId;
  final String ambulanceType;

  const EmtTrackingScreen({
    super.key,
    required this.requestId,
    required this.ambulanceType,
  });

  @override
  State<EmtTrackingScreen> createState() => _EmtTrackingScreenState();
}

class _EmtTrackingScreenState extends State<EmtTrackingScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  /// Fit the map so both patient and EMT markers are visible.
  void _fitBounds(LatLng patient, LatLng emt) {
    final bounds = LatLngBounds.fromPoints([patient, emt]);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
    );
  }

  String _distanceLabel(LatLng a, LatLng b) {
    final meters = const Distance().as(LengthUnit.Meter, a, b);
    if (meters < 1000) return '${meters.round()} m away';
    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergency_requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};

          final patientLat = (data['latitude'] as num?)?.toDouble();
          final patientLng = (data['longitude'] as num?)?.toDouble();
          final emtLat = (data['emtLat'] as num?)?.toDouble();
          final emtLng = (data['emtLng'] as num?)?.toDouble();

          final hasPatient = patientLat != null && patientLng != null;
          final hasEmt = emtLat != null && emtLng != null;

          final patientPos = hasPatient
              ? LatLng(patientLat, patientLng)
              : const LatLng(6.9271, 79.8612);
          final emtPos = hasEmt ? LatLng(emtLat, emtLng) : null;

          // Auto-fit when both positions are known
          if (hasPatient && hasEmt) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fitBounds(patientPos, emtPos!);
            });
          }

          final markers = <Marker>[
            // Patient marker — red pulsing
            Marker(
              point: patientPos,
              width: 56,
              height: 56,
              child: _PulsingDot(
                animation: _pulse,
                color: Colors.red,
                size: 20,
                pulseSize: 50,
              ),
            ),
            // EMT marker — blue ambulance
            if (emtPos != null)
              Marker(
                point: emtPos,
                width: 52,
                height: 52,
                child: _PulsingDot(
                  animation: _pulse,
                  color: const Color(0xFF2D3A8C),
                  size: 22,
                  pulseSize: 48,
                  icon: Icons.emergency_rounded,
                ),
              ),
          ];

          return Scaffold(
            body: Stack(
              children: [
                // ── Map ───────────────────────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: patientPos,
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.stj.stj_medilink_plus',
                    ),
                    MarkerLayer(markers: markers),
                    // Line between patient and EMT
                    if (emtPos != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [patientPos, emtPos],
                            color: const Color(
                              0xFF2D3A8C,
                            ).withValues(alpha: 0.5),
                            strokeWidth: 3,
                            pattern: const StrokePattern.dotted(),
                          ),
                        ],
                      ),
                  ],
                ),

                // ── Top status bar ────────────────────────────
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3A8C),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emergency_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EMT is on the way!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                widget.ambulanceType,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (emtPos != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _distanceLabel(emtPos, patientPos),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ── Recenter button ───────────────────────────
                Positioned(
                  bottom: 200,
                  right: 16,
                  child: _MapBtn(
                    onTap: () {
                      if (emtPos != null) {
                        _fitBounds(patientPos, emtPos);
                      } else {
                        _mapController.move(patientPos, 15);
                      }
                    },
                    child: const Icon(
                      Icons.fit_screen_rounded,
                      size: 20,
                      color: Color(0xFF2D3A8C),
                    ),
                  ),
                ),

                // ── Bottom info card ──────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      MediaQuery.of(context).padding.bottom + 20,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
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
                        // Legend
                        Row(
                          children: [
                            _LegendDot(color: Colors.red),
                            const SizedBox(width: 6),
                            Text(
                              'Your location',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(width: 20),
                            _LegendDot(color: const Color(0xFF2D3A8C)),
                            const SizedBox(width: 6),
                            Text(
                              'EMT location',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Status row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'EMT Accepted & En Route',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    hasEmt
                                        ? 'Live location updating every 5s'
                                        : 'Waiting for EMT location…',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasEmt)
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Done button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(
                              context,
                            ).popUntil((r) => r.isFirst),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade600,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Back to Dashboard',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Pulsing dot marker ────────────────────────────────────────────────────────

class _PulsingDot extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;
  final double pulseSize;
  final IconData? icon;

  const _PulsingDot({
    required this.animation,
    required this.color,
    required this.size,
    required this.pulseSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: pulseSize * animation.value,
            height: pulseSize * animation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(
                alpha: 0.18 * (1 - animation.value + 0.4),
              ),
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: icon != null
                ? Icon(icon, color: Colors.white, size: size * 0.55)
                : null,
          ),
        ],
      ),
    );
  }
}

// ── Map button ────────────────────────────────────────────────────────────────

class _MapBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _MapBtn({required this.onTap, required this.child});

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

// ── Legend dot ────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
        ],
      ),
    );
  }
}
