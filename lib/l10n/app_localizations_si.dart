// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Sinhala Sinhalese (`si`).
class AppLocalizationsSi extends AppLocalizations {
  AppLocalizationsSi([String locale = 'si']) : super(locale);

  @override
  String get appName => 'STJ MediLink';

  @override
  String get loginTitle => 'ඔබේ ගිණුමට පිවිසෙන්න';

  @override
  String get signupTitle => 'ඔබේ ගිණුම සාදන්න';

  @override
  String get email => 'විද්‍යුත් තැපෑල';

  @override
  String get password => 'මුරපදය';

  @override
  String get confirmPassword => 'මුරපදය තහවුරු කරන්න';

  @override
  String get contactNumber => 'දුරකථන අංකය';

  @override
  String get signIn => 'පිවිසෙන්න';

  @override
  String get signUp => 'ලියාපදිංචි වන්න';

  @override
  String get orSignInWith => '- හෝ මෙමගින් පිවිසෙන්න -';

  @override
  String get orSignUpWith => '- හෝ මෙමගින් ලියාපදිංචි වන්න -';

  @override
  String get noAccount => 'ගිණුමක් නැද්ද? ';

  @override
  String get signUpLink => 'ලියාපදිංචි වන්න';

  @override
  String get alreadyAccount => 'දැනටමත් ගිණුමක් තිබේද? ';

  @override
  String get signInLink => 'පිවිසෙන්න';

  @override
  String get signInWithPhone => 'දුරකථනයෙන් පිවිසෙන්න';

  @override
  String get enterOtp => 'OTP ඇතුළු කරන්න';

  @override
  String get sendOtp => 'OTP යවන්න';

  @override
  String get verifyOtp => 'OTP තහවුරු කරන්න';

  @override
  String get otpSent => 'OTP යවන ලදී!';

  @override
  String get changeNumberResend => 'අංකය වෙනස් කරන්න / OTP නැවත යවන්න';

  @override
  String get welcome => 'සාදරයෙන් පිළිගනිමු!';

  @override
  String get patientDashboard => 'රෝගී උපකරණ පුවරුව';

  @override
  String get welcomePatient => 'සාදරයෙන් පිළිගනිමු, රෝගියා!';

  @override
  String get ambulanceDashboard => 'EMT උපකරණ පුවරුව';

  @override
  String get welcomeDriver => 'සාදරයෙන් පිළිගනිමු, EMT!';

  @override
  String get adminDashboard => 'පරිපාලක උපකරණ පුවරුව';

  @override
  String get welcomeAdmin => 'සාදරයෙන් පිළිගනිමු, පරිපාලක!';

  @override
  String get signOut => 'ඉවත් වන්න';

  @override
  String get createAccount => 'ගිණුම සාදන්න';

  @override
  String get ambulance => 'EMT';

  @override
  String get admins => 'පරිපාලකයින්';

  @override
  String get patients => 'රෝගීන්';

  @override
  String get fullName => 'සම්පූර්ණ නම';

  @override
  String get phoneNumber => 'දුරකථන අංකය';

  @override
  String get newPassword => 'නව මුරපදය (හිස් නම් වෙනස් නොවේ)';

  @override
  String get role => 'භූමිකාව';

  @override
  String get save => 'සුරකින්න';

  @override
  String get cancel => 'අවලංගු කරන්න';

  @override
  String get create => 'සාදන්න';

  @override
  String get edit => 'සංස්කරණය';

  @override
  String get delete => 'මකන්න';

  @override
  String get deleteAccount => 'ගිණුම මකන්න';

  @override
  String get accountUpdated => 'ගිණුම සාර්ථකව යාවත්කාලීන කරන ලදී';

  @override
  String get accountCreated => 'ගිණුම සාදන ලදී!';

  @override
  String get accountDeleted => 'ගිණුම මකා දමන ලදී';

  @override
  String get forgotPassword => 'මුරපදය අමතකද?';

  @override
  String get resetPassword => 'මුරපදය යළි සකසන්න';

  @override
  String get resetPasswordSubtitle =>
      'ඔබේ විද්‍යුත් තැපැල් ලිපිනය ඇතුළු කරන්න, අපි ඔබට මුරපදය යළි සැකසීමේ සබැඳියක් යවන්නෙමු.';

  @override
  String get sendResetLink => 'යළි සැකසීමේ සබැඳිය යවන්න';

  @override
  String get resetEmailSent => 'යළි සැකසීමේ විද්‍යුත් තැපෑල යවන ලදී!';

  @override
  String resetEmailSentDesc(String email) {
    return 'අපි $email වෙත මුරපදය යළි සැකසීමේ සබැඳියක් යවා ඇත. ඔබේ inbox පරීක්ෂා කරන්න.';
  }

  @override
  String get backToLogin => 'පිවිසීමට ආපසු';

  @override
  String get emailRequired => 'කරුණාකර ඔබේ විද්‍යුත් තැපැල් ලිපිනය ඇතුළු කරන්න';

  @override
  String get resetLinkSent =>
      'මුරපදය යළි සැකසීමේ සබැඳිය ඔබේ විද්‍යුත් තැපෑලට යවන ලදී';

  @override
  String get patient => 'රෝගියා';

  @override
  String get sosButton => 'SOS';

  @override
  String get yourLocation => 'ඔබේ ස්ථානය';

  @override
  String get locating => 'ස්ථානය සොයමින්...';

  @override
  String requestAmbulance(String type) {
    return '$type ගිලන් රථයක් ඉල්ලන්න';
  }

  @override
  String get confirmRequest => 'ඉල්ලීම තහවුරු කරන්න';

  @override
  String ambulanceType(String type) {
    return 'වර්ගය: $type ගිලන් රථය';
  }

  @override
  String price(String price) {
    return 'මිල: $price';
  }

  @override
  String get dispatchMessage => 'EMT කෙනෙකු ඔබේ ස්ථානයට යවනු ලැබේ.';

  @override
  String get confirm => 'තහවුරු කරන්න';

  @override
  String helpOnWay(String type) {
    return '🚑 $type ගිලන් රථය ඉල්ලා ඇත! උදව් එමින් පවතී.';
  }

  @override
  String get basicAmbulance => 'මූලික';

  @override
  String get advancedAmbulance => 'උසස්';

  @override
  String get icuAmbulance => 'ICU';

  @override
  String get neonatalAmbulance => 'නවජ';

  @override
  String get capacity2 => 'රෝගීන් 2';

  @override
  String get capacity1 => 'රෝගියෙකු 1';

  @override
  String get capacityInfant => 'ළදරුවෙකු 1';

  @override
  String get profile => 'පැතිකඩ';

  @override
  String get saveChanges => 'වෙනස්කම් සුරකින්න';

  @override
  String get profileUpdated => 'පැතිකඩ සාර්ථකව යාවත්කාලීන කරන ලදී';

  @override
  String get takePhoto => 'ඡායාරූපයක් ගන්න';

  @override
  String get chooseFromGallery => 'ගැලරියෙන් තෝරන්න';

  @override
  String get useDevicePhoneNumber => 'උපාංගයේ දුරකථන අංකය භාවිතා කරන්න';

  @override
  String get enterPhoneDesc =>
      'ඔබේ දුරකථන අංකය රටේ කේතය සමඟ ඇතුළු කරන්න (උදා: +94771234567).\n\nඔබට එය කෙලින්ම ක්ෂේත්‍රයේ ටයිප් කළ හැකිය.';

  @override
  String get editProfile => 'පැතිකඩ සංස්කරණය කරන්න';

  @override
  String get imageTooLarge => 'රූපය ඉතා විශාලයි. කරුණාකර කුඩා රූපයක් තෝරන්න.';

  @override
  String get useMyPhoneNumber => 'මගේ දුරකථන අංකය භාවිතා කරන්න';

  @override
  String get welcomeBack => 'නැවත සාදරයෙන් පිළිගනිමු,';

  @override
  String get areYouInEmergency => 'ඔබ හදිසි අවස්ථාවකද?';

  @override
  String get pressButtonHelp => 'පහත බොත්තම ගහන්න, ඉක්මනින් උදව් ලැබේ.';

  @override
  String get yourCurrentLocation => 'ඔබේ වත්මන් ස්ථානය';

  @override
  String get tapSosToShare => 'ඔබේ ස්ථානය බෙදා ගැනීමට SOS ගහන්න';

  @override
  String get personalInfo => 'පෞද්ගලික තොරතුරු';

  @override
  String get dateOfBirth => 'උපන් දිනය';

  @override
  String get gender => 'ස්ත්‍රී පුරුෂ භාවය';

  @override
  String get selectGender => 'ස්ත්‍රී පුරුෂ භාවය තෝරන්න';

  @override
  String get address => 'ලිපිනය';

  @override
  String get addressHint => 'වීදිය, නගරය, පළාත';

  @override
  String get medicalInfo => 'වෛද්‍ය තොරතුරු';

  @override
  String get bloodType => 'රුධිර වර්ගය';

  @override
  String get selectBloodType => 'රුධිර වර්ගය තෝරන්න';

  @override
  String get medicalNotes => 'වෛද්‍ය සටහන් / අසාත්මිකතා';

  @override
  String get medicalNotesHint => 'උදා: දියවැඩියාව, පෙනිසිලින් සඳහා අසාත්මිකතා…';

  @override
  String get medicalHistory => 'වෛද්‍ය ඉතිහාසය';

  @override
  String get medicalHistoryHint => 'පෙර රෝග, ශල්‍යකර්ම, පවුලේ ඉතිහාසය…';

  @override
  String get emergencyContact => 'හදිසි සම්බන්ධතාව';

  @override
  String get contactName => 'සම්බන්ධතා නම';

  @override
  String get contactPhone => 'සම්බන්ධතා දුරකථනය';

  @override
  String get genderMale => 'පිරිමි';

  @override
  String get genderFemale => 'ගැහැනු';

  @override
  String get genderOther => 'වෙනත්';

  @override
  String get genderPreferNot => 'කීමට කැමති නැත';

  @override
  String get paymentDetails => 'ගෙවීම් විස්තර';

  @override
  String get cardNumber => 'කාඩ්පත් අංකය';

  @override
  String get expiryDate => 'කල් ඉකුත් වන දිනය (MM/YY)';

  @override
  String get cvv => 'CVV';

  @override
  String get hospitalsTab => 'රෝහල්';

  @override
  String get noHospitals => 'තවමත් රෝහල් එකතු කර නොමැත';

  @override
  String get addHospital => 'රෝහලක් එකතු කරන්න';

  @override
  String get registerHospital => 'රෝහල ලියාපදිංචි කරන්න';

  @override
  String get hospitalName => 'රෝහලේ නම';

  @override
  String get locationAcquired => 'ස්ථානය ලබා ගෙන ඇත';

  @override
  String get fetchLocation => 'වත්මන් ස්ථානය ලබා ගන්න';

  @override
  String get register => 'ලියාපදිංචි කරන්න';

  @override
  String get deleteHospital => 'රෝහල මකන්න';

  @override
  String deleteHospitalConfirm(String name) {
    return 'මකා දමන්නද $name?';
  }

  @override
  String get hospitalRegistered => 'රෝහල සාර්ථකව ලියාපදිංචි කරන ලදි!';

  @override
  String get fetchLocationFirst => 'කරුණාකර පළමුව ස්ථානය ලබා ගන්න';

  @override
  String get hospitalNameRequired => 'රෝහලේ නම අවශ්‍යයි';

  @override
  String get hospitalDeleted => 'රෝහල මකා දමන ලදි';

  @override
  String get selectDestination => 'ගමනාන්තය තෝරන්න';

  @override
  String distanceKm(String distance) {
    return 'දුර: කි.මී. $distance';
  }

  @override
  String estimatedFare(String fare) {
    return 'ඇස්තමේන්තු ගාස්තුව: LKR $fare';
  }

  @override
  String get startTrip => 'ගමන ආරම්භ කරන්න';

  @override
  String get arrivingNow => 'දැන් පැමිණෙමින් පවතී';

  @override
  String minAway(String mins) {
    return 'මිනිත්තු $mins කින්';
  }

  @override
  String mAwayTime(String meters, String timeStr) {
    return 'මීටර් $meters ක් දුරින් • $timeStr';
  }

  @override
  String kmAwayTime(String km, String timeStr) {
    return 'කි.මී. $km ක් දුරින් • $timeStr';
  }

  @override
  String get transportingToHospital => 'රෝහලට ප්‍රවාහනය කරමින් පවතී!';

  @override
  String get emtOnTheWay => 'EMT පැමිණෙමින් සිටී!';

  @override
  String get hospital => 'රෝහල';

  @override
  String get ambulanceWord => 'ගිලන්රථය';

  @override
  String enRouteTo(String hospitalName) {
    return '$hospitalName වෙත යමින්';
  }

  @override
  String get emtAcceptedEnRoute => 'EMT පිළිගන්නා ලදි & පැමිණෙමින්';

  @override
  String hospitalTripFare(String price) {
    return 'රෝහල් ගමන් ගාස්තුව: $price';
  }

  @override
  String get liveLocationUpdating =>
      'සජීවී ස්ථානය තත්පර 5කට වරක් යාවත්කාලීන වේ';

  @override
  String get waitingForEmtLocation => 'EMT ස්ථානය සඳහා රැඳී සිටින්න…';

  @override
  String get emtHasArrived => 'EMT පැමිණ ඇත!';

  @override
  String get emtAssessing =>
      'EMT දැනට රෝගියා පරීක්ෂා කරමින් මූලික වාර්තාව පුරවමින් සිටී. කරුණාකර රැඳී සිටින්න.';

  @override
  String get estimatedInitialFare =>
      'ඇස්තමේන්තුගත මූලික ගාස්තුව (කැඳවීම + EMT ගමන)';

  @override
  String get calculating => 'ගණනය කරමින්...';

  @override
  String get statusPending => 'තත්ත්වය: පොරොත්තු';

  @override
  String get pending => 'පොරොත්තු';

  @override
  String get pcrTitle => 'රෝගී සත්කාර වාර්තාව';

  @override
  String get nicPassport => 'ජා.හැ.ප. / විදේශ ගමන් බලපත්‍රය';

  @override
  String get age => 'වයස';

  @override
  String get bloodGroup => 'රුධිර ගණය';

  @override
  String get contactNo => 'සම්බන්ධ කරගත යුතු අංකය';

  @override
  String get guardianNextOfKin => 'භාරකරු / ඥාතියා';

  @override
  String get relationship => 'ඥාතිත්වය';

  @override
  String get guardianContactNo => 'භාරකරුගේ දුරකථන අංකය';

  @override
  String get idFront => 'හැඳුනුම්පත ඉදිරිපස';

  @override
  String get idBack => 'හැඳුනුම්පත පසුපස';

  @override
  String get emergencyType => 'හදිසි තත්වයේ වර්ගය';

  @override
  String get chiefComplaint => 'ප්‍රධාන පැමිණිල්ල / විස්තරය';

  @override
  String get symptoms => 'රෝග ලක්ෂණ';

  @override
  String get consciousLevel => 'සිහිය ඇති මට්ටම';

  @override
  String get painLevel010 => 'වේදනා මට්ටම (0 - 10)';

  @override
  String get aAirway => 'A - ශ්වසන මාර්ගය';

  @override
  String get airwayManaged => 'ශ්වසන මාර්ගය කළමනාකරණය කළාද?';

  @override
  String get method => 'ක්‍රමය';

  @override
  String get bBreathing => 'B - හුස්ම ගැනීම';

  @override
  String get respRate => 'ශ්වසන වේගය (/min)';

  @override
  String get spo2 => 'SpO2 (%)';

  @override
  String get breathingAssisted => 'හුස්ම ගැනීමට සහාය වූවාද?';

  @override
  String get cCirculation => 'C - රුධිර සංසරණය';

  @override
  String get pulseMin => 'නාඩි (/min)';

  @override
  String get bpMmHg => 'රුධිර පීඩනය (mmHg)';

  @override
  String get capillaryRefill => 'Capillary Refill';

  @override
  String get bleedingControlled => 'රුධිර වහනය පාලනය කළාද?';

  @override
  String get dDisability => 'D - ආබාධිත බව';

  @override
  String get gcsScore => 'GCS අගය:';

  @override
  String get e14 => 'E (1-4)';

  @override
  String get v15 => 'V (1-5)';

  @override
  String get m16 => 'M (1-6)';

  @override
  String get eExposure => 'E - නිරාවරණය';

  @override
  String get temperatureC => 'උෂ්ණත්වය (°C)';

  @override
  String get noVitalsRecorded => 'තාමත් ජීව සලකුණු වාර්තා කර නොමැත.';

  @override
  String timePulseBpSpo2(String time, String pulse, String bp, String spo2) {
    return 'වේලාව: $time | නාඩි: $pulse | රු.පී: $bp | SpO2: $spo2';
  }

  @override
  String get logCurrentVitals => 'වත්මන් ජීව සලකුණු සටහන් කරන්න';

  @override
  String get sSignsSymptoms => 'S - සංඥා සහ ලක්ෂණ';

  @override
  String get aAllergies => 'A - අසාත්මිකතා';

  @override
  String get mMedications => 'M - ඖෂධ';

  @override
  String get pPastMedicalHistory => 'P - පෙර වෛද්‍ය ඉතිහාසය';

  @override
  String get lLastMeal => 'L - අවසන් ආහාරය';

  @override
  String get eEventsLeading => 'E - අසනීපයට/තුවාලයට හේතු වූ සිදුවීම්';

  @override
  String get knownConditions => 'දන්නා රෝගී තත්වයන්';

  @override
  String get interactiveBodyMapPlaceHolder =>
      'අන්තර්ක්‍රියාකාරී ශරීර තුවාල සිතියම';

  @override
  String get interactiveBodyMapHint =>
      '(පිලිස්සුම්, අස්ථි බිඳීම්, ඉදිමීම් ආදිය සඳහා සලකුණු එකතු කිරීමට තට්ටු කරන්න)';

  @override
  String get airwayManagement => 'ශ්වසන මාර්ග කළමනාකරණය';

  @override
  String get o2Flow => 'O2 ගලනය (L/min)';

  @override
  String get cardiovascular => 'හෘද වාහිනී';

  @override
  String get immobilization => 'නිශ්චල කිරීම';

  @override
  String get medicationGiven => 'ලබා දුන් ඖෂධ';

  @override
  String get medication => 'ඖෂධය';

  @override
  String get dose => 'මාත්‍රාව';

  @override
  String get route => 'මාර්ගය';

  @override
  String get time => 'වේලාව';

  @override
  String get transportType => 'ප්‍රවාහන වර්ගය';

  @override
  String get departureTime => 'පිටත් වූ වේලාව';

  @override
  String get arrivalTimeExt => 'පැමිණි වේලාව';

  @override
  String get distanceCoveredKm => 'ගමන් කළ දුර (km)';

  @override
  String get doctorNurseName => 'වෛද්‍ය / හෙද නම';

  @override
  String get handoverTime => 'භාර දුන් වේලාව';

  @override
  String get conditionOnArrival => 'පැමිණෙන විට තත්වය';

  @override
  String get handoverNotes => 'භාරදීමේ සටහන්';

  @override
  String get submitPcr => 'රෝගී සත්කාර වාර්තාව ඉදිරිපත් කරන්න';

  @override
  String get reportSubmitted => 'වාර්තාව සාර්ථකව ඉදිරිපත් කරන ලදි!';

  @override
  String errorSavingReport(String error) {
    return 'වාර්තාව සුරැකීමේ දෝෂයක්: $error';
  }

  @override
  String get cancelTrip => 'ගමන අවලංගු කරන්න';

  @override
  String get cancelTripConfirm => 'ඔබට මෙම හදිසි ඉල්ලීම අවලංගු කිරීමට අවශ්‍යද?';

  @override
  String get tripCancelled => 'ගමන අවලංගු කරන ලදී.';

  @override
  String get yesCancel => 'ඔව්, අවලංගු කරන්න';

  @override
  String get noKeep => 'නැත';
}
