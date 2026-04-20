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
}
