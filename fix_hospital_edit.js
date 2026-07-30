const fs = require('fs');
const file = 'lib/screens/dashboards/admin_dashboard.dart';
let content = fs.readFileSync(file, 'utf8');

// 1. _HospitalDialog constructor
content = content.replace(
  "class _HospitalDialog extends StatefulWidget {\n  const _HospitalDialog();",
  "class _HospitalDialog extends StatefulWidget {\n  final Hospital? hospital;\n  const _HospitalDialog({super.key, this.hospital});"
);

// 2. initState
const initStateStr = `
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
`;
content = content.replace("  @override\n  void dispose() {", initStateStr);

// 3. _save method
const saveStart = `
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
`;

// Regex or replace to safely overwrite createHospital logic in _save
content = content.replace(/await HospitalService\(\)\.createHospital\([\s\S]*?features: _selectedFeatures,\n        \),\n      \);/m, "// replaced by edit logic");
content = content.replace("    setState(() => _loading = true);\n    try {\n      // replaced by edit logic", saveStart);

// 4. Update title logic
content = content.replace(
  "AppLocalizations.of(context)!.registerHospital,",
  "widget.hospital != null ? 'Edit Hospital' : AppLocalizations.of(context)!.registerHospital,"
);

// 5. Add Edit button to _HospitalCard
const editBtn = `
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
`;
content = content.replace("TextButton.icon(", editBtn);

fs.writeFileSync(file, content);
