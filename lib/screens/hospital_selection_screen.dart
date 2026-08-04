import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';

class HospitalSelectionScreen extends StatefulWidget {
  final String requestId;
  final String ambulanceType;

  const HospitalSelectionScreen({
    super.key,
    required this.requestId,
    required this.ambulanceType,
  });

  @override
  State<HospitalSelectionScreen> createState() => _HospitalSelectionScreenState();
}

class _HospitalSelectionScreenState extends State<HospitalSelectionScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(6.9271, 79.8612); // default
  bool _locationLoaded = false;
  
  List<Hospital> _hospitals = [];
  Hospital? _selectedHospital;
  double? _distanceKm;
  double? _fare;
  bool _loading = false;
  Hospital? _recommendedHospital;
  bool _isPatient = false;


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final allHospitals = await HospitalService().getHospitals();
      final hList = allHospitals.where((h) => h.status == 'approved').toList();

      // Fetch PCR data and required facilities
      Map<String, dynamic> pcrData = {};
      List<String> desiredFeatures = [];
      try {
        final reqDoc = await FirebaseFirestore.instance.collection('emergency_requests').doc(widget.requestId).get();
        if (reqDoc.exists) {
          final data = reqDoc.data();
          if (data != null) {
            _isPatient = data['uid'] == FirebaseAuth.instance.currentUser?.uid;
            if (data['patientCareReport'] != null) {
              pcrData = data['patientCareReport'] as Map<String, dynamic>;
            }
            if (data['requiredFacilities'] != null) {
              final reqFacs = data['requiredFacilities'] as List<dynamic>;
              desiredFeatures.addAll(reqFacs.map((e) => e.toString()));
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching req: $e');
      }
      
      // Analyze PCR to determine required features
      final String type = (pcrData['emergencyType'] ?? '').toString().toLowerCase();
      final String complaint = (pcrData['chiefComplaint'] ?? '').toString().toLowerCase();
      final String symptoms = (pcrData['symptoms'] ?? '').toString().toLowerCase();
      
      if (type.contains('trauma') || complaint.contains('accident') || symptoms.contains('fracture') || symptoms.contains('broken')) {
        desiredFeatures.addAll(['Trauma Center', 'X-Ray']);
      }
      if (type.contains('cardiac') || complaint.contains('chest pain') || symptoms.contains('heart')) {
        desiredFeatures.addAll(['Cardiology', 'ICU']);
      }
      if (type.contains('burn')) {
        desiredFeatures.addAll(['Burn Unit', 'ICU']);
      }
      if (type.contains('stroke') || symptoms.contains('paralysis') || symptoms.contains('numbness')) {
        desiredFeatures.addAll(['Neurology', 'ICU']);
      }
      if (type.contains('maternity') || complaint.contains('pregnancy') || symptoms.contains('labor')) {
        desiredFeatures.addAll(['Maternity']);
      }
      
      Hospital? topHospital;
      int topScore = -1;
      
      for (var h in hList) {
        int score = 0;
        for (var f in h.features) {
          if (desiredFeatures.contains(f)) {
            score++;
          }
        }
        if (score > topScore && score > 0) {
          topScore = score;
          topHospital = h;
        }
      }
      
      setState(() {
        _hospitals = hList;
        if (topHospital != null) {
          _recommendedHospital = topHospital;
          _hospitals.remove(topHospital);
          _hospitals.insert(0, topHospital); // move to front
        }
      });
      
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _locationLoaded = true;
      });
      _mapController.move(_currentLocation, 13.0);
      
      if (topHospital != null) {
        _selectHospital(topHospital); // auto select recommended
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _selectHospital(Hospital h) {
    final distance = const Distance();
    final d = distance.as(
      LengthUnit.Meter,
      _currentLocation,
      LatLng(h.latitude, h.longitude),
    );
    final distKm = d / 1000.0;
    
    // Formula calculation
    final basicFare = 5000.0 + (distKm * 200.0);
    double finalFare = basicFare;
    
    // Check type to apply multipliers
    final typeLower = widget.ambulanceType.toLowerCase();
    if (typeLower.contains('advanced')) {
      finalFare = basicFare * 1.5;
    } else if (typeLower.contains('icu')) {
      finalFare = basicFare * 2.0;
    } else if (typeLower.contains('neonatal')) {
      finalFare = basicFare * 1.8;
    }
    
    setState(() {
      _selectedHospital = h;
      _distanceKm = distKm;
      _fare = finalFare;
    });
  }

  Future<void> _confirmAndGo() async {
    if (_selectedHospital == null || _fare == null) return;
    
    setState(() => _loading = true);
    try {
      final fmt = NumberFormat('#,##0');
      final fareStr = 'LKR ${fmt.format(_fare!)}';
      
      final updateData = <String, dynamic>{
        'destinationHospital': _selectedHospital!.name,
        'destinationLat': _selectedHospital!.latitude,
        'destinationLng': _selectedHospital!.longitude,
        'hospitalTripPrice': fareStr,
      };
      
      if (!_isPatient) {
        updateData['status'] = 'transporting';
      }
      
      await FirebaseFirestore.instance.collection('emergency_requests').doc(widget.requestId).update(updateData);
      
      if (mounted) {
        Navigator.pop(context); // Go back to EMT Dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.selectDestination),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.stj.medilink',
              ),
              MarkerLayer(
                markers: [
                  if (_locationLoaded)
                    Marker(
                      point: _currentLocation,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location_rounded, color: Colors.blue, size: 30),
                    ),
                  ..._hospitals.map((h) => Marker(
                    point: LatLng(h.latitude, h.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => _selectHospital(h),
                      child: Icon(
                        Icons.local_hospital_rounded,
                        color: _selectedHospital?.id == h.id ? Colors.orange : (_recommendedHospital?.id == h.id ? Colors.green : Colors.red),
                        size: _selectedHospital?.id == h.id ? 40 : (_recommendedHospital?.id == h.id ? 38 : 30),
                      ),
                    ),
                  )),
                ],
              ),
            ],
          ),
          
          // Zoom Controls
          Positioned(
            right: 16,
            top: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'hospital_zoom_in',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom + 1);
                  },
                  child: const Icon(Icons.add, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'hospital_zoom_out',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(_mapController.camera.center, currentZoom - 1);
                  },
                  child: const Icon(Icons.remove, color: Colors.black87),
                ),
              ],
            ),
          ),
          
          if (_selectedHospital != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 30,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      if (_recommendedHospital?.id == _selectedHospital!.id)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.star_rounded, color: Colors.green, size: 16),
                              SizedBox(width: 4),
                              Text('Recommended Match', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      Text(
                        _selectedHospital!.name,

                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      
                      if (_selectedHospital!.features.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: _selectedHospital!.features.map((f) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                            ),
                            child: Text(f, style: TextStyle(fontSize: 10, color: Colors.blue.shade700)),
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text('Distance: ${_distanceKm!.toStringAsFixed(1)} km'),
                      Text(
                        'Estimated Fare: LKR ${NumberFormat('#,##0').format(_fare!)}',
                        style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D3A8C),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _loading ? null : _confirmAndGo,
                          child: _loading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(_isPatient ? 'Confirm Destination' : AppLocalizations.of(context)!.startTrip),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
