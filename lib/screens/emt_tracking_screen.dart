import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';
import 'voice_call_screen.dart';
import 'hospital_selection_screen.dart';
import '../services/agora_service.dart';
import '../services/routing_service.dart';
import '../services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import '../l10n/app_localizations.dart';

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
  bool _hasFitBounds = false;
  List<LatLng> _routePoints = [];
  DateTime? _lastRouteFetch;
  LatLng? _lastRouteEnd;

  Future<void> _fetchRouteIfNeeded(LatLng start, LatLng end) async {
    final now = DateTime.now();
    if (_lastRouteFetch == null ||
        now.difference(_lastRouteFetch!).inSeconds > 10 ||
        _lastRouteEnd != end) {
      _lastRouteFetch = now;
      _lastRouteEnd = end;
      final points = await RoutingService.getRoute(start, end);
      if (mounted && points.isNotEmpty) {
        setState(() {
          _routePoints = points;
        });
      }
    }
  }


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
    final mins = (meters / 500).ceil(); // ~30 km/h
    final timeStr = mins < 1 ? AppLocalizations.of(context)!.arrivingNow : '$mins min away';
    
    if (meters < 1000) return AppLocalizations.of(context)!.mAwayTime(meters.round().toString(), timeStr);
    return AppLocalizations.of(context)!.kmAwayTime((meters / 1000).toStringAsFixed(1), timeStr);
  }


  Future<void> _showHandoverDialog(BuildContext context, Map<String, dynamic> data) async {
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
              await FirebaseFirestore.instance.collection('emergency_requests').doc(widget.requestId).update({
                'status': 'completed',
                'handoverDoctor': docCtrl.text.trim(),
                'handoverTime': timestamp,
              });
              
              final updatedData = Map<String, dynamic>.from(data)
                ..['status'] = 'completed'
                ..['handoverDoctor'] = docCtrl.text.trim()
                ..['handoverTime'] = timestamp;

              final pdfData = await PdfService.generateHandoverReport(updatedData, docCtrl.text.trim());
              await Printing.layoutPdf(onLayout: (format) async => pdfData);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Submit & Generate Report'),
          ),
        ],
      ),
    );
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
          final destLat = (data['destinationLat'] as num?)?.toDouble();
          final destLng = (data['destinationLng'] as num?)?.toDouble();
          final status = data['status'] as String? ?? 'accepted';

          final hasPatient = patientLat != null && patientLng != null;
          final hasEmt = emtLat != null && emtLng != null;
          final hasDest = destLat != null && destLng != null;
          final isTransporting = status == 'transporting' && hasDest;

          final patientPos = hasPatient
              ? LatLng(patientLat, patientLng)
              : const LatLng(6.9271, 79.8612);
          
          final destPos = isTransporting ? LatLng(destLat, destLng) : null;
          final emtPos = hasEmt ? LatLng(emtLat, emtLng) : null;

          
          // Fetch route points
          if (hasEmt) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (isTransporting && destPos != null) {
                  _fetchRouteIfNeeded(emtPos!, destPos);
                } else {
                  _fetchRouteIfNeeded(emtPos!, patientPos);
                }
              }
            });
          }

          // Auto-fit bounds if we have two points and haven't fit yet
          if (hasEmt && !_hasFitBounds) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                if (isTransporting && destPos != null) {
                  _fitBounds(emtPos!, destPos);
                } else {
                  _fitBounds(patientPos, emtPos!);
                }
                _hasFitBounds = true;
              }
            });
          }

          final markers = <Marker>[
            // Destination or Patient marker
            if (isTransporting && destPos != null)
              Marker(
                point: destPos,
                width: 56,
                height: 56,
                child: _PulsingDot(
                  animation: _pulse,
                  color: Colors.green,
                  size: 20,
                  pulseSize: 50,
                  icon: Icons.local_hospital_rounded,
                ),
              )
            else
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
          
          
          if (status == 'cancelled') {
            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F6FA),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cancel_outlined, color: Colors.red, size: 80),
                    const SizedBox(height: 16),
                    Text(AppLocalizations.of(context)!.tripCancelled, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('active_request_id');
                        await prefs.remove('active_request_type');
                        if (context.mounted) {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        }
                      },
                      child: const Text('Back to Dashboard'),
                    )
                  ],
                ),
              ),
            );
          }

          final isPatient = data['uid'] == FirebaseAuth.instance.currentUser?.uid;
          final isArrived = status == 'arrived';

          if (isPatient && status == 'completed') {
            if (status == 'completed') {
              SharedPreferences.getInstance().then((prefs) {
                prefs.remove('active_request_id');
                prefs.remove('active_request_type');
              });
            }
            return Scaffold(
              backgroundColor: isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F6FA),
              body: _ArrivedPatientView(data: data),
            );
          }

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
                    // Line between EMT and target (patient or hospital)
                    if (emtPos != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints.isNotEmpty ? _routePoints : (isTransporting && destPos != null ? [emtPos, destPos] : [patientPos, emtPos]),
                            color: const Color(
                              0xFF2D3A8C,
                            ).withValues(alpha: 0.5),
                            strokeWidth: 3,
                            // pattern: const StrokePattern.dotted(),
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
                              Text(
                                isTransporting ? AppLocalizations.of(context)!.transportingToHospital : AppLocalizations.of(context)!.emtOnTheWay,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              if (hasEmt && !isTransporting && emtPos != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _distanceLabel(patientPos, emtPos),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ] else if (isTransporting && destPos != null && hasEmt && emtPos != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  _distanceLabel(emtPos, destPos),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
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
                            _LegendDot(color: isTransporting ? Colors.green : Colors.red),
                            const SizedBox(width: 6),
                            Text(
                              isTransporting ? 'Hospital' : 'Your location',
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
                              'Ambulance',
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
                                    isTransporting 
                                        ? 'En Route to ${data['destinationHospital'] ?? 'Hospital'}' 
                                        : isArrived 
                                            ? 'EMT is assessing the patient' 
                                            : AppLocalizations.of(context)!.emtAcceptedEnRoute,
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
                                    isTransporting && data['hospitalTripPrice'] != null
                                        ? "${AppLocalizations.of(context)!.hospitalTripFare(data['hospitalTripPrice'].toString())}${hasEmt && destPos != null ? '  •  ${_distanceLabel(emtPos!, destPos)}' : ''}"
                                        : hasEmt
                                            ? AppLocalizations.of(context)!.liveLocationUpdating
                                            : AppLocalizations.of(context)!.waitingForEmtLocation,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isTransporting ? Colors.green.shade700 : (isDark ? Colors.white54 : Colors.grey),
                                      fontWeight: isTransporting ? FontWeight.w700 : FontWeight.normal,
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

                        // ── Call & Chat buttons ───────────────
                        Row(
                          children: [
                            Expanded(
                              child: _ContactButton(
                                icon: Icons.call_rounded,
                                label: 'Call EMT',
                                color: Colors.green,
                                onTap: () async {
                                  final emtName =
                                      (data['emtName'] ?? 'EMT') as String;
                                  final myName =
                                      FirebaseAuth
                                          .instance
                                          .currentUser
                                          ?.displayName ??
                                      'Patient';
                                  await AgoraService().initiateCall(
                                    requestId: widget.requestId,
                                    callerName: myName,
                                    callerIsEmt: false,
                                  );
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VoiceCallScreen(
                                          requestId: widget.requestId,
                                          callerName: myName,
                                          receiverName: emtName,
                                          isIncoming: false,
                                          isEmt: false,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ContactButton(
                                icon: Icons.chat_bubble_outline_rounded,
                                label: 'Message EMT',
                                color: const Color(0xFF2D3A8C),
                                onTap: () {
                                  final myName =
                                      FirebaseAuth
                                          .instance
                                          .currentUser
                                          ?.displayName ??
                                      'Patient';
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        requestId: widget.requestId,
                                        myName: myName,
                                        isEmt: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        if (isPatient && !isTransporting && data['destinationLat'] == null && data['patientCareReport'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.local_hospital_rounded),
                                label: const Text('Select Destination Hospital', style: TextStyle(fontWeight: FontWeight.w700)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HospitalSelectionScreen(
                                        requestId: widget.requestId,
                                        ambulanceType: widget.ambulanceType,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),

                        // Done / Cancel button
                        SizedBox(
                          width: double.infinity,
                          child: Builder(
                            builder: (context) {
                              if (isPatient && status == 'accepted') {
                                return SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(AppLocalizations.of(context)!.cancelTrip),
                                          content: Text(AppLocalizations.of(context)!.cancelTripConfirm),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(AppLocalizations.of(context)!.noKeep),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context); // close dialog
                                                await FirebaseFirestore.instance.collection('emergency_requests').doc(widget.requestId).update({'status': 'cancelled'});
                                              },
                                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                                              child: Text(AppLocalizations.of(context)!.yesCancel),
                                            ),
                                          ],
                                        )
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade50,
                                      foregroundColor: Colors.red,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.cancelTrip,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                );
                              }
                              if (!isPatient && status == 'transporting') {
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.directions_rounded),
                                        onPressed: () async {
                                          if (destPos != null) {
                                            final url = 'https://www.google.com/maps/dir/?api=1&destination=${destPos.latitude},${destPos.longitude}';
                                            if (await canLaunchUrl(Uri.parse(url))) {
                                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        label: const Text('Get Directions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () => _showHandoverDialog(context, data),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: const Text('Arrived to Hospital', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              if (!isPatient && status == 'completed') {
                                return SizedBox(
                                  height: 50,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.grey.shade600,
                                            side: BorderSide(color: Colors.grey.shade300),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            final pdfData = await PdfService.generateHandoverReport(data, data['handoverDoctor'] ?? 'N/A');
                                            await Printing.layoutPdf(onLayout: (format) async => pdfData);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                          child: const Text('View Report', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              if (isPatient && status == 'transporting') {
                                return const SizedBox.shrink();
                              }
                              
                              return SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey.shade600,
                                    side: BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text(
                                    'Back to Dashboard',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              );
                            }
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

// ── Contact button ────────────────────────────────────────────────────────────

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
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
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrivedPatientView extends StatelessWidget {
  final Map<String, dynamic> data;

  const _ArrivedPatientView({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                data['status'] == 'completed'
                    ? 'Arrived to Hospital Successfully'
                    : AppLocalizations.of(context)!.emtHasArrived,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                data['status'] == 'completed'
                    ? 'Your trip has been completed.'
                    : AppLocalizations.of(context)!.emtAssessing,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            data['status'] == 'completed'
                                ? 'Total Fare'
                                : AppLocalizations.of(context)!.estimatedInitialFare,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['status'] == 'completed'
                          ? (data['hospitalTripPrice']?.toString() ?? data['price']?.toString() ?? 'N/A')
                          : (data['price']?.toString() ?? AppLocalizations.of(context)!.calculating),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade600,
                      ),
                    ),
],
                ),
              ),
              if (data['status'] == 'completed') ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final pdfData = await PdfService.generateHandoverReport(data, data['handoverDoctor'] ?? 'N/A');
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => _PdfViewerScreen(pdfData: pdfData),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('View Patient Care Report', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PdfViewerScreen extends StatelessWidget {
  final Uint8List pdfData;

  const _PdfViewerScreen({required this.pdfData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Care Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PdfPreview(
        build: (format) async => pdfData,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        initialPageFormat: PdfPageFormat.a4,
      ),
    );
  }
}

