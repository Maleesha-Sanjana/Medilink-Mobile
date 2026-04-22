import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/theme_toggle_button.dart';
import '../theme/language_toggle_button.dart';
import '../services/auth_service.dart';
import '../services/auth_error.dart';
import '../main.dart';
import 'phone_auth_screen.dart';
import '../l10n/app_localizations.dart';

// Multicolor Google "G" SVG
const _googleGSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.18 1.48-4.97 2.31-8.16 2.31-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>
''';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  final _auth = AuthService();

  void _navigate() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (_) => false,
    );
  }

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        phone: _contactController.text,
      );
      _navigate();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authErrorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final result = await _auth.signInWithGoogle();
      if (result) _navigate();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authErrorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _appleSignIn() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithApple();
      _navigate();
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authErrorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF888888);
    final fieldFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE0E0E0);
    final appleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: back arrow + theme toggle ────────────────
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

            // ── Scrollable content ────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // ── Logo centered ─────────────────────────────
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

                    const SizedBox(height: 40),

                    Text(
                      l.signupTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: _emailController,
                      hint: l.email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIconData: Icons.mail_outline_rounded,
                      fieldFill: fieldFill,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _contactController,
                      hint: l.contactNumber,
                      keyboardType: TextInputType.phone,
                      prefixIconData: Icons.phone_outlined,
                      fieldFill: fieldFill,
                      borderColor: borderColor,
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _passwordController,
                      hint: l.password,
                      obscure: _obscurePassword,
                      prefixIconData: Icons.lock_outline_rounded,
                      fieldFill: fieldFill,
                      borderColor: borderColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFAAAAAA),
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _confirmPasswordController,
                      hint: l.confirmPassword,
                      obscure: _obscureConfirm,
                      prefixIconData: Icons.lock_outline_rounded,
                      fieldFill: fieldFill,
                      borderColor: borderColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFAAAAAA),
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _signUp,
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
                                l.signUp,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(child: Divider(color: borderColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            l.orSignUpWith,
                            style: TextStyle(color: subTextColor, fontSize: 13),
                          ),
                        ),
                        Expanded(child: Divider(color: borderColor)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _SocialIconButton(
                            onTap: _loading ? () {} : _googleSignIn,
                            isDark: isDark,
                            child: SvgPicture.string(
                              _googleGSvg,
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SocialIconButton(
                            onTap: _loading ? () {} : _appleSignIn,
                            isDark: isDark,
                            child: FaIcon(
                              FontAwesomeIcons.apple,
                              color: appleColor,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _SocialIconButton(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PhoneAuthScreen(),
                              ),
                            ),
                            isDark: isDark,
                            child: const Icon(
                              Icons.phone_android_rounded,
                              color: Color(0xFF2D3A8C),
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 14),
                            children: [
                              TextSpan(
                                text: l.alreadyAccount,
                                style: TextStyle(color: subTextColor),
                              ),
                              TextSpan(
                                text: l.signInLink,
                                style: const TextStyle(
                                  color: Color(0xFF2D3A8C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    IconData? prefixIconData,
    required Color fieldFill,
    required Color borderColor,
  }) {
    return _ValidatedField(
      controller: controller,
      hint: hint,
      obscure: obscure,
      keyboardType: keyboardType,
      suffixIcon: suffixIcon,
      prefixIconData: prefixIconData,
      fieldFill: fieldFill,
    );
  }
}

// ── Validated field (blue when filled, red when empty) ───────────────────────

class _ValidatedField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final IconData? prefixIconData;
  final Color fieldFill;

  const _ValidatedField({
    required this.controller,
    required this.hint,
    required this.fieldFill,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIconData,
  });

  @override
  State<_ValidatedField> createState() => _ValidatedFieldState();
}

class _ValidatedFieldState extends State<_ValidatedField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    final filled = widget.controller.text.isNotEmpty;
    if (filled != _hasText) setState(() => _hasText = filled);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final idleBorder = _hasText ? const Color(0xFF2D3A8C) : Colors.red;
    final idleWidth = _hasText ? 1.5 : 1.2;

    return TextField(
      controller: widget.controller,
      obscureText: widget.obscure,
      keyboardType: widget.keyboardType,
      style: TextStyle(fontSize: 15, color: textColor),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 15),
        prefixIcon: widget.prefixIconData != null
            ? Icon(
                widget.prefixIconData,
                color: _hasText ? const Color(0xFF2D3A8C) : Colors.red.shade300,
                size: 20,
              )
            : null,
        suffixIcon: widget.suffixIcon,
        filled: true,
        fillColor: widget.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: idleBorder, width: idleWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: idleBorder, width: idleWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D3A8C), width: 2),
        ),
      ),
    );
  }
}

// ── Social icon-only button ───────────────────────────────────────────────────

class _SocialIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool isDark;

  const _SocialIconButton({
    required this.onTap,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
