const fs = require('fs');

const enExtras = {
  "hospitalsTab": "Hospitals",
  "noHospitals": "No hospitals added yet",
  "addHospital": "Add Hospital",
  "registerHospital": "Register Hospital",
  "hospitalName": "Hospital Name",
  "locationAcquired": "Location Acquired",
  "fetchLocation": "Fetch Current Location",
  "register": "Register",
  "deleteHospital": "Delete Hospital",
  "deleteHospitalConfirm": "Delete hospital {name}?",
  "@deleteHospitalConfirm": {
    "placeholders": {
      "name": { "type": "String" }
    }
  },
  "hospitalRegistered": "Hospital registered successfully!",
  "fetchLocationFirst": "Please fetch the location first",
  "hospitalNameRequired": "Hospital name is required",
  "hospitalDeleted": "Hospital deleted",
  "selectDestination": "Select Destination",
  "distanceKm": "Distance: {distance} km",
  "@distanceKm": {
    "placeholders": {
      "distance": { "type": "String" }
    }
  },
  "estimatedFare": "Estimated Fare: {fare}",
  "@estimatedFare": {
    "placeholders": {
      "fare": { "type": "String" }
    }
  },
  "startTrip": "Start Trip",
  "arrivingNow": "Arriving now",
  "minAway": "{mins} min away",
  "@minAway": {
    "placeholders": {
      "mins": { "type": "String" }
    }
  },
  "mAwayTime": "{meters} m away • {timeStr}",
  "@mAwayTime": {
    "placeholders": {
      "meters": { "type": "String" },
      "timeStr": { "type": "String" }
    }
  },
  "kmAwayTime": "{km} km away • {timeStr}",
  "@kmAwayTime": {
    "placeholders": {
      "km": { "type": "String" },
      "timeStr": { "type": "String" }
    }
  },
  "transportingToHospital": "Transporting to Hospital!",
  "emtOnTheWay": "EMT is on the way!",
  "hospital": "Hospital",
  "ambulanceWord": "Ambulance",
  "enRouteTo": "En Route to {hospitalName}",
  "@enRouteTo": {
    "placeholders": {
      "hospitalName": { "type": "String" }
    }
  },
  "emtAcceptedEnRoute": "EMT Accepted & En Route",
  "hospitalTripFare": "Hospital Trip Fare: {price}",
  "@hospitalTripFare": {
    "placeholders": {
      "price": { "type": "String" }
    }
  },
  "liveLocationUpdating": "Live location updating every 5s",
  "waitingForEmtLocation": "Waiting for EMT location…",
  "emtHasArrived": "EMT Has Arrived!",
  "emtAssessing": "The EMT is currently assessing the patient and filling out the initial Patient Care Report. Please stand by.",
  "estimatedInitialFare": "Estimated Initial Fare (Callout + EMT Travel)",
  "calculating": "Calculating...",
  "statusPending": "Status: Pending",
  "pending": "PENDING"
};

const siExtras = {
  "hospitalsTab": "රෝහල්",
  "noHospitals": "තවමත් රෝහල් එකතු කර නොමැත",
  "addHospital": "රෝහලක් එකතු කරන්න",
  "registerHospital": "රෝහල ලියාපදිංචි කරන්න",
  "hospitalName": "රෝහලේ නම",
  "locationAcquired": "ස්ථානය ලබා ගෙන ඇත",
  "fetchLocation": "වත්මන් ස්ථානය ලබා ගන්න",
  "register": "ලියාපදිංචි කරන්න",
  "deleteHospital": "රෝහල මකන්න",
  "deleteHospitalConfirm": "මකා දමන්නද {name}?",
  "@deleteHospitalConfirm": {
    "placeholders": {
      "name": { "type": "String" }
    }
  },
  "hospitalRegistered": "රෝහල සාර්ථකව ලියාපදිංචි කරන ලදි!",
  "fetchLocationFirst": "කරුණාකර පළමුව ස්ථානය ලබා ගන්න",
  "hospitalNameRequired": "රෝහලේ නම අවශ්‍යයි",
  "hospitalDeleted": "රෝහල මකා දමන ලදි",
  "selectDestination": "ගමනාන්තය තෝරන්න",
  "distanceKm": "දුර: කි.මී. {distance}",
  "@distanceKm": {
    "placeholders": {
      "distance": { "type": "String" }
    }
  },
  "estimatedFare": "ඇස්තමේන්තු ගාස්තුව: LKR {fare}",
  "@estimatedFare": {
    "placeholders": {
      "fare": { "type": "String" }
    }
  },
  "startTrip": "ගමන ආරම්භ කරන්න",
  "arrivingNow": "දැන් පැමිණෙමින් පවතී",
  "minAway": "මිනිත්තු {mins} කින්",
  "@minAway": {
    "placeholders": {
      "mins": { "type": "String" }
    }
  },
  "mAwayTime": "මීටර් {meters} ක් දුරින් • {timeStr}",
  "@mAwayTime": {
    "placeholders": {
      "meters": { "type": "String" },
      "timeStr": { "type": "String" }
    }
  },
  "kmAwayTime": "කි.මී. {km} ක් දුරින් • {timeStr}",
  "@kmAwayTime": {
    "placeholders": {
      "km": { "type": "String" },
      "timeStr": { "type": "String" }
    }
  },
  "transportingToHospital": "රෝහලට ප්‍රවාහනය කරමින් පවතී!",
  "emtOnTheWay": "EMT පැමිණෙමින් සිටී!",
  "hospital": "රෝහල",
  "ambulanceWord": "ගිලන්රථය",
  "enRouteTo": "{hospitalName} වෙත යමින්",
  "@enRouteTo": {
    "placeholders": {
      "hospitalName": { "type": "String" }
    }
  },
  "emtAcceptedEnRoute": "EMT පිළිගන්නා ලදි & පැමිණෙමින්",
  "hospitalTripFare": "රෝහල් ගමන් ගාස්තුව: {price}",
  "@hospitalTripFare": {
    "placeholders": {
      "price": { "type": "String" }
    }
  },
  "liveLocationUpdating": "සජීවී ස්ථානය තත්පර 5කට වරක් යාවත්කාලීන වේ",
  "waitingForEmtLocation": "EMT ස්ථානය සඳහා රැඳී සිටින්න…",
  "emtHasArrived": "EMT පැමිණ ඇත!",
  "emtAssessing": "EMT දැනට රෝගියා පරීක්ෂා කරමින් මූලික වාර්තාව පුරවමින් සිටී. කරුණාකර රැඳී සිටින්න.",
  "estimatedInitialFare": "ඇස්තමේන්තුගත මූලික ගාස්තුව (කැඳවීම + EMT ගමන)",
  "calculating": "ගණනය කරමින්...",
  "statusPending": "තත්ත්වය: පොරොත්තු",
  "pending": "පොරොත්තු"
};

const taExtras = {
  "hospitalsTab": "மருத்துவமனைகள்",
  "noHospitals": "இன்னும் மருத்துவமனைகள் சேர்க்கப்படவில்லை",
  "addHospital": "மருத்துவமனையைச் சேர்",
  "registerHospital": "மருத்துவமனையைப் பதிவு செய்",
  "hospitalName": "மருத்துவமனை பெயர்",
  "locationAcquired": "இடம் பெறப்பட்டது",
  "fetchLocation": "தற்போதைய இடத்தைப் பெறு",
  "register": "பதிவு செய்",
  "deleteHospital": "மருத்துவமனையை நீக்கு",
  "deleteHospitalConfirm": "{name} மருத்துவமனையை நீக்கவா?",
  "@deleteHospitalConfirm": {
    "placeholders": {
      "name": { "type": "String" }
    }
  },
  "hospitalRegistered": "மருத்துவமனை வெற்றிகரமாக பதிவு செய்யப்பட்டது!",
  "fetchLocationFirst": "தயவுசெய்து முதலில் இடத்தைப் பெறவும்",
  "hospitalNameRequired": "மருத்துவமனை பெயர் தேவை",
  "hospitalDeleted": "மருத்துவமனை நீக்கப்பட்டது",
  "selectDestination": "இலக்கைத் தேர்ந்தெடுக்கவும்",
  "distanceKm": "தூரம்: {distance} கி.மீ",
  "@distanceKm": {
    "placeholders": {
      "distance": { "type": "String" }
    }
  },
  "estimatedFare": "மதிப்பிடப்பட்ட கட்டணம்: LKR {fare}",
  "@estimatedFare": {
    "placeholders": {
      "fare": { "type": "String" }
    }
  },
  "startTrip": "பயணத்தைத் தொடங்கு",
  "arrivingNow": "இப்போது வந்துகொண்டிருக்கிறது",
  "minAway": "{mins} நிமிடங்களில்",
  "@minAway": {
    "placeholders": {
      "mins": { "type": "String" }
    }
  },
  "mAwayTime": "{meters} மீ தொலைவில் • {timeStr}",
  "@mAwayTime": {
    "placeholders": {
      "meters": { "type": "String" },
      "timeStr": { "type": "String" }
    }
  },
  "kmAwayTime": "{km} கி.மீ தொலைவில் • {timeStr}",
  "@kmAwayTime": {
    "placeholders": {
      "km": { "type": "String" },
      "timeStr": { "type": "String" }
    }
  },
  "transportingToHospital": "மருத்துவமனைக்கு கொண்டு செல்லப்படுகிறது!",
  "emtOnTheWay": "EMT வந்துகொண்டிருக்கிறார்!",
  "hospital": "மருத்துவமனை",
  "ambulanceWord": "ஆம்புலன்ஸ்",
  "enRouteTo": "{hospitalName} நோக்கி செல்கிறது",
  "@enRouteTo": {
    "placeholders": {
      "hospitalName": { "type": "String" }
    }
  },
  "emtAcceptedEnRoute": "EMT ஏற்கப்பட்டது & வழியில்",
  "hospitalTripFare": "மருத்துவமனை பயணக் கட்டணம்: {price}",
  "@hospitalTripFare": {
    "placeholders": {
      "price": { "type": "String" }
    }
  },
  "liveLocationUpdating": "நேரடி இருப்பிடம் 5 வினாடிகளுக்கு ஒருமுறை புதுப்பிக்கப்படும்",
  "waitingForEmtLocation": "EMT இருப்பிடத்திற்காக காத்திருக்கிறது…",
  "emtHasArrived": "EMT வந்துவிட்டார்!",
  "emtAssessing": "EMT தற்போது நோயாளியை பரிசோதித்து প্রাথমিক அறிக்கையை நிரப்புகிறார். காத்திருக்கவும்.",
  "estimatedInitialFare": "மதிப்பிடப்பட்ட ஆரம்ப கட்டணம் (அழைப்பு + EMT பயணம்)",
  "calculating": "கணக்கிடப்படுகிறது...",
  "statusPending": "நிலை: நிலுவையில் உள்ளது",
  "pending": "நிலுவையில்"
};

function updateArb(file, extras) {
  let content = fs.readFileSync(file, 'utf8');
  let obj = JSON.parse(content);
  obj = { ...obj, ...extras };
  fs.writeFileSync(file, JSON.stringify(obj, null, 2));
}

updateArb('lib/l10n/app_en.arb', enExtras);
updateArb('lib/l10n/app_si.arb', siExtras);
updateArb('lib/l10n/app_ta.arb', taExtras);

console.log("ARB files updated successfully");
