const fs = require('fs');

function replaceInFile(filePath, replacements) {
  let content = fs.readFileSync(filePath, 'utf8');
  for (const [search, replace] of replacements) {
    content = content.replace(search, replace);
  }
  fs.writeFileSync(filePath, content);
}

// 1. admin_dashboard.dart
replaceInFile('lib/screens/dashboards/admin_dashboard.dart', [
  [/const Text\(\n\s*AppLocalizations/g, "Text(\n              AppLocalizations"],
  [/const Text\(AppLocalizations/g, "Text(AppLocalizations"],
  [/Tab\(icon: const Icon\(Icons\.people_alt_rounded\), text: AppLocalizations\.of\(context\)!\.employees\)/g, "Tab(icon: Icon(Icons.people_alt_rounded), text: 'Employees')"]
]);

// 2. hospital_selection_screen.dart
replaceInFile('lib/screens/hospital_selection_screen.dart', [
  [/import 'package:latlong2\/latlong\.dart';/g, "import 'package:latlong2/latlong.dart';\nimport '../../l10n/app_localizations.dart';"],
  [/const Text\(\n\s*AppLocalizations/g, "Text(\n                                AppLocalizations"],
  [/const Text\(AppLocalizations/g, "Text(AppLocalizations"]
]);

// 3. emt_tracking_screen.dart
replaceInFile('lib/screens/emt_tracking_screen.dart', [
  [/import '\.\.\/services\/agora_service\.dart';/g, "import '../services/agora_service.dart';\nimport '../l10n/app_localizations.dart';"],
  [/const Text\(\n\s*AppLocalizations/g, "Text(\n                                AppLocalizations"],
  [/const Text\(AppLocalizations/g, "Text(AppLocalizations"]
]);

console.log("Fixed analyze errors");
