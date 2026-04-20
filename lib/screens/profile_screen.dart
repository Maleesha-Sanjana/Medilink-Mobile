import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/theme_toggle_button.dart';
import '../theme/language_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  bool _uploading = false;
  bool _editing = false;
  Map<String, dynamic> _userData = {};
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (_user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .get();
    if (doc.exists && mounted) {
      setState(() {
        _userData = doc.data() ?? {};
        _nameCtrl.text = _userData['displayName'] ?? '';
        _phoneCtrl.text = _userData['phone'] ?? '';
        _photoUrl = _userData['photoUrl'];
      });
    }
  }

  // ── Pick image from gallery or camera ────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 40, // compress heavily to stay under Firestore 1MB limit
        maxWidth: 300,
        maxHeight: 300,
      );
      if (picked == null) return;

      setState(() => _uploading = true);

      final bytes = await picked.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Check size — Firestore doc limit is 1MB
      if (base64Str.length > 900000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image too large. Please choose a smaller image.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'photoUrl': base64Str});
      await _user.updatePhotoURL(null); // clear Firebase Auth photo URL

      if (mounted) setState(() => _photoUrl = base64Str);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8EAF6),
                child: Icon(Icons.camera_alt_rounded, color: Color(0xFF2D3A8C)),
              ),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8EAF6),
                child: Icon(
                  Icons.photo_library_rounded,
                  color: Color(0xFF2D3A8C),
                ),
              ),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .update({
            'displayName': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
          });
      await _user.updateDisplayName(_nameCtrl.text.trim());
      if (mounted) {
        setState(() => _editing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final fieldFill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE0E0E0);
    final name = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text
        : _user?.email?.split('@').first ?? 'Patient';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'P';

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          const ThemeToggleButton(),
          const LanguageToggleButton(),
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit profile',
              onPressed: () => setState(() => _editing = true),
            )
          else
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('Cancel'),
            ),
          const SizedBox(width: 4),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ── Avatar with upload ────────────────────────────────
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: const Color(0xFF2D3A8C),
                      backgroundImage: _photoUrl != null
                          ? (_photoUrl!.startsWith('data:image')
                                ? MemoryImage(
                                    base64Decode(_photoUrl!.split(',').last),
                                  )
                                : NetworkImage(_photoUrl!) as ImageProvider)
                          : null,
                      child: _uploading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : _photoUrl == null
                          ? Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3A8C),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF121212)
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _user?.email ?? '',
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
            ),

            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3A8C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                (_userData['role'] ?? 'patient').toString().toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF2D3A8C),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Info card ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildField(
                    label: 'Full Name',
                    controller: _nameCtrl,
                    icon: Icons.person_outline_rounded,
                    enabled: _editing,
                    fieldFill: fieldFill,
                    borderColor: borderColor,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    label: 'Email',
                    controller: TextEditingController(text: _user?.email ?? ''),
                    icon: Icons.mail_outline_rounded,
                    enabled: false,
                    fieldFill: fieldFill,
                    borderColor: borderColor,
                    textColor: textColor,
                  ),
                  const SizedBox(height: 16),

                  // Phone field with device picker button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Number',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _phoneCtrl,
                              enabled: _editing,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(fontSize: 15, color: textColor),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.phone_outlined,
                                  color: Color(0xFF9FA8DA),
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: _editing
                                    ? fieldFill
                                    : fieldFill.withValues(alpha: 0.5),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: borderColor),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: borderColor.withValues(alpha: 0.5),
                                  ),
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
                          ),
                          if (_editing) ...[
                            const SizedBox(width: 8),
                            // Get from device button
                            Tooltip(
                              message: 'Use my phone number',
                              child: InkWell(
                                onTap: _pickPhoneFromDevice,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 52,
                                  width: 52,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2D3A8C,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF2D3A8C,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.sim_card_outlined,
                                    color: Color(0xFF2D3A8C),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (_editing)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3A8C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Pick phone number from device ─────────────────────────────────────────
  void _pickPhoneFromDevice() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Use Device Phone Number'),
        content: const Text(
          'Enter your phone number with country code (e.g. +94771234567).\n\nYou can also type it directly in the field.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Pre-fill with +94 country code if empty
              if (_phoneCtrl.text.isEmpty) {
                _phoneCtrl.text = '+94';
                _phoneCtrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: _phoneCtrl.text.length),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3A8C),
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    required Color fieldFill,
    required Color borderColor,
    required Color textColor,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboard,
          style: TextStyle(fontSize: 15, color: textColor),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF9FA8DA), size: 20),
            filled: true,
            fillColor: enabled ? fieldFill : fieldFill.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
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
      ],
    );
  }
}
