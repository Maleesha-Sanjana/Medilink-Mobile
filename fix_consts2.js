const fs = require('fs');
const file = 'lib/screens/dashboards/admin_dashboard.dart';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(/const SnackBar\(/g, 'SnackBar(');
content = content.replace(/title: const Row\(\n\s*children: \[\n\s*Icon\(Icons\.add_location_alt_rounded/g, 'title: Row(\n        children: [\n          const Icon(Icons.add_location_alt_rounded');

fs.writeFileSync(file, content);

console.log("Fixed consts in admin_dashboard");
