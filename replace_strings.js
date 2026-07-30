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
  [/tabs: const \[/g, 'tabs: ['],
  [/Tab\(icon: Icon\(Icons\.local_hospital_rounded\), text: 'Hospitals'\)/g, "Tab(icon: const Icon(Icons.local_hospital_rounded), text: AppLocalizations.of(context)!.hospitalsTab)"],
  [/Tab\(icon: Icon\(Icons\.people_alt_rounded\), text: 'Employees'\)/g, "Tab(icon: const Icon(Icons.people_alt_rounded), text: AppLocalizations.of(context)!.employees)"], // Wait, employees might not be in l10n, let's keep others const if they were
  [/'No hospitals added yet'/g, "AppLocalizations.of(context)!.noHospitals"],
  [/'Add Hospital'/g, "AppLocalizations.of(context)!.addHospital"],
  [/'Register Hospital'/g, "AppLocalizations.of(context)!.registerHospital"],
  [/'Hospital Name'/g, "AppLocalizations.of(context)!.hospitalName"],
  [/'Location Acquired'/g, "AppLocalizations.of(context)!.locationAcquired"],
  [/'Fetch Current Location'/g, "AppLocalizations.of(context)!.fetchLocation"],
  [/'Register'/g, "AppLocalizations.of(context)!.register"],
  [/'Delete Hospital'/g, "AppLocalizations.of(context)!.deleteHospital"],
  [/'Delete hospital \$\{hospital\.name\}\?'/g, "AppLocalizations.of(context)!.deleteHospitalConfirm(hospital.name)"],
  [/'Hospital registered successfully!'/g, "AppLocalizations.of(context)!.hospitalRegistered"],
  [/'Please fetch the location first'/g, "AppLocalizations.of(context)!.fetchLocationFirst"],
  [/'Hospital name is required'/g, "AppLocalizations.of(context)!.hospitalNameRequired"],
  [/'Hospital deleted'/g, "AppLocalizations.of(context)!.hospitalDeleted"]
]);

// 2. hospital_selection_screen.dart
replaceInFile('lib/screens/hospital_selection_screen.dart', [
  [/'Select Destination'/g, "AppLocalizations.of(context)!.selectDestination"],
  [/'Distance: \$\{distance\.toStringAsFixed\(1\)\} km'/g, "AppLocalizations.of(context)!.distanceKm(distance.toStringAsFixed(1))"],
  [/'Estimated Fare: LKR \$\{fare\.toStringAsFixed\(0\)\}'/g, "AppLocalizations.of(context)!.estimatedFare(fare.toStringAsFixed(0))"],
  [/'Start Trip'/g, "AppLocalizations.of(context)!.startTrip"]
]);

// 3. emt_tracking_screen.dart
replaceInFile('lib/screens/emt_tracking_screen.dart', [
  [/'Arriving now'/g, "AppLocalizations.of(context)!.arrivingNow"],
  [/'\$\{mins\} min away'/g, "AppLocalizations.of(context)!.minAway(mins.toString())"],
  [/'\$\{meters\.round\(\)\} m away • \$timeStr'/g, "AppLocalizations.of(context)!.mAwayTime(meters.round().toString(), timeStr)"],
  [/'\$\{\(meters \/ 1000\)\.toStringAsFixed\(1\)\} km away • \$timeStr'/g, "AppLocalizations.of(context)!.kmAwayTime((meters / 1000).toStringAsFixed(1), timeStr)"],
  [/'Transporting to Hospital!'/g, "AppLocalizations.of(context)!.transportingToHospital"],
  [/'EMT is on the way!'/g, "AppLocalizations.of(context)!.emtOnTheWay"],
  [/'En Route to \$\{destName\}'/g, "AppLocalizations.of(context)!.enRouteTo(destName)"],
  [/'EMT Accepted & En Route'/g, "AppLocalizations.of(context)!.emtAcceptedEnRoute"],
  [/'Hospital Trip Fare: \$\{data\['hospitalTripPrice'\]\}'/g, "AppLocalizations.of(context)!.hospitalTripFare(data['hospitalTripPrice'].toString())"],
  [/'Live location updating every 5s'/g, "AppLocalizations.of(context)!.liveLocationUpdating"],
  [/'Waiting for EMT location…'/g, "AppLocalizations.of(context)!.waitingForEmtLocation"],
  [/'EMT Has Arrived!'/g, "AppLocalizations.of(context)!.emtHasArrived"],
  [/'The EMT is currently assessing the patient and filling out the initial Patient Care Report\. Please stand by\.'/g, "AppLocalizations.of(context)!.emtAssessing"],
  [/'Estimated Initial Fare \(Callout \+ EMT Travel\)'/g, "AppLocalizations.of(context)!.estimatedInitialFare"],
  [/'Calculating\.\.\.'/g, "AppLocalizations.of(context)!.calculating"]
]);

console.log("Replaced strings successfully");
