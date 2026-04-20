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
}
