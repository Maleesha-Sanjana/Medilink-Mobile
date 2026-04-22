import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'emt_tracking_screen.dart';

/// Shown after a patient submits an emergency request.
/// Listens to the Firestore doc and auto-navigates when status → "accepted".
class WaitingScreen extends StatefulWidget {
  final String requestId;
  final String ambulanceType;

  const WaitingScreen({
    super.key,
    required this.requestId,
    required this.ambulanceType,
  });

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulse = Tween(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  Future<void> _cancelRequest() async {
    await FirebaseFirestore.instance
        .collection('emergency_requests')
        .doc(widget.requestId)
        .update({'status': 'cancelled'});
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F6FA);

    return PopScope(
      canPop: false, // prevent back-swipe; user must cancel explicitly
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergency_requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final status = data['status'] as String? ?? 'pending';

          // Auto-navigate when accepted
          if (status == 'accepted') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _showAcceptedAndPop(context);
            });
          }

          return Scaffold(
            backgroundColor: bg,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Animated ambulance icon ───────────────
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, child) =>
                          Transform.scale(scale: _pulse.value, child: child),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer ring 1
                          _Ring(size: 200, color: Colors.red, opacity: 0.06),
                          // Outer ring 2
                          _Ring(size: 160, color: Colors.red, opacity: 0.10),
                          // Outer ring 3
                          _Ring(size: 120, color: Colors.red, opacity: 0.16),
                          // Core circle
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red.shade400,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.35),
                                  blurRadius: 24,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.emergency_rounded,
                              color: Colors.white,
                              size: 44,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ── Title ─────────────────────────────────
                    Text(
                      'Help is on the way!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Subtitle ──────────────────────────────
                    Text(
                      'Your ${widget.ambulanceType} request has been sent.\nWaiting for an EMT to accept…',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // ── Spinning loader ───────────────────────
                    RotationTransition(
                      turns: _rotateCtrl,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.red.shade400,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Searching for nearby EMTs…',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // ── Request info card ─────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.ambulanceType,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Status: Pending',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'PENDING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange.shade700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Cancel button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _cancelRequest,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel Request',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAcceptedAndPop(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE8F5E9),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'EMT Accepted!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'An EMT has accepted your request and is on the way to your location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                // Replace waiting screen with live tracking screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => EmtTrackingScreen(
                      requestId: widget.requestId,
                      ambulanceType: widget.ambulanceType,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Track EMT',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper ────────────────────────────────────────────────────────────────────

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Ring({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}
