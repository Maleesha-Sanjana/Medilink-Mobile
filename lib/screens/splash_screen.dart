import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'emt_tracking_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 1500), () async {
          if (!mounted) return;
          
          final prefs = await SharedPreferences.getInstance();
          final activeReqId = prefs.getString('active_request_id');
          final activeReqType = prefs.getString('active_request_type');
          
          if (!mounted) return;
          
          if (activeReqId != null && activeReqType != null && FirebaseAuth.instance.currentUser != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => EmtTrackingScreen(
                  requestId: activeReqId,
                  ambulanceType: activeReqType,
                ),
              ),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AuthGate()),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3A8C),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'STJ MediLink',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.top,
                  child: Text(
                    '\u207A',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
