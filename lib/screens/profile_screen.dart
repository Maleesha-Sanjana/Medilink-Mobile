import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../theme/theme_toggle_button.dart';
import '../theme/language_toggle_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _user = FirebaseAuth.instance.currentUser;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emergNameCtrl = TextEditingController();
  final _emergPhoneCtrl = TextEditingController();
  final _medNotesCtrl = TextEditingController();

  // Dropdown values
  String? _gender;
  String? _bloodType;

  bool _loading = false;
  bool _uploading = false;
  bool _editing = false;
  Map<String, dynamic> _userData = {};
  String? _photoUrl;

  static const _bloodTypes = [
    'A+',
    'A−',
    'B+',
    'B−',
    'AB+',
    'AB−',
    'O+',
    'O−',
    'Unknown',
  ];

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
      final d = doc.data() ?? {};
      setState(() {
        _userData = d;
        _nameCtrl.text = d['displayName'] ?? '';
        _phoneCtrl.text = d['phone'] ?? '';
        _dobCtrl.text = d['dob'] ?? '';
        _addressCtrl.text = d['address'] ?? '';
        _emergNameCtrl.text = d['emergencyName'] ?? '';
        _emergPhoneCtrl.text = d['emergencyPhone'] ?? '';
        _medNotesCtrl.text = d['medicalNotes'] ?? '';
        _gender =
            [
              'Male',
              'Female',
              'Other',
              'Prefer not to say',
            ].contains(d['gender'])
            ? d['gender']
            : null;
        _bloodType = _bloodTypes.contains(d['bloodType'])
            ? d['bloodType']
            : null;
        _photoUrl = d['photoUrl'];
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 40,
        maxWidth: 300,
        maxHeight: 300,
      );
      if (picked == null) return;
      setState(() => _uploading = true);
      final bytes = await picked.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      if (base64Str.length > 900000) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.imageTooLarge),
              backgroundColor: Colors.red,
            ),
          );
        return;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({'photoUrl': base64Str});
      if (mounted) setState(() => _photoUrl = base64Str);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showImagePicker() {
    final l = AppLocalizations.of(context)!;
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
              title: Text(l.takePhoto),
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
              title: Text(l.chooseFromGallery),
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

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dobCtrl.text.isNotEmpty
          ? DateTime.tryParse(_dobCtrl.text) ?? DateTime(1990)
          : DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2D3A8C)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(
        () => _dobCtrl.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
      );
    }
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
            'dob': _dobCtrl.text.trim(),
            'gender': _gender ?? '',
            'bloodType': _bloodType ?? '',
            'address': _addressCtrl.text.trim(),
            'emergencyName': _emergNameCtrl.text.trim(),
            'emergencyPhone': _emergPhoneCtrl.text.trim(),
            'medicalNotes': _medNotesCtrl.text.trim(),
          });
      await _user.updateDisplayName(_nameCtrl.text.trim());
      if (mounted) {
        setState(() => _editing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _addressCtrl.dispose();
    _emergNameCtrl.dispose();
    _emergPhoneCtrl.dispose();
    _medNotesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tc = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final fill = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final border = isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
    final name = _nameCtrl.text.isNotEmpty
        ? _nameCtrl.text
        : _user?.email?.split('@').first ?? 'Patient';

    // Localized gender list — keys stay English for storage, display is localized
    final genderLabels = {
      'Male': l.genderMale,
      'Female': l.genderFemale,
      'Other': l.genderOther,
      'Prefer not to say': l.genderPreferNot,
    };
    final genderKeys = genderLabels.keys.toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          l.profile,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          const ThemeToggleButton(),
          const LanguageToggleButton(),
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l.editProfile,
              onPressed: () => setState(() => _editing = true),
            )
          else
            TextButton(
              onPressed: () => setState(() => _editing = false),
              child: Text(l.cancel),
            ),
          const SizedBox(width: 4),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Avatar ────────────────────────────────────────────
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
                              name[0].toUpperCase(),
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
                color: tc,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _user?.email ?? '',
              style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
            ),
            const SizedBox(height: 8),
            // Role + blood type badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Badge(
                  label: (_userData['role'] ?? 'patient')
                      .toString()
                      .toUpperCase(),
                  color: const Color(0xFF2D3A8C),
                ),
                if (_bloodType != null && _bloodType!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  _Badge(label: _bloodType!, color: Colors.red),
                ],
              ],
            ),

            const SizedBox(height: 28),

            // ── Section: Personal Info ────────────────────────────
            _SectionHeader(title: l.personalInfo, isDark: isDark),
            const SizedBox(height: 12),
            _Card(
              isDark: isDark,
              child: Column(
                children: [
                  _buildField(
                    label: l.fullName,
                    ctrl: _nameCtrl,
                    icon: Icons.person_outline_rounded,
                    fill: fill,
                    border: border,
                    tc: tc,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: l.email,
                    ctrl: TextEditingController(text: _user?.email ?? ''),
                    icon: Icons.mail_outline_rounded,
                    fill: fill,
                    border: border,
                    tc: tc,
                    enabled: false,
                  ),
                  const SizedBox(height: 14),
                  _buildPhoneField(fill: fill, border: border, tc: tc, l: l),
                  const SizedBox(height: 14),
                  // Date of Birth
                  _FieldLabel(label: l.dateOfBirth, tc: tc),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _editing ? _pickDob : null,
                    child: AbsorbPointer(
                      child: TextField(
                        controller: _dobCtrl,
                        enabled: _editing,
                        style: TextStyle(fontSize: 15, color: tc),
                        decoration: _fieldDeco(
                          icon: Icons.cake_outlined,
                          hint: 'YYYY-MM-DD',
                          fill: fill,
                          border: border,
                          enabled: _editing,
                          suffix: _editing
                              ? const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: Color(0xFF9FA8DA),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Gender dropdown
                  _FieldLabel(label: l.gender, tc: tc),
                  const SizedBox(height: 6),
                  _DropdownField(
                    value: _gender,
                    items: genderKeys,
                    labels: genderLabels,
                    hint: l.selectGender,
                    icon: Icons.wc_outlined,
                    enabled: _editing,
                    fill: fill,
                    border: border,
                    tc: tc,
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 14),
                  // Address
                  _FieldLabel(label: l.address, tc: tc),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _addressCtrl,
                    enabled: _editing,
                    maxLines: 2,
                    style: TextStyle(fontSize: 15, color: tc),
                    decoration: _fieldDeco(
                      icon: Icons.location_on_outlined,
                      hint: l.addressHint,
                      fill: fill,
                      border: border,
                      enabled: _editing,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section: Medical Info ─────────────────────────────
            _SectionHeader(title: l.medicalInfo, isDark: isDark),
            const SizedBox(height: 12),
            _Card(
              isDark: isDark,
              child: Column(
                children: [
                  // Blood type
                  _FieldLabel(label: l.bloodType, tc: tc),
                  const SizedBox(height: 6),
                  _DropdownField(
                    value: _bloodType,
                    items: _bloodTypes,
                    labels: null,
                    hint: l.selectBloodType,
                    icon: Icons.bloodtype_outlined,
                    enabled: _editing,
                    fill: fill,
                    border: border,
                    tc: tc,
                    onChanged: (v) => setState(() => _bloodType = v),
                  ),
                  const SizedBox(height: 14),
                  // Medical notes
                  _FieldLabel(label: l.medicalNotes, tc: tc),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _medNotesCtrl,
                    enabled: _editing,
                    maxLines: 3,
                    style: TextStyle(fontSize: 15, color: tc),
                    decoration: _fieldDeco(
                      icon: Icons.medical_information_outlined,
                      hint: l.medicalNotesHint,
                      fill: fill,
                      border: border,
                      enabled: _editing,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Section: Emergency Contact ────────────────────────
            _SectionHeader(title: l.emergencyContact, isDark: isDark),
            const SizedBox(height: 12),
            _Card(
              isDark: isDark,
              child: Column(
                children: [
                  _buildField(
                    label: l.contactName,
                    ctrl: _emergNameCtrl,
                    icon: Icons.person_pin_outlined,
                    fill: fill,
                    border: border,
                    tc: tc,
                  ),
                  const SizedBox(height: 14),
                  _buildField(
                    label: l.contactPhone,
                    ctrl: _emergPhoneCtrl,
                    icon: Icons.phone_outlined,
                    fill: fill,
                    border: border,
                    tc: tc,
                    keyboard: TextInputType.phone,
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
                      : Text(
                          l.saveChanges,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  // ── Phone field with SIM button ───────────────────────────────────────────
  Widget _buildPhoneField({
    required Color fill,
    required Color border,
    required Color tc,
    required AppLocalizations l,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: l.phoneNumber, tc: tc),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneCtrl,
                enabled: _editing,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: 15, color: tc),
                decoration: _fieldDeco(
                  icon: Icons.phone_outlined,
                  hint: '+94771234567',
                  fill: fill,
                  border: border,
                  enabled: _editing,
                ),
              ),
            ),
            if (_editing) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: l.useMyPhoneNumber,
                child: InkWell(
                  onTap: _pickPhoneFromDevice,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3A8C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2D3A8C).withValues(alpha: 0.3),
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
    );
  }

  void _pickPhoneFromDevice() {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.useDevicePhoneNumber),
        content: Text(l.enterPhoneDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
    required TextEditingController ctrl,
    required IconData icon,
    required Color fill,
    required Color border,
    required Color tc,
    bool enabled = true,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label, tc: tc),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          enabled: enabled,
          keyboardType: keyboard,
          style: TextStyle(fontSize: 15, color: tc),
          decoration: _fieldDeco(
            icon: icon,
            hint: '',
            fill: fill,
            border: border,
            enabled: enabled,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDeco({
    required IconData icon,
    required String hint,
    required Color fill,
    required Color border,
    required bool enabled,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF9FA8DA), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: enabled ? fill : fill.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2D3A8C), width: 1.5),
      ),
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF2D3A8C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final Color tc;
  const _FieldLabel({required this.label, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: tc.withValues(alpha: 0.6),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final Map<String, String>? labels; // optional localized display labels
  final String hint;
  final IconData icon;
  final bool enabled;
  final Color fill, border, tc;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.labels,
    required this.hint,
    required this.icon,
    required this.enabled,
    required this.fill,
    required this.border,
    required this.tc,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(
          hint,
          style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
        ),
        style: TextStyle(fontSize: 15, color: tc),
        dropdownColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF9FA8DA), size: 20),
          filled: true,
          fillColor: enabled ? fill : fill.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: border.withValues(alpha: 0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2D3A8C), width: 1.5),
          ),
        ),
        items: items
            .map(
              (key) => DropdownMenuItem(
                value: key,
                child: Text(labels?[key] ?? key),
              ),
            )
            .toList(),
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
