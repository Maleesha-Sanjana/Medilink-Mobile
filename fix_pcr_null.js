const fs = require('fs');
const file = 'lib/screens/patient_care_report_screen.dart';
let content = fs.readFileSync(file, 'utf8');

content = content.replace(/v\['time'\], v\['pulse'\], v\['bp'\], v\['spo2'\]/g, "v['time']?.toString() ?? '', v['pulse']?.toString() ?? '', v['bp']?.toString() ?? '', v['spo2']?.toString() ?? ''");

fs.writeFileSync(file, content);
