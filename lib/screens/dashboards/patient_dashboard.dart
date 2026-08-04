import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../theme/theme_toggle_button.dart';
import '../../theme/language_toggle_button.dart';
import '../login_screen.dart';
import '../emergency_screen.dart';
import 'dart:math';
import '../profile_screen.dart';
import '../voice_call_screen.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : user?.email?.split('@').first ?? l10n.patient;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
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
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: l10n.profile,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.signOut,
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
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('emergency_requests')
              .where('uid', isEqualTo: user?.uid)
              .where('status', whereIn: ['pending', 'assigned', 'accepted', 'transporting', 'arrived', 'admin_call'])
              .snapshots(),
          builder: (context, snapshot) {
            final hasActiveCase = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
            final activeCaseDoc = hasActiveCase ? snapshot.data!.docs.first : null;
            final activeCaseData = activeCaseDoc?.data() as Map<String, dynamic>?;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  if (hasActiveCase) ...[
                    GestureDetector(
                      onTap: () {
                        // Navigate to tracking screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmergencyScreen(),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark 
                              ? [const Color(0xFF1E2F26), const Color(0xFF141F18)] 
                              : [Colors.red.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black38 : Colors.red.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.shade100,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.emergency_share_rounded, color: isDark ? Colors.red.shade400 : Colors.red.shade700, size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ACTIVE EMERGENCY',
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.red.shade400 : Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    activeCaseData?['status'] == 'transporting' ? 'Ambulance is arriving' : 'Waiting for ambulance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      letterSpacing: -0.5,
                                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to track your request',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded, color: isDark ? Colors.white54 : Colors.grey.shade500, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Welcome text ──────────────────────────────────
              Text(
                l10n.welcomeBack,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.grey.shade500,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),

              const SizedBox(height: 32),

              // ── Heading ───────────────────────────────────────
              Center(
                child: Text(
                  l10n.areYouInEmergency,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  l10n.pressButtonHelp,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),
              ),

              // ── SOS Button centered ───────────────────────────
              Expanded(
                child: Center(
                  child: _SosPulseButton(
                    onPressed: () {
                      _saveSosLocation();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmergencyScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // ── Call Admin Button ─────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, right: 16),
                  child: ElevatedButton(
                    onPressed: () => _callAdmin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(16),
                      elevation: 4,
                    ),
                    child: const Icon(Icons.call, size: 28),
                  ),
                ),
              ),

              // ── Location card ─────────────────────────────────
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.06,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.red.shade50,
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.yourCurrentLocation,
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
                            l10n.tapSosToShare,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  ),
);
}

  Future<void> _saveSosLocation() async {
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
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'lastLatitude': pos.latitude,
          'lastLongitude': pos.longitude,
          'lastSosTime': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Failed to save SOS location: $e');
    }
  }

  Future<void> _callAdmin(BuildContext context) async {
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
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final caseId = 'CASE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}-${Random().nextInt(9999).toString().padLeft(4, '0')}';
        final patientName = user.displayName?.isNotEmpty == true ? user.displayName! : (user.email?.split('@').first ?? 'Patient');
        
        final doc = await FirebaseFirestore.instance.collection('emergency_requests').add({
          'caseId': caseId,
          'uid': user.uid,
          'patientName': patientName,
          'ambulanceType': 'Emergency Ambulance',
          'price': 'LKR 5,000',
          'latitude': pos.latitude,
          'longitude': pos.longitude,
          'status': 'admin_call',
          'isAdminCall': true,
          'isMandatory': true,
          'rejectedBy': [],
          'createdAt': FieldValue.serverTimestamp(),
          'callState': 'ringing',
          'callInitiatedBy': user.uid,
          'callerName': patientName,
          'callerIsEmt': false,
          'callStartedAt': FieldValue.serverTimestamp(),
        });
        
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VoiceCallScreen(
                requestId: doc.id,
                callerName: patientName,
                receiverName: 'Admin',
                isIncoming: false,
                isEmt: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to call admin: $e');
    }
  }
}

// ── SOS Pulse Button ──────────────────────────────────────────────────────────

class _SosPulseButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _SosPulseButton({required this.onPressed});

  @override
  State<_SosPulseButton> createState() => _SosPulseButtonState();
}

class _SosPulseButtonState extends State<_SosPulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ring1;
  late Animation<double> _ring2;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _ring1 = Tween(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _ring2 = Tween(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 260 * _ring2.value,
                  height: 260 * _ring2.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(
                      alpha: 0.08 * (1 - _ctrl.value + 0.3),
                    ),
                  ),
                ),
                // Middle ring
                Container(
                  width: 210 * _ring1.value,
                  height: 210 * _ring1.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(
                      alpha: 0.14 * (1 - _ctrl.value + 0.3),
                    ),
                  ),
                ),
                // Core button
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.shade400,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                      ),
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
