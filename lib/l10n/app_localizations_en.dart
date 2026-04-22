// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'STJ MediLink';

  @override
  String get loginTitle => 'Login to your Account';

  @override
  String get signupTitle => 'Create your Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get contactNumber => 'Contact Number';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get orSignInWith => '- Or sign in with -';

  @override
  String get orSignUpWith => '- Or sign up with -';

  @override
  String get noAccount => 'Don\'\'t have an account? ';

  @override
  String get signUpLink => 'Sign up';

  @override
  String get alreadyAccount => 'Already have an account? ';

  @override
  String get signInLink => 'Sign in';

  @override
  String get signInWithPhone => 'Sign in with Phone';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get otpSent => 'OTP sent!';

  @override
  String get changeNumberResend => 'Change number / Resend OTP';

  @override
  String get welcome => 'Welcome!';

  @override
  String get patientDashboard => 'Patient Dashboard';

  @override
  String get welcomePatient => 'Welcome, Patient!';

  @override
  String get ambulanceDashboard => 'EMT Dashboard';

  @override
  String get welcomeDriver => 'Welcome, EMT!';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get welcomeAdmin => 'Welcome, Admin!';

  @override
  String get signOut => 'Sign out';

  @override
  String get createAccount => 'Create Account';

  @override
  String get ambulance => 'EMT';

  @override
  String get admins => 'Admins';

  @override
  String get patients => 'Patients';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get newPassword => 'New Password (leave blank to keep)';

  @override
  String get role => 'Role';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get accountUpdated => 'Account updated successfully';

  @override
  String get accountCreated => 'account created!';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email address and we\'\'ll send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetEmailSent => 'Reset Email Sent!';

  @override
  String resetEmailSentDesc(String email) {
    return 'We\'\'ve sent a password reset link to $email. Check your inbox and follow the instructions.';
  }

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get emailRequired => 'Please enter your email address';

  @override
  String get resetLinkSent => 'Password reset link sent to your email';

  @override
  String get patient => 'Patient';

  @override
  String get sosButton => 'SOS';

  @override
  String get yourLocation => 'Your location';

  @override
  String get locating => 'Locating...';

  @override
  String requestAmbulance(String type) {
    return 'Request $type EMT';
  }

  @override
  String get confirmRequest => 'Confirm Request';

  @override
  String ambulanceType(String type) {
    return 'Type: $type EMT';
  }

  @override
  String price(String price) {
    return 'Price: $price';
  }

  @override
  String get dispatchMessage => 'An EMT will be dispatched to your location.';

  @override
  String get confirm => 'Confirm';

  @override
  String helpOnWay(String type) {
    return '🚑 $type EMT requested! Help is on the way.';
  }

  @override
  String get basicAmbulance => 'Basic';

  @override
  String get advancedAmbulance => 'Advanced';

  @override
  String get icuAmbulance => 'ICU';

  @override
  String get neonatalAmbulance => 'Neonatal';

  @override
  String get capacity2 => '2 patients';

  @override
  String get capacity1 => '1 patient';

  @override
  String get capacityInfant => '1 infant';

  @override
  String get profile => 'Profile';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get useDevicePhoneNumber => 'Use Device Phone Number';

  @override
  String get enterPhoneDesc =>
      'Enter your phone number with country code (e.g. +94771234567).\n\nYou can also type it directly in the field.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get imageTooLarge => 'Image too large. Please choose a smaller image.';

  @override
  String get useMyPhoneNumber => 'Use my phone number';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get areYouInEmergency => 'Are you in emergency?';

  @override
  String get pressButtonHelp =>
      'Press the button below help will\nreach you soon.';

  @override
  String get yourCurrentLocation => 'Your current location';

  @override
  String get tapSosToShare => 'Tap SOS to share your location';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get selectGender => 'Select gender';

  @override
  String get address => 'Address';

  @override
  String get addressHint => 'Street, City, Province';

  @override
  String get medicalInfo => 'Medical Information';

  @override
  String get bloodType => 'Blood Type';

  @override
  String get selectBloodType => 'Select blood type';

  @override
  String get medicalNotes => 'Medical Notes / Allergies';

  @override
  String get medicalNotesHint => 'e.g. Diabetic, allergic to penicillin…';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get contactName => 'Contact Name';

  @override
  String get contactPhone => 'Contact Phone';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get genderPreferNot => 'Prefer not to say';
}
