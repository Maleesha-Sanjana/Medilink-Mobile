const fs = require('fs');
const file = 'lib/screens/dashboards/admin_dashboard.dart';
let content = fs.readFileSync(file, 'utf8');

// Replace any remaining "const Text(" containing AppLocalizations with "Text("
content = content.replace(/const\s+Text\([\s\S]*?AppLocalizations/g, match => match.replace(/^const\s+Text\(/, 'Text('));

// Also some lists might be const and have Text(AppLocalizations...) inside.
// Actually, it's safer to just let the script do a global regex replace for const Text( ... AppLocalizations
fs.writeFileSync(file, content);

console.log("Fixed consts in admin_dashboard");
