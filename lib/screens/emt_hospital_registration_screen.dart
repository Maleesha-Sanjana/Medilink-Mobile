import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';

class EmtHospitalRegistrationScreen extends StatefulWidget {
  const EmtHospitalRegistrationScreen({super.key});

  @override
  State<EmtHospitalRegistrationScreen> createState() => _EmtHospitalRegistrationScreenState();
}

class _EmtHospitalRegistrationScreenState extends State<EmtHospitalRegistrationScreen> {
  final _nameCtrl = TextEditingController();
  
  final List<String> _specialFacilities = [
    'Emergency Department',
    'ICU',
    'Trauma Care',
    'Operating Theatre',
    'Cardiac Care Unit',
    'Stroke Unit',
    'X-Ray',
    'CT Scan',
    'MRI',
    'Ventilator Support',
    'Pediatric Unit',
    'Maternity Unit',
    'Burns Unit',
    'Dialysis Unit',
    'Other Special Requirements',
  ];
  final List<String> _selectedFeatures = [];
  
  double? _lat;
  double? _lng;
  bool _fetchingLocation = false;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location fetched successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _fetchingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hospital name is required'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fetch the hospital location first'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _submitting = true);
    
    try {
      final features = List<String>.from(_selectedFeatures);

      final newHospital = Hospital(
        id: '', // Firestore will assign
        name: _nameCtrl.text.trim(),
        latitude: _lat!,
        longitude: _lng!,
        features: features,
        status: 'pending',
      );

      await HospitalService().createHospital(newHospital);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hospital registered successfully and is pending admin approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Hospital'),
        backgroundColor: const Color(0xFF2D3A8C),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Register a new hospital by providing its details and fetching your current GPS location.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Hospital Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital_rounded),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Available Facilities',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: _specialFacilities.map((facility) {
                    return CheckboxListTile(
                      title: Text(facility),
                      value: _selectedFeatures.contains(facility),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedFeatures.add(facility);
                          } else {
                            _selectedFeatures.remove(facility);
                          }
                        });
                      },
                      dense: true,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _lat != null && _lng != null
                                ? 'Lat: ${_lat!.toStringAsFixed(4)}, Lng: ${_lng!.toStringAsFixed(4)}'
                                : 'Location not set',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _fetchingLocation ? null : _fetchLocation,
                        icon: _fetchingLocation 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.my_location_rounded),
                        label: const Text('Fetch Current Location'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit for Approval', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
