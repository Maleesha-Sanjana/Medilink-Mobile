import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hospital_selection_screen.dart';

class PatientCareReportScreen extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> initialData;

  const PatientCareReportScreen({
    super.key,
    required this.requestId,
    required this.initialData,
  });

  @override
  State<PatientCareReportScreen> createState() => _PatientCareReportScreenState();
}

class _PatientCareReportScreenState extends State<PatientCareReportScreen> {
  final _formKey = GlobalKey<FormState>();

  // Section 1 Controllers
  final _nameCtrl = TextEditingController();
  final _nicCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _gender;
  final _contactCtrl = TextEditingController();
  String? _bloodGroup;
  final _addressCtrl = TextEditingController();
  final _guardianNameCtrl = TextEditingController();
  final _guardianRelCtrl = TextEditingController();
  final _guardianContactCtrl = TextEditingController();

  // Section 2 Controllers
  String? _emergencyType;
  final _complaintCtrl = TextEditingController();
  final _symptomsCtrl = TextEditingController();
  String? _consciousLevel;
  double _painLevel = 0;

  // Section 3 Controllers
  final Map<String, bool> _airway = {'Clear': false, 'Obstructed': false, 'Swelling': false, 'Secretions': false, 'Blood': false};
  bool _airwayManaged = false;
  final _airwayMethodCtrl = TextEditingController();

  final Map<String, bool> _breathing = {'Normal': false, 'Shallow': false, 'Gasping': false, 'Absent': false};
  final _respiratoryRateCtrl = TextEditingController();
  final _spO2Ctrl = TextEditingController();
  bool _breathingAssisted = false;
  final _breathingMethodCtrl = TextEditingController();

  final Map<String, bool> _circulation = {'Normal': false, 'Pale': false, 'Cyanotic': false, 'Bleeding': false};
  final _pulseCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  String? _capillaryRefill;
  bool _bleedingControlled = false;

  final Map<String, bool> _disability = {'Alert': false, 'Voice': false, 'Pain': false, 'Unresponsive': false};
  final _gcsECtrl = TextEditingController();
  final _gcsVCtrl = TextEditingController();
  final _gcsMCtrl = TextEditingController();
  String? _pupilsLeft;
  String? _pupilsRight;

  final Map<String, bool> _exposure = {'Burns': false, 'Fracture': false, 'Bleeding': false, 'Rash': false, 'Swelling': false, 'Other': false};
  final _tempCtrl = TextEditingController();

  // Section 4
  final List<Map<String, String>> _vitalsTimeline = [];

  // Section 5 Controllers
  final _sampleSCtrl = TextEditingController();
  final _sampleACtrl = TextEditingController();
  final _sampleMCtrl = TextEditingController();
  final _samplePCtrl = TextEditingController();
  final _sampleLCtrl = TextEditingController();
  final _sampleECtrl = TextEditingController();
  final Map<String, bool> _knownConditions = {'Diabetes': false, 'Hypertension': false, 'Asthma': false, 'Cardiac Disease': false, 'Stroke': false, 'Seizures': false, 'Pregnancy': false, 'Other': false};

  // Section 7 Controllers
  final Map<String, bool> _treatmentAirway = {'Oxygen': false, 'Suction': false, 'Nebulizer': false, 'Intubation': false, 'Other': false};
  final _o2FlowCtrl = TextEditingController();
  final Map<String, bool> _treatmentCardio = {'ECG Monitoring': false, 'CPR': false, 'Defibrillation': false, 'IV Line Inserted': false, 'Fluids Given': false, 'Other': false};
  final Map<String, bool> _treatmentImmobi = {'Cervical Collar': false, 'Splint': false, 'Spine Board': false, 'Stretcher': false, 'Other': false};
  final _medicationCtrl = TextEditingController();
  final _medDoseCtrl = TextEditingController();
  final _medRouteCtrl = TextEditingController();
  final _medTimeCtrl = TextEditingController();

  // Section 9 & 10 Controllers
  String? _transportType;
  final _departureTimeCtrl = TextEditingController();
  final _arrivalTimeCtrl = TextEditingController();
  final _distanceCoveredCtrl = TextEditingController();
  final _hospitalNameCtrl = TextEditingController();
  final _doctorNameCtrl = TextEditingController();
  final _handoverTimeCtrl = TextEditingController();
  String? _patientConditionArrival;
  final _handoverNotesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill some data if available
    _nameCtrl.text = widget.initialData['patientName'] ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicCtrl.dispose();
    _ageCtrl.dispose();
    _contactCtrl.dispose();
    _addressCtrl.dispose();
    _guardianNameCtrl.dispose();
    _guardianRelCtrl.dispose();
    _guardianContactCtrl.dispose();
    _complaintCtrl.dispose();
    _symptomsCtrl.dispose();
    _airwayMethodCtrl.dispose();
    _respiratoryRateCtrl.dispose();
    _spO2Ctrl.dispose();
    _breathingMethodCtrl.dispose();
    _pulseCtrl.dispose();
    _bpCtrl.dispose();
    _gcsECtrl.dispose();
    _gcsVCtrl.dispose();
    _gcsMCtrl.dispose();
    _tempCtrl.dispose();
    _sampleSCtrl.dispose();
    _sampleACtrl.dispose();
    _sampleMCtrl.dispose();
    _samplePCtrl.dispose();
    _sampleLCtrl.dispose();
    _sampleECtrl.dispose();
    _o2FlowCtrl.dispose();
    _medicationCtrl.dispose();
    _medDoseCtrl.dispose();
    _medRouteCtrl.dispose();
    _medTimeCtrl.dispose();
    _departureTimeCtrl.dispose();
    _arrivalTimeCtrl.dispose();
    _distanceCoveredCtrl.dispose();
    _hospitalNameCtrl.dispose();
    _doctorNameCtrl.dispose();
    _handoverTimeCtrl.dispose();
    _handoverNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.pcrTitle),
        backgroundColor: const Color(0xFF2D3A8C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('1. PATIENT INFORMATION', Icons.person),
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fullName),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nicCtrl,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.nicPassport),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _ageCtrl,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.age),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.gender),
                              value: _gender,
                              items: ['Male', 'Female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) => setState(() => _gender = v),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.bloodGroup),
                              value: _bloodGroup,
                              items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) => setState(() => _bloodGroup = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactCtrl,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.contactNo),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressCtrl,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.address),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _guardianNameCtrl,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.guardianNextOfKin),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _guardianRelCtrl,
                              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.relationship),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _guardianContactCtrl,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.guardianContactNo),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      // ID Scan Placeholders
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.camera_alt),
                              label: Text(AppLocalizations.of(context)!.idFront),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.camera_alt),
                              label: Text(AppLocalizations.of(context)!.idBack),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionHeader('2. EMERGENCY DETAILS', Icons.warning_rounded),
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.emergencyType),
                        value: _emergencyType,
                        items: ['Medical', 'Trauma', 'Obstetric', 'Pediatric'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _emergencyType = v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _complaintCtrl,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.chiefComplaint),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _symptomsCtrl,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.symptoms),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.consciousLevel),
                        value: _consciousLevel,
                        items: ['Conscious', 'Unconscious', 'Responds to Pain'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _consciousLevel = v),
                      ),
                      const SizedBox(height: 20),
                      Text(AppLocalizations.of(context)!.painLevel010, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Slider(
                        value: _painLevel,
                        min: 0,
                        max: 10,
                        divisions: 10,
                        label: _painLevel.round().toString(),
                        activeColor: _painLevel > 6 ? Colors.red : (_painLevel > 3 ? Colors.orange : Colors.green),
                        onChanged: (v) => setState(() => _painLevel = v),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('3. PRIMARY SURVEY (ABCDE)', Icons.accessibility_new_rounded),
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.aAirway, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        children: _airway.keys.map((k) => _buildCheckbox(k, _airway[k]!, (v) => setState(() => _airway[k] = v!))).toList(),
                      ),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.airwayManaged),
                        value: _airwayManaged,
                        onChanged: (v) => setState(() => _airwayManaged = v),
                      ),
                      if (_airwayManaged)
                        TextFormField(controller: _airwayMethodCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.method)),
                      
                      const Divider(height: 32),
                      
                      Text(AppLocalizations.of(context)!.bBreathing, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        children: _breathing.keys.map((k) => _buildCheckbox(k, _breathing[k]!, (v) => setState(() => _breathing[k] = v!))).toList(),
                      ),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _respiratoryRateCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.respRate))),
                          const SizedBox(width: 12),
                          Expanded(child: TextFormField(controller: _spO2Ctrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.spo2))),
                        ],
                      ),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.breathingAssisted),
                        value: _breathingAssisted,
                        onChanged: (v) => setState(() => _breathingAssisted = v),
                      ),
                      if (_breathingAssisted)
                        TextFormField(controller: _breathingMethodCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.method)),

                      const Divider(height: 32),
                      
                      Text(AppLocalizations.of(context)!.cCirculation, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        children: _circulation.keys.map((k) => _buildCheckbox(k, _circulation[k]!, (v) => setState(() => _circulation[k] = v!))).toList(),
                      ),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _pulseCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.pulseMin))),
                          const SizedBox(width: 12),
                          Expanded(child: TextFormField(controller: _bpCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.bpMmHg))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.capillaryRefill),
                        value: _capillaryRefill,
                        items: ['< 2 sec', '> 2 sec'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setState(() => _capillaryRefill = v),
                      ),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.bleedingControlled),
                        value: _bleedingControlled,
                        onChanged: (v) => setState(() => _bleedingControlled = v),
                      ),
                      
                      const Divider(height: 32),
                      
                      Text(AppLocalizations.of(context)!.dDisability, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        children: _disability.keys.map((k) => _buildCheckbox(k, _disability[k]!, (v) => setState(() => _disability[k] = v!))).toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(AppLocalizations.of(context)!.gcsScore, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _gcsECtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.e14), keyboardType: TextInputType.number)),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _gcsVCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.v15), keyboardType: TextInputType.number)),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _gcsMCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.m16), keyboardType: TextInputType.number)),
                        ],
                      ),
                      
                      const Divider(height: 32),
                      
                      Text(AppLocalizations.of(context)!.eExposure, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(
                        children: _exposure.keys.map((k) => _buildCheckbox(k, _exposure[k]!, (v) => setState(() => _exposure[k] = v!))).toList(),
                      ),
                      TextFormField(controller: _tempCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.temperatureC)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionHeader('4. VITAL SIGNS TIMELINE', Icons.timeline),
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Mock timeline entries
                      if (_vitalsTimeline.isEmpty)
                        Text(AppLocalizations.of(context)!.noVitalsRecorded, style: const TextStyle(color: Colors.grey)),
                      ..._vitalsTimeline.map((v) => ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: Text('Time: ${v['time']}'),
                        subtitle: Text(AppLocalizations.of(context)!.timePulseBpSpo2(v['time']?.toString() ?? '', v['pulse']?.toString() ?? '', v['bp']?.toString() ?? '', v['spo2']?.toString() ?? '')),
                      )),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Simple mock add
                          setState(() {
                            _vitalsTimeline.add({
                              'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                              'pulse': _pulseCtrl.text.isNotEmpty ? _pulseCtrl.text : 'N/A',
                              'bp': _bpCtrl.text.isNotEmpty ? _bpCtrl.text : 'N/A',
                              'spo2': _spO2Ctrl.text.isNotEmpty ? _spO2Ctrl.text : 'N/A',
                            });
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: Text(AppLocalizations.of(context)!.logCurrentVitals),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('5. MEDICAL HISTORY (SAMPLE)', Icons.history_edu),
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            TextFormField(controller: _sampleSCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.sSignsSymptoms)),
                            TextFormField(controller: _sampleACtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.aAllergies)),
                            TextFormField(controller: _sampleMCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.mMedications)),
                            TextFormField(controller: _samplePCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.pPastMedicalHistory)),
                            TextFormField(controller: _sampleLCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.lLastMeal)),
                            TextFormField(controller: _sampleECtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.eEventsLeading)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.knownConditions, style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ..._knownConditions.keys.map((k) => _buildCheckbox(k, _knownConditions[k]!, (v) => setState(() => _knownConditions[k] = v!))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionHeader('6. BODY INJURY MAP', Icons.accessibility_new),
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.person_outline, size: 100, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.interactiveBodyMapPlaceHolder, style: const TextStyle(color: Colors.grey)),
                      Text(AppLocalizations.of(context)!.interactiveBodyMapHint, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('7. TREATMENT GIVEN', Icons.healing),
              Card(
                color: cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.airwayManagement, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                ..._treatmentAirway.keys.map((k) => _buildCheckbox(k, _treatmentAirway[k]!, (v) => setState(() => _treatmentAirway[k] = v!))),
                                TextFormField(controller: _o2FlowCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.o2Flow)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.cardiovascular, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                ..._treatmentCardio.keys.map((k) => _buildCheckbox(k, _treatmentCardio[k]!, (v) => setState(() => _treatmentCardio[k] = v!))),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.immobilization, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                ..._treatmentImmobi.keys.map((k) => _buildCheckbox(k, _treatmentImmobi[k]!, (v) => setState(() => _treatmentImmobi[k] = v!))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.medicationGiven, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      Row(
                        children: [
                          Expanded(flex: 2, child: TextFormField(controller: _medicationCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.medication))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _medDoseCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.dose))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _medRouteCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.route))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _medTimeCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.time))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader('8. TRANSPORT DETAILS', Icons.directions_car),
                        Card(
                          color: cardColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.transportType),
                                  value: _transportType,
                                  items: ['ALS', 'BLS'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                  onChanged: (v) => setState(() => _transportType = v),
                                ),
                                TextFormField(controller: _departureTimeCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.departureTime)),
                                TextFormField(controller: _arrivalTimeCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.arrivalTimeExt)),
                                TextFormField(controller: _distanceCoveredCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.distanceCoveredKm)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader('9. PATIENT HANDOVER', Icons.handshake),
                        Card(
                          color: cardColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextFormField(controller: _hospitalNameCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.hospital)),
                                TextFormField(controller: _doctorNameCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.doctorNurseName)),
                                TextFormField(controller: _handoverTimeCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.handoverTime)),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.conditionOnArrival),
                                  value: _patientConditionArrival,
                                  items: ['Stable', 'Critical', 'Deceased'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                  onChanged: (v) => setState(() => _patientConditionArrival = v),
                                ),
                                TextFormField(controller: _handoverNotesCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.handoverNotes), maxLines: 2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () => _submitForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: Text(AppLocalizations.of(context)!.submitPcr),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final reportData = {
        'patientInfo': {
          'name': _nameCtrl.text,
          'nic': _nicCtrl.text,
          'age': _ageCtrl.text,
          'gender': _gender,
          'contact': _contactCtrl.text,
          'bloodGroup': _bloodGroup,
          'address': _addressCtrl.text,
          'guardianName': _guardianNameCtrl.text,
          'guardianRel': _guardianRelCtrl.text,
        },
        'emergencyDetails': {
          'emergencyType': _emergencyType,
          'chiefComplaint': _complaintCtrl.text,
          'symptoms': _symptomsCtrl.text,
          'consciousLevel': _consciousLevel,
          'painLevel': _painLevel,
        },
        'primarySurvey': {
          'airway': _airway,
          'breathing': _breathing,
          'circulation': _circulation,
          'disability': _disability,
          'exposure': _exposure,
        },
        'vitals': _vitalsTimeline,
        'medicalHistory': {
          'signsSymptoms': _sampleSCtrl.text,
          'allergies': _sampleACtrl.text,
          'medications': _sampleMCtrl.text,
          'pastMedicalHistory': _samplePCtrl.text,
          'lastMeal': _sampleLCtrl.text,
          'events': _sampleECtrl.text,
          'knownConditions': _knownConditions,
        },
        'treatment': {
          'airway': _treatmentAirway,
          'o2Flow': _o2FlowCtrl.text,
          'cardiovascular': _treatmentCardio,
          'immobilization': _treatmentImmobi,
          'medication': _medicationCtrl.text,
          'dose': _medDoseCtrl.text,
          'route': _medRouteCtrl.text,
          'time': _medTimeCtrl.text,
        },
        'transport': {
          'type': _transportType,
          'departureTime': _departureTimeCtrl.text,
          'arrivalTime': _arrivalTimeCtrl.text,
          'distance': _distanceCoveredCtrl.text,
        },
        'handover': {
          'hospital': _hospitalNameCtrl.text,
          'doctorNurse': _doctorNameCtrl.text,
          'time': _handoverTimeCtrl.text,
          'patientCondition': _patientConditionArrival,
          'notes': _handoverNotesCtrl.text,
        },
        'submittedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('emergency_requests')
          .doc(widget.requestId)
          .update({
            'patientCareReport': reportData,
          });

      if (mounted) {
        Navigator.pop(context); // pop dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.reportSubmitted)),
        );
        final reqDoc = await FirebaseFirestore.instance.collection('emergency_requests').doc(widget.requestId).get();
        final destLat = reqDoc.data()?['destinationLat'];
        final destHosp = reqDoc.data()?['destinationHospital'];
        
        if (destLat != null) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Destination Selected'),
                content: Text('The patient has requested to go to $destHosp. Do you want to start the trip to this hospital?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HospitalSelectionScreen(
                            requestId: widget.requestId,
                            ambulanceType: widget.initialData['ambulanceType'] ?? 'Basic',
                          ),
                        ),
                      );
                    },
                    child: const Text('No, select different'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await FirebaseFirestore.instance.collection('emergency_requests').doc(widget.requestId).update({'status': 'transporting'});
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Yes, start trip'),
                  ),
                ],
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HospitalSelectionScreen(
                requestId: widget.requestId,
                ambulanceType: widget.initialData['ambulanceType'] ?? 'Basic',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // pop dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingReport(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return SizedBox(
      width: 140,
      child: CheckboxListTile(
        title: Text(label, style: const TextStyle(fontSize: 13)),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2D3A8C), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3A8C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
