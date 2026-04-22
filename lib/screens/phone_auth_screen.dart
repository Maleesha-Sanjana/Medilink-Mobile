import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/auth_error.dart';
import '../services/user_service.dart';
import '../main.dart';
import '../theme/theme_toggle_button.dart';
import '../theme/language_toggle_button.dart';
import '../l10n/app_localizations.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController(text: '+94');
  final _otpController = TextEditingController();
  final _auth = AuthService();

  bool _codeSent = false;
  bool _loading = false;
  String _verificationId = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone)) {
      _showError('Enter a valid number in E.164 format, e.g. +94771234567');
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.sendPhoneOtp(
        phoneNumber: phone,
        onAutoVerified: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          await _ensureUserDoc();
          _navigateToApp();
        },
        onFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _loading = false);
          // Show the raw error code to help debug
          _showError('${e.code}: ${e.message ?? authErrorMessage(e)}');
        },
        onCodeSent: (verificationId, _) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _loading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent! Check your SMS.'),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError(authErrorMessage(e));
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showError('Enter the 6-digit OTP');
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.verifyPhoneOtp(verificationId: _verificationId, smsCode: otp);
      await _ensureUserDoc();
      _navigateToApp();
    } on Exception catch (e) {
      if (!mounted) return;
      _showError(authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _ensureUserDoc() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final existing = await UserService().getUser(user.uid);
    if (existing == null) {
      await UserService().createUser(
        uid: user.uid,
        email: user.email ?? '',
        phone: user.phoneNumber ?? _phoneController.text.trim(),
        role: 'patient',
      );
    }
  }

  void _navigateToApp() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final fieldFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE0E0E0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ThemeToggleButton(),
                      LanguageToggleButton(),
                      SizedBox(width: 4),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'STJ MediLink',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A237E),
                                letterSpacing: 0.5,
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.top,
                              child: Text(
                                '\u207A',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1A237E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      _codeSent ? l.enterOtp : l.signInWithPhone,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _codeSent
                          ? 'Enter the 6-digit code sent to ${_phoneController.text}'
                          : 'Enter your number with country code\ne.g. +94771234567',
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Phone field
                    if (!_codeSent)
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 15, color: textColor),
                        decoration: InputDecoration(
                          hintText: '+94771234567',
                          hintStyle: const TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: Color(0xFF9FA8DA),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: fieldFill,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF2D3A8C),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                    // OTP field
                    if (_codeSent)
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 14,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: '------',
                          hintStyle: const TextStyle(
                            color: Color(0xFFBBBBBB),
                            fontSize: 24,
                            letterSpacing: 12,
                          ),
                          counterText: '',
                          filled: true,
                          fillColor: fieldFill,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFF2D3A8C),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : (_codeSent ? _verifyOtp : _sendOtp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D3A8C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _codeSent ? l.verifyOtp : l.sendOtp,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    if (_codeSent) ...[
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: _loading
                              ? null
                              : () => setState(() {
                                  _codeSent = false;
                                  _otpController.clear();
                                }),
                          child: const Text(
                            'Change number / Resend OTP',
                            style: TextStyle(
                              color: Color(0xFF2D3A8C),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
