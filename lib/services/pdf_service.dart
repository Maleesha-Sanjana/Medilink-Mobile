import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  static Future<Uint8List> generateHandoverReport(
    Map<String, dynamic> requestData,
    String doctorName,
  ) async {
    final pdf = pw.Document();

    final pcr = requestData['patientCareReport'] as Map<String, dynamic>? ?? {};
    final id = requestData['id'] ?? 'Unknown ID';
    
    // Extract sections
    final patientInfo = pcr['patientInfo'] as Map<String, dynamic>? ?? {};
    final emergencyDetails = pcr['emergencyDetails'] as Map<String, dynamic>? ?? {};
    final primarySurvey = pcr['primarySurvey'] as Map<String, dynamic>? ?? {};
    final medicalHistory = pcr['medicalHistory'] as Map<String, dynamic>? ?? {};
    final treatment = pcr['treatment'] as Map<String, dynamic>? ?? {};
    final transport = pcr['transport'] as Map<String, dynamic>? ?? {};

    // Patient Info
    final name = patientInfo['name']?.toString() ?? 'Unknown';
    final age = patientInfo['age']?.toString() ?? 'N/A';
    final gender = patientInfo['gender']?.toString() ?? 'N/A';
    final contact = patientInfo['contact']?.toString() ?? 'N/A';
    final bloodGroup = patientInfo['bloodGroup']?.toString() ?? 'N/A';
    final nic = patientInfo['nic']?.toString() ?? 'N/A';

    // Emergency Details
    final emergencyType = emergencyDetails['emergencyType']?.toString() ?? 'N/A';
    final chiefComplaint = emergencyDetails['chiefComplaint']?.toString() ?? 'N/A';
    final symptoms = emergencyDetails['symptoms']?.toString() ?? 'None';
    final consciousLevel = emergencyDetails['consciousLevel']?.toString() ?? 'N/A';

    // Hospital Info
    final hospital = requestData['destinationHospital'] ?? 'Unknown Hospital';
    final timeStr = requestData['handoverTime'] != null 
        ? DateTime.fromMillisecondsSinceEpoch((requestData['handoverTime']).millisecondsSinceEpoch).toString() 
        : DateTime.now().toString();

    // Helper for map to string
    String mapTrueKeys(Map<String, dynamic>? map) {
      if (map == null) return 'None';
      final keys = map.entries.where((e) => e.value == true).map((e) => e.key).toList();
      return keys.isEmpty ? 'None' : keys.join(', ');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('STJ MediLink +', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('EMT PRE-HOSPITAL PATIENT CARE REPORT', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Incident ID: $id', style: const pw.TextStyle(fontSize: 10, color: PdfColors.red)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // 1. Patient Information
            _buildSectionHeader('1. PATIENT INFORMATION'),
            pw.SizedBox(height: 8),
            _buildRow('Full Name:', name, 'Age/Gender:', '$age / $gender'),
            _buildRow('NIC/Passport:', nic, 'Blood Group:', bloodGroup),
            _buildRow('Contact No:', contact, 'Guardian:', patientInfo['guardianName']?.toString() ?? 'N/A'),
            pw.SizedBox(height: 16),

            // 2. Emergency Details
            _buildSectionHeader('2. EMERGENCY DETAILS'),
            pw.SizedBox(height: 8),
            _buildRow('Emergency Type:', emergencyType, 'Conscious Lvl:', consciousLevel),
            _buildRow('Chief Complaint:', chiefComplaint, 'Pain Level:', emergencyDetails['painLevel']?.toString() ?? 'N/A'),
            _buildRow('Symptoms:', symptoms, '', ''),
            pw.SizedBox(height: 16),

            // 3. Primary Survey
            _buildSectionHeader('3. PRIMARY SURVEY'),
            pw.SizedBox(height: 8),
            _buildRow('Airway:', primarySurvey['airway']?.toString() ?? 'N/A', 'Breathing:', primarySurvey['breathing']?.toString() ?? 'N/A'),
            _buildRow('Circulation:', primarySurvey['circulation']?.toString() ?? 'N/A', 'Disability:', primarySurvey['disability']?.toString() ?? 'N/A'),
            pw.SizedBox(height: 16),

            // 4. SAMPLE History
            _buildSectionHeader('4. SAMPLE HISTORY'),
            pw.SizedBox(height: 8),
            _buildRow('Allergies:', medicalHistory['allergies']?.toString() ?? 'N/A', 'Medications:', medicalHistory['medications']?.toString() ?? 'N/A'),
            _buildRow('Past History:', medicalHistory['pastMedicalHistory']?.toString() ?? 'N/A', 'Last Meal:', medicalHistory['lastMeal']?.toString() ?? 'N/A'),
            _buildRow('Events Prior:', medicalHistory['events']?.toString() ?? 'N/A', '', ''),
            pw.SizedBox(height: 16),

            // 5. Treatment Given
            _buildSectionHeader('5. TREATMENT GIVEN'),
            pw.SizedBox(height: 8),
            _buildRow('Airway Mgmt:', mapTrueKeys(treatment['airway'] as Map<String, dynamic>?), 'O2 Flow:', treatment['o2Flow']?.toString() ?? 'N/A'),
            _buildRow('Cardiovascular:', mapTrueKeys(treatment['cardiovascular'] as Map<String, dynamic>?), 'Immobilization:', mapTrueKeys(treatment['immobilization'] as Map<String, dynamic>?)),
            if ((treatment['medication']?.toString().isNotEmpty ?? false))
              _buildRow('Medication Given:', '${treatment['medication']} - ${treatment['dose']} - ${treatment['route']} at ${treatment['time']}', '', ''),
            pw.SizedBox(height: 16),

            // 6. Patient Handover
            _buildSectionHeader('6. PATIENT HANDOVER'),
            pw.SizedBox(height: 8),
            _buildRow('Receiving Hospital:', hospital, 'Handover Time:', timeStr.substring(0, 16)),
            _buildRow('Receiving Dr/Nurse:', doctorName, 'Transport Type:', transport['type']?.toString() ?? 'N/A'),
            
            pw.SizedBox(height: 30),
            
            // Footer
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('EMT Signature: _________________', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Generated by AI Decision Support System', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(4),
      decoration: const pw.BoxDecoration(color: PdfColors.blue900),
      child: pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 12)),
    );
  }

  static pw.Widget _buildRow(String label1, String val1, String label2, String val2) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 2, child: pw.Text(label1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          pw.Expanded(flex: 3, child: pw.Text(val1, style: const pw.TextStyle(fontSize: 10))),
          pw.Expanded(flex: 2, child: pw.Text(label2, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          pw.Expanded(flex: 3, child: pw.Text(val2, style: const pw.TextStyle(fontSize: 10))),
        ],
      ),
    );
  }
}
