import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_error.dart';
import '../theme/theme_toggle_button.dart';
import '../theme/language_toggle_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    final l = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.emailRequired), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() {
        _emailSent = true;
        _loading = false;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authErrorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            // ── Top bar ───────────────────────────────────────────
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
                child: _emailSent
                    ? _SuccessView(
                        email: _emailController.text.trim(),
                        l: l,
                        isDark: isDark,
                        onBack: () => Navigator.pop(context),
                      )
                    : _FormView(
                        emailController: _emailController,
                        loading: _loading,
                        l: l,
                        isDark: isDark,
                        textColor: textColor,
                        fieldFill: fieldFill,
                        borderColor: borderColor,
                        onSend: _sendResetLink,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form view ─────────────────────────────────────────────────────────────────

class _FormView extends StatelessWidget {
  final TextEditingController emailController;
  final bool loading;
  final AppLocalizations l;
  final bool isDark;
  final Color textColor;
  final Color fieldFill;
  final Color borderColor;
  final VoidCallback onSend;

  const _FormView({
    required this.emailController,
    required this.loading,
    required this.l,
    required this.isDark,
    required this.textColor,
    required this.fieldFill,
    required this.borderColor,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),

        // Logo
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'STJ MediLink',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A237E),
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
                      color: isDark ? Colors.white : const Color(0xFF1A237E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Lock icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2D3A8C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 40,
              color: Color(0xFF2D3A8C),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          l.resetPassword,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),

        const SizedBox(height: 10),

        // Subtitle
        Text(
          l.resetPasswordSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFAAAAAA),
            height: 1.5,
          ),
        ),

        const SizedBox(height: 36),

        // Email field
        _ValidatedField(
          controller: emailController,
          hint: l.email,
          fieldFill: fieldFill,
          keyboardType: TextInputType.emailAddress,
          prefixIconData: Icons.mail_outline_rounded,
        ),

        const SizedBox(height: 28),

        // Send button
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: loading ? null : onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3A8C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    l.sendResetLink,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

// ── Success view ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  final String email;
  final AppLocalizations l;
  final bool isDark;
  final VoidCallback onBack;

  const _SuccessView({
    required this.email,
    required this.l,
    required this.isDark,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 60),

        // Success icon with animation
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 52,
              color: Colors.green,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Title
        Text(
          l.resetEmailSent,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 12),

        // Description with email highlighted
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFAAAAAA),
              height: 1.6,
            ),
            children: [TextSpan(text: l.resetEmailSentDesc(email))],
          ),
        ),

        const SizedBox(height: 10),

        // Spam warning
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Color(0xFFFFAA00),
            ),
            const SizedBox(width: 6),
            const Flexible(
              child: Text(
                "If you don't see it, check your spam or junk folder.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFFAA00),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Email chip
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D3A8C).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2D3A8C).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.mail_outline_rounded,
                  size: 16,
                  color: Color(0xFF2D3A8C),
                ),
                const SizedBox(width: 6),
                Text(
                  email,
                  style: const TextStyle(
                    color: Color(0xFF2D3A8C),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Back to login button
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3A8C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              l.backToLogin,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Validated field (blue when filled, red when empty) ───────────────────────

class _ValidatedField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final Color fieldFill;
  final TextInputType keyboardType;
  final IconData? prefixIconData;

  const _ValidatedField({
    required this.controller,
    required this.hint,
    required this.fieldFill,
    this.keyboardType = TextInputType.text,
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
