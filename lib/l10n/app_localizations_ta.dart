// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'STJ MediLink';

  @override
  String get loginTitle => 'உங்கள் கணக்கில் உள்நுழைக';

  @override
  String get signupTitle => 'உங்கள் கணக்கை உருவாக்கவும்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get confirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get contactNumber => 'தொடர்பு எண்';

  @override
  String get signIn => 'உள்நுழைக';

  @override
  String get signUp => 'பதிவு செய்க';

  @override
  String get orSignInWith => '- அல்லது இதன் மூலம் உள்நுழைக -';

  @override
  String get orSignUpWith => '- அல்லது இதன் மூலம் பதிவு செய்க -';

  @override
  String get noAccount => 'கணக்கு இல்லையா? ';

  @override
  String get signUpLink => 'பதிவு செய்க';

  @override
  String get alreadyAccount => 'ஏற்கனவே கணக்கு உள்ளதா? ';

  @override
  String get signInLink => 'உள்நுழைக';

  @override
  String get signInWithPhone => 'தொலைபேசி மூலம் உள்நுழைக';

  @override
  String get enterOtp => 'OTP உள்ளிடவும்';

  @override
  String get sendOtp => 'OTP அனுப்பவும்';

  @override
  String get verifyOtp => 'OTP சரிபார்க்கவும்';

  @override
  String get otpSent => 'OTP அனுப்பப்பட்டது!';

  @override
  String get changeNumberResend => 'எண்ணை மாற்றவும் / OTP மீண்டும் அனுப்பவும்';

  @override
  String get welcome => 'வரவேற்கிறோம்!';

  @override
  String get patientDashboard => 'நோயாளி டாஷ்போர்டு';

  @override
  String get welcomePatient => 'வரவேற்கிறோம், நோயாளி!';

  @override
  String get ambulanceDashboard => 'EMT டாஷ்போர்டு';

  @override
  String get welcomeDriver => 'வரவேற்கிறோம், EMT!';

  @override
  String get adminDashboard => 'நிர்வாக டாஷ்போர்டு';

  @override
  String get welcomeAdmin => 'வரவேற்கிறோம், நிர்வாகி!';

  @override
  String get signOut => 'வெளியேறு';

  @override
  String get createAccount => 'கணக்கு உருவாக்கவும்';

  @override
  String get ambulance => 'EMT';

  @override
  String get admins => 'நிர்வாகிகள்';

  @override
  String get patients => 'நோயாளிகள்';

  @override
  String get fullName => 'முழு பெயர்';

  @override
  String get phoneNumber => 'தொலைபேசி எண்';

  @override
  String get newPassword => 'புதிய கடவுச்சொல் (காலியாக விட்டால் மாறாது)';

  @override
  String get role => 'பங்கு';

  @override
  String get save => 'சேமிக்கவும்';

  @override
  String get cancel => 'ரத்து செய்க';

  @override
  String get create => 'உருவாக்கவும்';

  @override
  String get edit => 'திருத்தவும்';

  @override
  String get delete => 'நீக்கவும்';

  @override
  String get deleteAccount => 'கணக்கை நீக்கவும்';

  @override
  String get accountUpdated => 'கணக்கு வெற்றிகரமாக புதுப்பிக்கப்பட்டது';

  @override
  String get accountCreated => 'கணக்கு உருவாக்கப்பட்டது!';

  @override
  String get accountDeleted => 'கணக்கு நீக்கப்பட்டது';

  @override
  String get forgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get resetPassword => 'கடவுச்சொல்லை மீட்டமைக்கவும்';

  @override
  String get resetPasswordSubtitle =>
      'உங்கள் மின்னஞ்சல் முகவரியை உள்ளிடவும், கடவுச்சொல்லை மீட்டமைக்க இணைப்பை அனுப்புவோம்.';

  @override
  String get sendResetLink => 'மீட்டமைப்பு இணைப்பை அனுப்பவும்';

  @override
  String get resetEmailSent => 'மீட்டமைப்பு மின்னஞ்சல் அனுப்பப்பட்டது!';

  @override
  String resetEmailSentDesc(String email) {
    return '$email க்கு கடவுச்சொல் மீட்டமைப்பு இணைப்பை அனுப்பியுள்ளோம். உங்கள் inbox சரிபார்க்கவும்.';
  }

  @override
  String get backToLogin => 'உள்நுழைவுக்கு திரும்பவும்';

  @override
  String get emailRequired => 'உங்கள் மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get resetLinkSent =>
      'கடவுச்சொல் மீட்டமைப்பு இணைப்பு உங்கள் மின்னஞ்சலுக்கு அனுப்பப்பட்டது';

  @override
  String get patient => 'நோயாளி';

  @override
  String get sosButton => 'SOS';

  @override
  String get yourLocation => 'உங்கள் இடம்';

  @override
  String get locating => 'இடம் கண்டறிகிறது...';

  @override
  String requestAmbulance(String type) {
    return '$type ஆம்புலன்ஸ் கோரவும்';
  }

  @override
  String get confirmRequest => 'கோரிக்கையை உறுதிப்படுத்தவும்';

  @override
  String ambulanceType(String type) {
    return 'வகை: $type ஆம்புலன்ஸ்';
  }

  @override
  String price(String price) {
    return 'விலை: $price';
  }

  @override
  String get dispatchMessage => 'உங்கள் இடத்திற்கு EMT அனுப்பப்படும்.';

  @override
  String get confirm => 'உறுதிப்படுத்தவும்';

  @override
  String helpOnWay(String type) {
    return '🚑 $type ஆம்புலன்ஸ் கோரப்பட்டது! உதவி வருகிறது.';
  }

  @override
  String get basicAmbulance => 'அடிப்படை';

  @override
  String get advancedAmbulance => 'மேம்பட்ட';

  @override
  String get icuAmbulance => 'ICU';

  @override
  String get neonatalAmbulance => 'நவஜாதக';

  @override
  String get capacity2 => '2 நோயாளிகள்';

  @override
  String get capacity1 => '1 நோயாளி';

  @override
  String get capacityInfant => '1 குழந்தை';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get saveChanges => 'மாற்றங்களை சேமிக்கவும்';

  @override
  String get profileUpdated => 'சுயவிவரம் வெற்றிகரமாக புதுப்பிக்கப்பட்டது';

  @override
  String get takePhoto => 'புகைப்படம் எடுக்கவும்';

  @override
  String get chooseFromGallery => 'கேலரியிலிருந்து தேர்வு செய்க';

  @override
  String get useDevicePhoneNumber => 'சாதன தொலைபேசி எண்ணை பயன்படுத்தவும்';

  @override
  String get enterPhoneDesc =>
      'நாட்டு குறியீட்டுடன் உங்கள் தொலைபேசி எண்ணை உள்ளிடவும் (எ.கா. +94771234567).\n\nநேரடியாக புலத்தில் தட்டச்சு செய்யலாம்.';

  @override
  String get editProfile => 'சுயவிவரத்தை திருத்தவும்';

  @override
  String get imageTooLarge =>
      'படம் மிகவும் பெரியது. சிறிய படத்தை தேர்வு செய்யவும்.';

  @override
  String get useMyPhoneNumber => 'என் தொலைபேசி எண்ணை பயன்படுத்தவும்';

  @override
  String get welcomeBack => 'மீண்டும் வரவேற்கிறோம்,';

  @override
  String get areYouInEmergency => 'நீங்கள் அவசரநிலையில் இருக்கிறீர்களா?';

  @override
  String get pressButtonHelp =>
      'கீழே உள்ள பொத்தானை அழுத்தவும், உதவி விரைவில் வரும்.';

  @override
  String get yourCurrentLocation => 'உங்கள் தற்போதைய இடம்';

  @override
  String get tapSosToShare => 'உங்கள் இடத்தை பகிர SOS அழுத்தவும்';

  @override
  String get personalInfo => 'தனிப்பட்ட தகவல்';

  @override
  String get dateOfBirth => 'பிறந்த தேதி';

  @override
  String get gender => 'பாலினம்';

  @override
  String get selectGender => 'பாலினம் தேர்வு செய்க';

  @override
  String get address => 'முகவரி';

  @override
  String get addressHint => 'தெரு, நகரம், மாகாணம்';

  @override
  String get medicalInfo => 'மருத்துவ தகவல்';

  @override
  String get bloodType => 'இரத்த வகை';

  @override
  String get selectBloodType => 'இரத்த வகை தேர்வு செய்க';

  @override
  String get medicalNotes => 'மருத்துவ குறிப்புகள் / ஒவ்வாமை';

  @override
  String get medicalNotesHint => 'எ.கா. நீரிழிவு, பென்சிலின் ஒவ்வாமை…';

  @override
  String get medicalHistory => 'மருத்துவ வரலாறு';

  @override
  String get medicalHistoryHint =>
      'கடந்தகால நோய்கள், அறுவை சிகிச்சைகள், குடும்ப வரலாறு…';

  @override
  String get emergencyContact => 'அவசர தொடர்பு';

  @override
  String get contactName => 'தொடர்பு பெயர்';

  @override
  String get contactPhone => 'தொடர்பு தொலைபேசி';

  @override
  String get genderMale => 'ஆண்';

  @override
  String get genderFemale => 'பெண்';

  @override
  String get genderOther => 'மற்றவை';

  @override
  String get genderPreferNot => 'கூற விரும்பவில்லை';

  @override
  String get paymentDetails => 'கட்டண விவரங்கள்';

  @override
  String get cardNumber => 'அட்டை எண்';

  @override
  String get expiryDate => 'காலாவதி தேதி (MM/YY)';

  @override
  String get cvv => 'CVV';

  @override
  String get hospitalsTab => 'மருத்துவமனைகள்';

  @override
  String get noHospitals => 'இன்னும் மருத்துவமனைகள் சேர்க்கப்படவில்லை';

  @override
  String get addHospital => 'மருத்துவமனையைச் சேர்';

  @override
  String get registerHospital => 'மருத்துவமனையைப் பதிவு செய்';

  @override
  String get hospitalName => 'மருத்துவமனை பெயர்';

  @override
  String get locationAcquired => 'இடம் பெறப்பட்டது';

  @override
  String get fetchLocation => 'தற்போதைய இடத்தைப் பெறு';

  @override
  String get register => 'பதிவு செய்';

  @override
  String get deleteHospital => 'மருத்துவமனையை நீக்கு';

  @override
  String deleteHospitalConfirm(String name) {
    return '$name மருத்துவமனையை நீக்கவா?';
  }

  @override
  String get hospitalRegistered =>
      'மருத்துவமனை வெற்றிகரமாக பதிவு செய்யப்பட்டது!';

  @override
  String get fetchLocationFirst => 'தயவுசெய்து முதலில் இடத்தைப் பெறவும்';

  @override
  String get hospitalNameRequired => 'மருத்துவமனை பெயர் தேவை';

  @override
  String get hospitalDeleted => 'மருத்துவமனை நீக்கப்பட்டது';

  @override
  String get selectDestination => 'இலக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String distanceKm(String distance) {
    return 'தூரம்: $distance கி.மீ';
  }

  @override
  String estimatedFare(String fare) {
    return 'மதிப்பிடப்பட்ட கட்டணம்: LKR $fare';
  }

  @override
  String get startTrip => 'பயணத்தைத் தொடங்கு';

  @override
  String get arrivingNow => 'இப்போது வந்துகொண்டிருக்கிறது';

  @override
  String minAway(String mins) {
    return '$mins நிமிடங்களில்';
  }

  @override
  String mAwayTime(String meters, String timeStr) {
    return '$meters மீ தொலைவில் • $timeStr';
  }

  @override
  String kmAwayTime(String km, String timeStr) {
    return '$km கி.மீ தொலைவில் • $timeStr';
  }

  @override
  String get transportingToHospital =>
      'மருத்துவமனைக்கு கொண்டு செல்லப்படுகிறது!';

  @override
  String get emtOnTheWay => 'EMT வந்துகொண்டிருக்கிறார்!';

  @override
  String get hospital => 'மருத்துவமனை';

  @override
  String get ambulanceWord => 'ஆம்புலன்ஸ்';

  @override
  String enRouteTo(String hospitalName) {
    return '$hospitalName நோக்கி செல்கிறது';
  }

  @override
  String get emtAcceptedEnRoute => 'EMT ஏற்கப்பட்டது & வழியில்';

  @override
  String hospitalTripFare(String price) {
    return 'மருத்துவமனை பயணக் கட்டணம்: $price';
  }

  @override
  String get liveLocationUpdating =>
      'நேரடி இருப்பிடம் 5 வினாடிகளுக்கு ஒருமுறை புதுப்பிக்கப்படும்';

  @override
  String get waitingForEmtLocation => 'EMT இருப்பிடத்திற்காக காத்திருக்கிறது…';

  @override
  String get emtHasArrived => 'EMT வந்துவிட்டார்!';

  @override
  String get emtAssessing =>
      'EMT தற்போது நோயாளியை பரிசோதித்து প্রাথমিক அறிக்கையை நிரப்புகிறார். காத்திருக்கவும்.';

  @override
  String get estimatedInitialFare =>
      'மதிப்பிடப்பட்ட ஆரம்ப கட்டணம் (அழைப்பு + EMT பயணம்)';

  @override
  String get calculating => 'கணக்கிடப்படுகிறது...';

  @override
  String get statusPending => 'நிலை: நிலுவையில் உள்ளது';

  @override
  String get pending => 'நிலுவையில்';

  @override
  String get pcrTitle => 'நோயாளி பராமரிப்பு அறிக்கை';

  @override
  String get nicPassport => 'அடையாள அட்டை / கடவுச்சீட்டு எண்';

  @override
  String get age => 'வயது';

  @override
  String get bloodGroup => 'இரத்த வகை';

  @override
  String get contactNo => 'தொடர்பு எண்';

  @override
  String get guardianNextOfKin => 'பாதுகாவலர் / உறவினர்';

  @override
  String get relationship => 'உறவு';

  @override
  String get guardianContactNo => 'பாதுகாவலர் தொடர்பு எண்';

  @override
  String get idFront => 'அடையாள அட்டை முன்';

  @override
  String get idBack => 'அடையாள அட்டை பின்';

  @override
  String get emergencyType => 'அவசர வகை';

  @override
  String get chiefComplaint => 'முக்கிய புகார் / விவரம்';

  @override
  String get symptoms => 'அறிகுறிகள்';

  @override
  String get consciousLevel => 'உணர்வு நிலை';

  @override
  String get painLevel010 => 'வலி நிலை (0 - 10)';

  @override
  String get aAirway => 'A - சுவாசப்பாதை';

  @override
  String get airwayManaged => 'சுவாசப்பாதை நிர்வகிக்கப்பட்டதா?';

  @override
  String get method => 'முறை';

  @override
  String get bBreathing => 'B - சுவாசம்';

  @override
  String get respRate => 'சுவாச வீதம் (/min)';

  @override
  String get spo2 => 'SpO2 (%)';

  @override
  String get breathingAssisted => 'சுவாசம் உதவப்பட்டதா?';

  @override
  String get cCirculation => 'C - சுழற்சி';

  @override
  String get pulseMin => 'நாடித் துடிப்பு (/min)';

  @override
  String get bpMmHg => 'இரத்த அழுத்தம் (mmHg)';

  @override
  String get capillaryRefill => 'Capillary Refill';

  @override
  String get bleedingControlled => 'இரத்தப்போக்கு கட்டுப்படுத்தப்பட்டதா?';

  @override
  String get dDisability => 'D - இயலாமை';

  @override
  String get gcsScore => 'GCS மதிப்பெண்:';

  @override
  String get e14 => 'E (1-4)';

  @override
  String get v15 => 'V (1-5)';

  @override
  String get m16 => 'M (1-6)';

  @override
  String get eExposure => 'E - வெளிப்பாடு';

  @override
  String get temperatureC => 'வெப்பநிலை (°C)';

  @override
  String get noVitalsRecorded =>
      'இதுவரை உயிர் அறிகுறிகள் பதிவு செய்யப்படவில்லை.';

  @override
  String timePulseBpSpo2(String time, String pulse, String bp, String spo2) {
    return 'நேரம்: $time | நாடி: $pulse | ர.அ: $bp | SpO2: $spo2';
  }

  @override
  String get logCurrentVitals => 'தற்போதைய உயிர் அறிகுறிகளை பதிவு செய்';

  @override
  String get sSignsSymptoms => 'S - அறிகுறிகள் மற்றும் அடையாளங்கள்';

  @override
  String get aAllergies => 'A - ஒவ்வாமை';

  @override
  String get mMedications => 'M - மருந்துகள்';

  @override
  String get pPastMedicalHistory => 'P - கடந்தகால மருத்துவ வரலாறு';

  @override
  String get lLastMeal => 'L - கடைசி உணவு';

  @override
  String get eEventsLeading => 'E - நோய்/காயத்திற்கு வழிவகுத்த நிகழ்வுகள்';

  @override
  String get knownConditions => 'அறிந்த மருத்துவ நிலைகள்';

  @override
  String get interactiveBodyMapPlaceHolder => 'ஊடாடும் உடல் காயம் வரைபடம்';

  @override
  String get interactiveBodyMapHint =>
      '(தீக்காயங்கள், எலும்பு முறிவுகள், வீக்கம் போன்றவற்றைச் சேர்க்கத் தட்டவும்)';

  @override
  String get airwayManagement => 'சுவாசப்பாதை மேலாண்மை';

  @override
  String get o2Flow => 'O2 ஓட்டம் (L/min)';

  @override
  String get cardiovascular => 'இருதய அமைப்பு';

  @override
  String get immobilization => 'அசைவற்றாக்கம்';

  @override
  String get medicationGiven => 'அளிக்கப்பட்ட மருந்து';

  @override
  String get medication => 'மருந்து';

  @override
  String get dose => 'அளவு';

  @override
  String get route => 'பாதை';

  @override
  String get time => 'நேரம்';

  @override
  String get transportType => 'போக்குவரத்து வகை';

  @override
  String get departureTime => 'புறப்பட்ட நேரம்';

  @override
  String get arrivalTimeExt => 'வந்தடைந்த நேரம்';

  @override
  String get distanceCoveredKm => 'கடந்த தூரம் (கிமீ)';

  @override
  String get doctorNurseName => 'மருத்துவர் / செவிலியர் பெயர்';

  @override
  String get handoverTime => 'ஒப்படைக்கப்பட்ட நேரம்';

  @override
  String get conditionOnArrival => 'வந்தடையும் போது நிலை';

  @override
  String get handoverNotes => 'ஒப்படைப்பு குறிப்புகள்';

  @override
  String get submitPcr => 'நோயாளி பராமரிப்பு அறிக்கையைச் சமர்ப்பி';

  @override
  String get reportSubmitted => 'அறிக்கை வெற்றிகரமாக சமர்ப்பிக்கப்பட்டது!';

  @override
  String errorSavingReport(String error) {
    return 'அறிக்கையைச் சேமிப்பதில் பிழை: $error';
  }

  @override
  String get cancelTrip => 'பயணத்தை ரத்துசெய்';

  @override
  String get cancelTripConfirm =>
      'இந்த அவசர கோரிக்கையை ரத்துசெய்ய உறுதியாக இருக்கிறீர்களா?';

  @override
  String get tripCancelled => 'பயணம் ரத்துசெய்யப்பட்டது.';

  @override
  String get yesCancel => 'ஆம், ரத்துசெய்';

  @override
  String get noKeep => 'இல்லை';
}
