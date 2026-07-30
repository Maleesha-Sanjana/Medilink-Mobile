import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pdf_service.dart';

class CollectPaymentScreen extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> initialData;

  const CollectPaymentScreen({
    Key? key,
    required this.requestId,
    required this.initialData,
  }) : super(key: key);

  @override
  State<CollectPaymentScreen> createState() => _CollectPaymentScreenState();
}

class _CollectPaymentScreenState extends State<CollectPaymentScreen> {
  bool _loading = false;
  double _initialFare = 0.0;
  double _hospitalFare = 0.0;
  double _totalFare = 0.0;
  String _initialFareStr = 'LKR 0';
  String _hospitalFareStr = 'LKR 0';
  String _totalFareStr = 'LKR 0';

  @override
  void initState() {
    super.initState();
    _calculateFares();
  }

  double _parsePrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return 0.0;
    // e.g. 'LKR 5,000'
    final numStr = priceStr.replaceAll('LKR', '').replaceAll(',', '').trim();
    return double.tryParse(numStr) ?? 0.0;
  }

  void _calculateFares() {
    _initialFareStr = widget.initialData['price']?.toString() ?? 'LKR 0';
    _hospitalFareStr = widget.initialData['hospitalTripPrice']?.toString() ?? 'LKR 0';
    
    _initialFare = _parsePrice(_initialFareStr);
    _hospitalFare = _parsePrice(_hospitalFareStr);
    _totalFare = _initialFare + _hospitalFare;

    final fmt = NumberFormat('#,##0');
    _totalFareStr = 'LKR ${fmt.format(_totalFare)}';
  }

  Future<void> _confirmPayment() async {
    setState(() => _loading = true);
    try {
      // Mark as completed and payment collected
      await FirebaseFirestore.instance.collection('emergency_requests').doc(widget.requestId).update({
        'status': 'completed',
        'paymentCollected': true,
        'totalFare': _totalFareStr,
      });

      final updatedData = Map<String, dynamic>.from(widget.initialData)
        ..['status'] = 'completed'
        ..['paymentCollected'] = true
        ..['totalFare'] = _totalFareStr;

      final docName = updatedData['handoverDoctor']?.toString() ?? 'Unknown';

      final pdfData = await PdfService.generateHandoverReport(updatedData, docName);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_request_id');
      await prefs.remove('active_request_type');

      if (mounted) {
        // Pop the screen back to dashboard
        Navigator.pop(context);
        // Show PDF
        await Printing.layoutPdf(onLayout: (format) async => pdfData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collect Payment'),
        backgroundColor: const Color(0xFF2D3A8C),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.payments_rounded, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'Handover Complete',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Please collect the total cash payment from the patient or guardian before concluding the trip.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
              ),
              const SizedBox(height: 40),
              
              Card(
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Initial Arriving Fare:', style: TextStyle(fontSize: 16)),
                          Text(_initialFareStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Hospital Trip Fare:', style: TextStyle(fontSize: 16)),
                          Text(_hospitalFareStr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(thickness: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Due:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(
                            _totalFareStr,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              ElevatedButton(
                onPressed: _loading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Cash Collected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
