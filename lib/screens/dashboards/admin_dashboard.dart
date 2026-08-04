import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_user.dart';
import '../../models/ambulance_vehicle.dart';
import '../../models/driver.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/driver_service.dart';
import '../../theme/theme_toggle_button.dart';
import '../../theme/language_toggle_button.dart';
import '../../l10n/app_localizations.dart';
import '../login_screen.dart';
import '../voice_call_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/hospital.dart';
import '../../services/hospital_service.dart';
import 'package:geolocator/geolocator.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _mainTabController;
  bool _callScreenShown = false;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emergency_requests')
          .where('isAdminCall', isEqualTo: true)
          .where('callState', isEqualTo: 'ringing')
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final req = snapshot.data!.docs.first;
          final reqData = req.data() as Map<String, dynamic>;
          final callInitiatedBy = reqData['callInitiatedBy'] as String? ?? '';
          
          if (callInitiatedBy != _uid && !_callScreenShown) {
            _callScreenShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncomingCallScreen(
                      requestId: req.id,
                      callerName: reqData['callerName'] ?? 'Patient',
                      callerIsEmt: reqData['callerIsEmt'] ?? false,
                      myName: 'Admin',
                    ),
                  ),
                );
              }
            });
          }
        } else {
          // Reset when there are no active incoming calls
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _callScreenShown) {
              setState(() => _callScreenShown = false);
            }
          });
        }
        
        return Scaffold(
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
            icon: const Icon(Icons.logout_rounded),
            tooltip: l.signOut,
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
        bottom: TabBar(
          controller: _mainTabController,
          tabs: [
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Employees'),
            Tab(icon: Icon(Icons.airport_shuttle_rounded), text: 'Vehicles'),
            Tab(icon: Icon(Icons.people_rounded), text: 'Patients'),
            Tab(icon: const Icon(Icons.local_hospital_rounded), text: AppLocalizations.of(context)!.hospitalsTab),
            const Tab(icon: Icon(Icons.call_rounded), text: 'Calls'),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: TabBarView(
        controller: _mainTabController,
        children: [
          _EmployeesTab(),
          const _VehiclesTab(),
          _PatientList(),
          const _HospitalsTab(),
          const _ActiveCallsTab(),
        ],
      ),
    );
      },
    );
  }
}

// ── Employees Tab ─────────────────────────────────────────────────────────────

class _EmployeesTab extends StatefulWidget {
  @override
  State<_EmployeesTab> createState() => _EmployeesTabState();
}

class _EmployeesTabState extends State<_EmployeesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.emergency_rounded, size: 18),
              text: l.ambulance,
            ),
            Tab(
              icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
              text: l.admins,
            ),
            const Tab(
              icon: Icon(Icons.drive_eta_rounded, size: 18),
              text: 'Drivers',
            ),
          ],
        ),
        Expanded(
          child: Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _UserList(role: 'emt'),
                  _UserList(role: 'admin'),
                  const _DriverList(),
                ],
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  heroTag: 'emp_fab',
                  onPressed: () {
                    if (_tabController.index == 3) {
                      showDialog(
                        context: context,
                        builder: (_) => const _DriverDialog(),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => _CreateUserDialog(
                          role: _tabController.index == 0 ? 'emt' : 'admin',
                        ),
                      );
                    }
                  },
                  backgroundColor: const Color(0xFF2D3A8C),
                  icon: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    _tabController.index == 3 ? 'Add Driver' : l.createAccount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Vehicles Tab ──────────────────────────────────────────────────────────────

class _VehiclesTab extends StatelessWidget {
  const _VehiclesTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        StreamBuilder<List<AmbulanceVehicle>>(
          stream: VehicleService().streamVehicles(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final vehicles = snap.data ?? [];
            if (vehicles.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.airport_shuttle_rounded,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No vehicles added yet',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: vehicles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  _VehicleCard(vehicle: vehicles[i], isDark: isDark),
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'veh_fab',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const _VehicleDialog(),
            ),
            backgroundColor: Colors.red,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              'Add Vehicle',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Vehicle Card ──────────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  final AmbulanceVehicle vehicle;
  final bool isDark;
  const _VehicleCard({required this.vehicle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3A8C).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.airport_shuttle_rounded,
                  color: Color(0xFF2D3A8C),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.vehicleNumber,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          if (vehicle.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              vehicle.notes!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => _VehicleDialog(vehicle: vehicle),
                ),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2D3A8C),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Delete vehicle ${vehicle.vehicleNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await VehicleService().deleteVehicle(vehicle.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vehicle deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Vehicle Dialog (create/edit) ──────────────────────────────────────────────

class _VehicleDialog extends StatefulWidget {
  final AmbulanceVehicle? vehicle;
  const _VehicleDialog({this.vehicle});
  @override
  State<_VehicleDialog> createState() => _VehicleDialogState();
}

class _VehicleDialogState extends State<_VehicleDialog> {
  late TextEditingController _numberCtrl;
  late TextEditingController _notesCtrl;
  late String _type;
  late String _status;
  bool _loading = false;

  final _types = ['Basic', 'Advanced', 'ICU', 'Neonatal'];
  final _statuses = ['available', 'on_duty', 'maintenance'];
  final _statusLabels = {
    'available': 'Available',
    'on_duty': 'On Duty',
    'maintenance': 'Maintenance',
  };

  bool get _isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _numberCtrl = TextEditingController(text: v?.vehicleNumber ?? '');
    _notesCtrl = TextEditingController(text: v?.notes ?? '');
    _type = v?.type ?? 'Basic';
    _status = v?.status ?? 'available';
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_numberCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle number is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final data = {
        'vehicleNumber': _numberCtrl.text.trim(),
        'type': _type,
        'status': _status,
        'notes': _notesCtrl.text.trim(),
      };
      if (_isEdit) {
        await VehicleService().updateVehicle(widget.vehicle!.id, data);
      } else {
        await VehicleService().createVehicle(
          AmbulanceVehicle.fromMap('', data),
        );
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Vehicle updated' : 'Vehicle added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEdit ? Icons.edit_outlined : Icons.add_rounded,
            color: const Color(0xFF2D3A8C),
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            _isEdit ? 'Edit Vehicle' : 'Add Vehicle',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _f(
              _numberCtrl,
              'Vehicle Number',
              Icons.confirmation_number_outlined,
            ),

            _f(_notesCtrl, 'Notes (optional)', Icons.notes_rounded),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D3A8C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(_isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _f(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF9FA8DA), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

// ── User List ─────────────────────────────────────────────────────────────────

class _UserList extends StatelessWidget {
  final String role;
  const _UserList({required this.role});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<List<AppUser>>(
      stream: UserService().streamUsersByRole(role),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snap.data ?? [];
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  role == 'emt'
                      ? Icons.emergency_rounded
                      : Icons.admin_panel_settings_rounded,
                  size: 56,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No ${role == 'emt' ? 'EMT' : 'Admin'} accounts yet',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _UserCard(user: users[i], isDark: isDark),
        );
      },
    );
  }
}

// ── Patient List (read-only) ──────────────────────────────────────────────────

class _PatientList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<List<AppUser>>(
      stream: UserService().streamUsersByRole('patient'),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final patients = snap.data ?? [];
        if (patients.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_rounded,
                  size: 56,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No patients yet',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: patients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _PatientCard(user: patients[i], isDark: isDark),
        );
      },
    );
  }
}

class _PatientCard extends StatelessWidget {
  final AppUser user;
  final bool isDark;
  const _PatientCard({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, snap) {
              String? photoUrl;
              if (snap.hasData && snap.data!.exists) {
                photoUrl =
                    (snap.data!.data() as Map<String, dynamic>?)?['photoUrl'];
              }
              final initials =
                  (user.displayName?.isNotEmpty == true
                          ? user.displayName!
                          : user.email)
                      .substring(0, 1)
                      .toUpperCase();
              return CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF2D3A8C),
                backgroundImage: photoUrl != null
                    ? (photoUrl.startsWith('data:image')
                          ? MemoryImage(base64Decode(photoUrl.split(',').last))
                          : NetworkImage(photoUrl) as ImageProvider)
                    : null,
                child: photoUrl == null
                    ? Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    : null,
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName?.isNotEmpty == true
                      ? user.displayName!
                      : user.email,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                if (user.displayName?.isNotEmpty == true)
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 12,
                    ),
                  ),
                if (user.phone?.isNotEmpty == true)
                  Text(
                    user.phone!,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Patient',
              style: TextStyle(
                color: Color(0xFF2D3A8C),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── User Card (ambulance/admin) ───────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final AppUser user;
  final bool isDark;
  const _UserCard({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isEmt = user.role == 'emt';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isEmt
                ? Colors.red.shade50
                : const Color(0xFFE8EAF6),
            child: Icon(
              isEmt
                  ? Icons.emergency_rounded
                  : Icons.admin_panel_settings_rounded,
              color: isEmt ? Colors.red : const Color(0xFF2D3A8C),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName?.isNotEmpty == true
                      ? user.displayName!
                      : user.email,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                if (user.displayName?.isNotEmpty == true)
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 12,
                    ),
                  ),
                if (user.phone?.isNotEmpty == true)
                  Text(
                    user.phone!,
                    style: const TextStyle(
                      color: Color(0xFFAAAAAA),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF2D3A8C),
              size: 22,
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _EditUserDialog(user: user),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 22,
            ),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Delete ${user.displayName?.isNotEmpty == true ? user.displayName : user.email}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await UserService().deleteUser(user.uid);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Create User Dialog ────────────────────────────────────────────────────────

class _CreateUserDialog extends StatefulWidget {
  final String role;
  const _CreateUserDialog({required this.role});
  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email and password are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_passCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService().createAccountByAdmin(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        role: widget.role,
        displayName: _nameCtrl.text,
        phone: _phoneCtrl.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.role == 'emt' ? 'EMT' : 'Admin'} account created!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmt = widget.role == 'emt';
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isEmt
                ? Icons.emergency_rounded
                : Icons.admin_panel_settings_rounded,
            color: isEmt ? Colors.red : const Color(0xFF2D3A8C),
            size: 22,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Create ${isEmt ? 'EMT' : 'Admin'} Account',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _f(_nameCtrl, 'Full Name', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _f(
              _emailCtrl,
              'Email',
              Icons.mail_outline_rounded,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _f(
              _phoneCtrl,
              'Phone Number',
              Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Password',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF9FA8DA),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFFAAAAAA),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _create,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D3A8C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Widget _f(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF9FA8DA), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

// ── Edit User Dialog ──────────────────────────────────────────────────────────

class _EditUserDialog extends StatefulWidget {
  final AppUser user;
  const _EditUserDialog({required this.user});
  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _passCtrl;
  late String _selectedRole;
  bool _obscure = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.displayName ?? '');
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
    _passCtrl = TextEditingController();
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await UserService().updateUser(
        widget.user.uid,
        displayName: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        role: _selectedRole,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.edit_outlined, color: Color(0xFF2D3A8C), size: 22),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Edit ${widget.user.displayName?.isNotEmpty == true ? widget.user.displayName : widget.user.email}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _f(_nameCtrl, 'Full Name', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _f(
              _emailCtrl,
              'Email',
              Icons.mail_outline_rounded,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _f(
              _phoneCtrl,
              'Phone Number',
              Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'New Password (leave blank to keep)',
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFF9FA8DA),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFFAAAAAA),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.badge_outlined,
                  color: Color(0xFF9FA8DA),
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'patient', child: Text('Patient')),
                DropdownMenuItem(value: 'emt', child: Text('EMT')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D3A8C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _f(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF9FA8DA), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

// ── Driver List ───────────────────────────────────────────────────────────────

class _DriverList extends StatelessWidget {
  const _DriverList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<List<Driver>>(
      stream: DriverService().streamDrivers(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final drivers = snap.data ?? [];
        if (drivers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.drive_eta_rounded,
                  size: 56,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'No drivers added yet',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: drivers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _DriverCard(driver: drivers[i], isDark: isDark),
        );
      },
    );
  }
}

// ── Driver Card ───────────────────────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
  final Driver driver;
  final bool isDark;
  const _DriverCard({required this.driver, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal.shade50,
            child: const Icon(
              Icons.drive_eta_rounded,
              color: Colors.teal,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  driver.phone,
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'License: ${driver.licenseNumber}',
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 12,
                  ),
                ),
                if (driver.assignedVehicle?.isNotEmpty == true)
                  Text(
                    'Vehicle: ${driver.assignedVehicle}',
                    style: const TextStyle(
                      color: Color(0xFF2D3A8C),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF2D3A8C),
              size: 22,
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => _DriverDialog(driver: driver),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 22,
            ),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Driver'),
        content: Text('Delete driver ${driver.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DriverService().deleteDriver(driver.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Driver deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Driver Dialog (create/edit) ───────────────────────────────────────────────

class _DriverDialog extends StatefulWidget {
  final Driver? driver;
  const _DriverDialog({this.driver});
  @override
  State<_DriverDialog> createState() => _DriverDialogState();
}

class _DriverDialogState extends State<_DriverDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _licenseCtrl;
  late TextEditingController _vehicleCtrl;
  late TextEditingController _notesCtrl;
  bool _loading = false;

  bool get _isEdit => widget.driver != null;

  @override
  void initState() {
    super.initState();
    final d = widget.driver;
    _nameCtrl = TextEditingController(text: d?.name ?? '');
    _phoneCtrl = TextEditingController(text: d?.phone ?? '');
    _licenseCtrl = TextEditingController(text: d?.licenseNumber ?? '');
    _vehicleCtrl = TextEditingController(text: d?.assignedVehicle ?? '');
    _notesCtrl = TextEditingController(text: d?.notes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _licenseCtrl.dispose();
    _vehicleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty ||
        _licenseCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name, phone and license number are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'licenseNumber': _licenseCtrl.text.trim(),
        'assignedVehicle': _vehicleCtrl.text.trim(),
        'notes': _notesCtrl.text.trim(),
      };
      if (_isEdit) {
        await DriverService().updateDriver(widget.driver!.id, data);
      } else {
        await DriverService().createDriver(Driver.fromMap('', data));
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Driver updated' : 'Driver added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEdit ? Icons.edit_outlined : Icons.person_add_rounded,
            color: Colors.teal,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            _isEdit ? 'Edit Driver' : 'Add Driver',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _f(_nameCtrl, 'Full Name', Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _f(
              _phoneCtrl,
              'Phone Number',
              Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            _f(_licenseCtrl, 'License Number', Icons.badge_outlined),
            const SizedBox(height: 12),
            _f(_notesCtrl, 'Notes (optional)', Icons.notes_rounded),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(_isEdit ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Widget _f(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF9FA8DA), size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

// ── Hospitals Tab ────────────────────────────────────────────────────────────

class _HospitalsTab extends StatelessWidget {
  const _HospitalsTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        StreamBuilder<List<Hospital>>(
          stream: HospitalService().streamHospitals(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final hospitals = snap.data ?? [];
            if (hospitals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_hospital_rounded,
                      size: 56,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.noHospitals,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: hospitals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) =>
                  _HospitalCard(hospital: hospitals[i], isDark: isDark),
            );
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'hosp_fab',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const _HospitalDialog(),
            ),
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.add_location_alt_rounded, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.addHospital,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final bool isDark;
  const _HospitalCard({required this.hospital, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            hospital.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hospital.status == 'pending' 
                                ? Colors.orange.withValues(alpha: 0.2) 
                                : Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            hospital.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: hospital.status == 'pending' ? Colors.orange : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${hospital.latitude.toStringAsFixed(4)}, Lng: ${hospital.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hospital.status == 'pending')
                TextButton.icon(
                  onPressed: () async {
                    await HospitalService().updateHospital(hospital.id, {'status': 'approved'});
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Approve'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _HospitalDialog(hospital: hospital),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              TextButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteHospital),
        content: Text(AppLocalizations.of(context)!.deleteHospitalConfirm(hospital.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await HospitalService().deleteHospital(hospital.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.hospitalDeleted),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HospitalDialog extends StatefulWidget {
  final Hospital? hospital;
  const _HospitalDialog({super.key, this.hospital});
  @override
  State<_HospitalDialog> createState() => _HospitalDialogState();
}

class _HospitalDialogState extends State<_HospitalDialog> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  Position? _position;
  final List<String> _availableFeatures = ['X-Ray', 'ICU', 'Trauma Center', 'Cardiology', 'Neurology', 'Burn Unit', 'Maternity'];
  List<String> _selectedFeatures = [];

  @override
  void initState() {
    super.initState();
    if (widget.hospital != null) {
      _nameCtrl.text = widget.hospital!.name;
      _position = Position(
        longitude: widget.hospital!.longitude,
        latitude: widget.hospital!.latitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      _selectedFeatures = List.from(widget.hospital!.features);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _loading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _position = pos);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.hospitalNameRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fetchLocationFirst),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      if (widget.hospital != null) {
        await HospitalService().updateHospital(
          widget.hospital!.id,
          {
            'name': _nameCtrl.text.trim(),
            'latitude': _position!.latitude,
            'longitude': _position!.longitude,
            'features': _selectedFeatures,
          },
        );
      } else {
        await HospitalService().createHospital(
          Hospital(
            id: '',
            name: _nameCtrl.text.trim(),
            latitude: _position!.latitude,
            longitude: _position!.longitude,
            features: _selectedFeatures,
          ),
        );
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.hospitalRegistered),
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.add_location_alt_rounded, color: Colors.blue, size: 22),
          SizedBox(width: 8),
          Text(
            widget.hospital != null ? 'Edit Hospital' : AppLocalizations.of(context)!.registerHospital,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.hospitalName,
              prefixIcon: const Icon(Icons.local_hospital_rounded, color: Color(0xFF9FA8DA), size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          
          const SizedBox(height: 16),
          const Text('Hospital Features', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableFeatures.map((f) {
              final isSel = _selectedFeatures.contains(f);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSel) {
                      _selectedFeatures.remove(f);
                    } else {
                      _selectedFeatures.add(f);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                    border: Border.all(color: isSel ? Colors.blue : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(f, style: TextStyle(fontSize: 12, color: isSel ? Colors.blue : Colors.grey.shade700)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (_position != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.green),
                  const SizedBox(height: 4),
                  Text(AppLocalizations.of(context)!.locationAcquired, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text(
                    'Lat: ${_position!.latitude.toStringAsFixed(4)}\nLng: ${_position!.longitude.toStringAsFixed(4)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _loading ? null : _fetchLocation,
              icon: const Icon(Icons.my_location_rounded),
              label: Text(AppLocalizations.of(context)!.fetchLocation),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _loading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(AppLocalizations.of(context)!.register),
        ),
      ],
    );
  }
}

class _ActiveCallsTab extends StatelessWidget {
  const _ActiveCallsTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emergency_requests')
          .where('isAdminCall', isEqualTo: true)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        var docs = snap.data?.docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          return data['status'] != 'completed' && data['status'] != 'cancelled';
        }).toList() ?? [];

        docs.sort((a, b) {
          final tA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          final tB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          if (tA == null || tB == null) return 0;
          return tB.compareTo(tA);
        });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.call_end_rounded, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('No active admin calls', style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final doc = docs[i];
            final data = doc.data() as Map<String, dynamic>;
            final patientName = data['patientName'] ?? 'Patient';
            final status = data['status'] as String? ?? '';
            
            String statusText;
            Color statusColor;
            bool canAssign = false;

            if (status == 'admin_call') {
              statusText = 'Needs EMT Assignment';
              statusColor = Colors.red;
              canAssign = true;
            } else if (status == 'assigned') {
              statusText = 'Assigned to EMT';
              statusColor = Colors.orange;
            } else if (status == 'accepted') {
              statusText = 'EMT En Route';
              statusColor = Colors.blue;
            } else {
              statusText = status.toUpperCase();
              statusColor = Colors.grey;
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.emergency_rounded, color: statusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(statusText, style: TextStyle(color: statusColor, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (canAssign)
                    ElevatedButton(
                      onPressed: () => _assignEmt(context, doc.id),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D3A8C), foregroundColor: Colors.white),
                      child: const Text('Assign EMT'),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _assignEmt(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select EMT to Assign'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'emt').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) return const CircularProgressIndicator();
              final emts = snap.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: emts.length,
                itemBuilder: (context, i) {
                  final emt = emts[i].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(emt['displayName'] ?? emt['email'] ?? 'EMT'),
                    onTap: () async {
                      await FirebaseFirestore.instance.collection('emergency_requests').doc(requestId).update({
                        'status': 'assigned',
                        'assignedEmtUid': emts[i].id,
                      });
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

