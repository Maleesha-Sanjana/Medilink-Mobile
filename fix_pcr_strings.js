const fs = require('fs');

function replaceInFile(filePath, replacements) {
  let content = fs.readFileSync(filePath, 'utf8');
  for (const [search, replace] of replacements) {
    content = content.replace(search, replace);
  }
  fs.writeFileSync(filePath, content);
}

replaceInFile('lib/screens/patient_care_report_screen.dart', [
  [/import 'package:flutter_map\/flutter_map\.dart';/g, "import 'package:flutter_map/flutter_map.dart';\nimport '../l10n/app_localizations.dart';"],
  
  // Scaffold Title
  [/const Text\('Patient Care Report'\)/g, "Text(AppLocalizations.of(context)!.pcrTitle)"],
  
  // Section 1
  [/const InputDecoration\(labelText: 'Full Name'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.fullName)"],
  [/const InputDecoration\(labelText: 'NIC \/ Passport No\.'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.nicPassport)"],
  [/const InputDecoration\(labelText: 'Age'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.age)"],
  [/const InputDecoration\(labelText: 'Gender'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.gender)"],
  [/const InputDecoration\(labelText: 'Blood Group'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.bloodGroup)"],
  [/const InputDecoration\(labelText: 'Contact No\.'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.contactNo)"],
  [/const InputDecoration\(labelText: 'Address'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.address)"],
  [/const InputDecoration\(labelText: 'Guardian \/ Next of Kin'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.guardianNextOfKin)"],
  [/const InputDecoration\(labelText: 'Relationship'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.relationship)"],
  [/const InputDecoration\(labelText: 'Guardian Contact No\.'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.guardianContactNo)"],
  [/const Text\('ID Front'\)/g, "Text(AppLocalizations.of(context)!.idFront)"],
  [/const Text\('ID Back'\)/g, "Text(AppLocalizations.of(context)!.idBack)"],

  // Section 2
  [/const InputDecoration\(labelText: 'Emergency Type'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.emergencyType)"],
  [/const InputDecoration\(labelText: 'Chief Complaint \/ Description'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.chiefComplaint)"],
  [/const InputDecoration\(labelText: 'Symptoms'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.symptoms)"],
  [/const InputDecoration\(labelText: 'Conscious Level'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.consciousLevel)"],
  [/const Text\('Pain Level \(0 - 10\)', style: TextStyle\(fontWeight: FontWeight\.w600\)\)/g, "Text(AppLocalizations.of(context)!.painLevel010, style: const TextStyle(fontWeight: FontWeight.w600))"],

  // Section 3
  [/const Text\('A - Airway', style: TextStyle\(fontWeight: FontWeight\.bold\)\)/g, "Text(AppLocalizations.of(context)!.aAirway, style: const TextStyle(fontWeight: FontWeight.bold))"],
  [/const Text\('Airway Managed\?'\)/g, "Text(AppLocalizations.of(context)!.airwayManaged)"],
  [/const InputDecoration\(labelText: 'Method'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.method)"],

  [/const Text\('B - Breathing', style: TextStyle\(fontWeight: FontWeight\.bold\)\)/g, "Text(AppLocalizations.of(context)!.bBreathing, style: const TextStyle(fontWeight: FontWeight.bold))"],
  [/const InputDecoration\(labelText: 'Resp\. Rate \(\/min\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.respRate)"],
  [/const InputDecoration\(labelText: 'SpO2 \(%\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.spo2)"],
  [/const Text\('Breathing Assisted\?'\)/g, "Text(AppLocalizations.of(context)!.breathingAssisted)"],

  [/const Text\('C - Circulation', style: TextStyle\(fontWeight: FontWeight\.bold\)\)/g, "Text(AppLocalizations.of(context)!.cCirculation, style: const TextStyle(fontWeight: FontWeight.bold))"],
  [/const InputDecoration\(labelText: 'Pulse \(\/min\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.pulseMin)"],
  [/const InputDecoration\(labelText: 'BP \(mmHg\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.bpMmHg)"],
  [/const InputDecoration\(labelText: 'Capillary Refill'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.capillaryRefill)"],
  [/const Text\('Bleeding Controlled\?'\)/g, "Text(AppLocalizations.of(context)!.bleedingControlled)"],

  [/const Text\('D - Disability', style: TextStyle\(fontWeight: FontWeight\.bold\)\)/g, "Text(AppLocalizations.of(context)!.dDisability, style: const TextStyle(fontWeight: FontWeight.bold))"],
  [/const Text\('GCS Score:', style: TextStyle\(fontWeight: FontWeight\.w600\)\)/g, "Text(AppLocalizations.of(context)!.gcsScore, style: const TextStyle(fontWeight: FontWeight.w600))"],
  [/const InputDecoration\(labelText: 'E \(1-4\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.e14)"],
  [/const InputDecoration\(labelText: 'V \(1-5\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.v15)"],
  [/const InputDecoration\(labelText: 'M \(1-6\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.m16)"],

  [/const Text\('E - Exposure', style: TextStyle\(fontWeight: FontWeight\.bold\)\)/g, "Text(AppLocalizations.of(context)!.eExposure, style: const TextStyle(fontWeight: FontWeight.bold))"],
  [/const InputDecoration\(labelText: 'Temperature \(°C\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.temperatureC)"],
  [/const Text\('No vital signs recorded yet\.', style: TextStyle\(color: Colors\.grey\)\)/g, "Text(AppLocalizations.of(context)!.noVitalsRecorded, style: const TextStyle(color: Colors.grey))"],
  
  [/Text\('Time: \$\{v\['time'\]\}'\)/g, "Text('Time: ${v['time']}')"], // we can leave this, but let's replace with proper one
  [/Text\('Pulse: \$\{v\['pulse'\]\} \| BP: \$\{v\['bp'\]\} \| SpO2: \$\{v\['spo2'\]\}'\)/g, "Text(AppLocalizations.of(context)!.timePulseBpSpo2(v['time'], v['pulse'], v['bp'], v['spo2']))"],

  [/const Text\('Log Current Vitals'\)/g, "Text(AppLocalizations.of(context)!.logCurrentVitals)"],

  // Section 4
  [/const InputDecoration\(labelText: 'S - Signs & Symptoms'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.sSignsSymptoms)"],
  [/const InputDecoration\(labelText: 'A - Allergies'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.aAllergies)"],
  [/const InputDecoration\(labelText: 'M - Medications'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.mMedications)"],
  [/const InputDecoration\(labelText: 'P - Past Medical History'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.pPastMedicalHistory)"],
  [/const InputDecoration\(labelText: 'L - Last Meal'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.lLastMeal)"],
  [/const InputDecoration\(labelText: 'E - Events Leading to Illness\/Injury'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.eEventsLeading)"],
  [/const Text\('Known Conditions', style: TextStyle\(fontWeight: FontWeight\.w600\)\)/g, "Text(AppLocalizations.of(context)!.knownConditions, style: const TextStyle(fontWeight: FontWeight.w600))"],

  // Section 5
  [/const Text\('Interactive Body Injury Map Placeholder', style: TextStyle\(color: Colors\.grey\)\)/g, "Text(AppLocalizations.of(context)!.interactiveBodyMapPlaceHolder, style: const TextStyle(color: Colors.grey))"],
  [/const Text\('\(Tap to add markers for burns, fractures, swelling, etc\.\)', style: TextStyle\(fontSize: 12, color: Colors\.grey\)\)/g, "Text(AppLocalizations.of(context)!.interactiveBodyMapHint, style: const TextStyle(fontSize: 12, color: Colors.grey))"],
  
  // Section 6
  [/const Text\('AIRWAY MANAGEMENT', style: TextStyle\(fontWeight: FontWeight\.w600, fontSize: 12\)\)/g, "Text(AppLocalizations.of(context)!.airwayManagement, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))"],
  [/const InputDecoration\(labelText: 'O2 Flow \(L\/min\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.o2Flow)"],
  [/const Text\('CARDIOVASCULAR', style: TextStyle\(fontWeight: FontWeight\.w600, fontSize: 12\)\)/g, "Text(AppLocalizations.of(context)!.cardiovascular, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))"],
  [/const Text\('IMMOBILIZATION', style: TextStyle\(fontWeight: FontWeight\.w600, fontSize: 12\)\)/g, "Text(AppLocalizations.of(context)!.immobilization, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))"],
  [/const Text\('MEDICATION GIVEN', style: TextStyle\(fontWeight: FontWeight\.w600, fontSize: 12\)\)/g, "Text(AppLocalizations.of(context)!.medicationGiven, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))"],
  [/const InputDecoration\(labelText: 'Medication'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.medication)"],
  [/const InputDecoration\(labelText: 'Dose'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.dose)"],
  [/const InputDecoration\(labelText: 'Route'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.route)"],
  [/const InputDecoration\(labelText: 'Time'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.time)"],

  // Section 7
  [/const InputDecoration\(labelText: 'Transport Type'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.transportType)"],
  [/const InputDecoration\(labelText: 'Departure Time'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.departureTime)"],
  [/const InputDecoration\(labelText: 'Arrival Time \(Ext\.\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.arrivalTimeExt)"],
  [/const InputDecoration\(labelText: 'Distance Covered \(km\)'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.distanceCoveredKm)"],
  [/const InputDecoration\(labelText: 'Hospital Name'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.hospital)"],
  [/const InputDecoration\(labelText: 'Doctor \/ Nurse Name'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.doctorNurseName)"],
  [/const InputDecoration\(labelText: 'Handover Time'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.handoverTime)"],
  [/const InputDecoration\(labelText: 'Condition on Arrival'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.conditionOnArrival)"],
  [/const InputDecoration\(labelText: 'Handover Notes'\)/g, "InputDecoration(labelText: AppLocalizations.of(context)!.handoverNotes)"],

  // Submission
  [/const Text\('SUBMIT PATIENT CARE REPORT'\)/g, "Text(AppLocalizations.of(context)!.submitPcr)"],
  [/const SnackBar\(content: Text\('Report submitted successfully!'\)\)/g, "SnackBar(content: Text(AppLocalizations.of(context)!.reportSubmitted))"],
  [/SnackBar\(content: Text\('Error saving report: \$e'\), backgroundColor: Colors\.red\)/g, "SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingReport(e.toString())), backgroundColor: Colors.red)"]

]);

console.log("Replaced strings successfully in PCR screen");
