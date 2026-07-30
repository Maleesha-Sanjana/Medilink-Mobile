import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'STJ MediLink'**
  String get appName;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to your Account'**
  String get loginTitle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your Account'**
  String get signupTitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @orSignInWith.
  ///
  /// In en, this message translates to:
  /// **'- Or sign in with -'**
  String get orSignInWith;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'- Or sign up with -'**
  String get orSignUpWith;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpLink;

  /// No description provided for @alreadyAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyAccount;

  /// No description provided for @signInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInLink;

  /// No description provided for @signInWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Phone'**
  String get signInWithPhone;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent!'**
  String get otpSent;

  /// No description provided for @changeNumberResend.
  ///
  /// In en, this message translates to:
  /// **'Change number / Resend OTP'**
  String get changeNumberResend;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcome;

  /// No description provided for @patientDashboard.
  ///
  /// In en, this message translates to:
  /// **'Patient Dashboard'**
  String get patientDashboard;

  /// No description provided for @welcomePatient.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Patient!'**
  String get welcomePatient;

  /// No description provided for @ambulanceDashboard.
  ///
  /// In en, this message translates to:
  /// **'EMT Dashboard'**
  String get ambulanceDashboard;

  /// No description provided for @welcomeDriver.
  ///
  /// In en, this message translates to:
  /// **'Welcome, EMT!'**
  String get welcomeDriver;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @welcomeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Admin!'**
  String get welcomeAdmin;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @ambulance.
  ///
  /// In en, this message translates to:
  /// **'EMT'**
  String get ambulance;

  /// No description provided for @admins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get admins;

  /// No description provided for @patients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patients;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password (leave blank to keep)'**
  String get newPassword;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @accountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account updated successfully'**
  String get accountUpdated;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'account created!'**
  String get accountCreated;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleted;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'\'ll send you a link to reset your password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset Email Sent!'**
  String get resetEmailSent;

  /// No description provided for @resetEmailSentDesc.
  ///
  /// In en, this message translates to:
  /// **'We\'\'ve sent a password reset link to {email}. Check your inbox and follow the instructions.'**
  String resetEmailSentDesc(String email);

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get emailRequired;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to your email'**
  String get resetLinkSent;

  /// No description provided for @patient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patient;

  /// No description provided for @sosButton.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sosButton;

  /// No description provided for @yourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get yourLocation;

  /// No description provided for @locating.
  ///
  /// In en, this message translates to:
  /// **'Locating...'**
  String get locating;

  /// No description provided for @requestAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Request {type} EMT'**
  String requestAmbulance(String type);

  /// No description provided for @confirmRequest.
  ///
  /// In en, this message translates to:
  /// **'Confirm Request'**
  String get confirmRequest;

  /// No description provided for @ambulanceType.
  ///
  /// In en, this message translates to:
  /// **'Type: {type} EMT'**
  String ambulanceType(String type);

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price: {price}'**
  String price(String price);

  /// No description provided for @dispatchMessage.
  ///
  /// In en, this message translates to:
  /// **'An EMT will be dispatched to your location.'**
  String get dispatchMessage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @helpOnWay.
  ///
  /// In en, this message translates to:
  /// **'🚑 {type} EMT requested! Help is on the way.'**
  String helpOnWay(String type);

  /// No description provided for @basicAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basicAmbulance;

  /// No description provided for @advancedAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedAmbulance;

  /// No description provided for @icuAmbulance.
  ///
  /// In en, this message translates to:
  /// **'ICU'**
  String get icuAmbulance;

  /// No description provided for @neonatalAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Neonatal'**
  String get neonatalAmbulance;

  /// No description provided for @capacity2.
  ///
  /// In en, this message translates to:
  /// **'2 patients'**
  String get capacity2;

  /// No description provided for @capacity1.
  ///
  /// In en, this message translates to:
  /// **'1 patient'**
  String get capacity1;

  /// No description provided for @capacityInfant.
  ///
  /// In en, this message translates to:
  /// **'1 infant'**
  String get capacityInfant;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @useDevicePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Use Device Phone Number'**
  String get useDevicePhoneNumber;

  /// No description provided for @enterPhoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number with country code (e.g. +94771234567).\n\nYou can also type it directly in the field.'**
  String get enterPhoneDesc;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image too large. Please choose a smaller image.'**
  String get imageTooLarge;

  /// No description provided for @useMyPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Use my phone number'**
  String get useMyPhoneNumber;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @areYouInEmergency.
  ///
  /// In en, this message translates to:
  /// **'Are you in emergency?'**
  String get areYouInEmergency;

  /// No description provided for @pressButtonHelp.
  ///
  /// In en, this message translates to:
  /// **'Press the button below help will\nreach you soon.'**
  String get pressButtonHelp;

  /// No description provided for @yourCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Your current location'**
  String get yourCurrentLocation;

  /// No description provided for @tapSosToShare.
  ///
  /// In en, this message translates to:
  /// **'Tap SOS to share your location'**
  String get tapSosToShare;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get selectGender;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, City, Province'**
  String get addressHint;

  /// No description provided for @medicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInfo;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @selectBloodType.
  ///
  /// In en, this message translates to:
  /// **'Select blood type'**
  String get selectBloodType;

  /// No description provided for @medicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Medical Notes / Allergies'**
  String get medicalNotes;

  /// No description provided for @medicalNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Diabetic, allergic to penicillin…'**
  String get medicalNotesHint;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @medicalHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Past illnesses, surgeries, family history…'**
  String get medicalHistoryHint;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone'**
  String get contactPhone;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @genderPreferNot.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNot;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get paymentDetails;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date (MM/YY)'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @hospitalsTab.
  ///
  /// In en, this message translates to:
  /// **'Hospitals'**
  String get hospitalsTab;

  /// No description provided for @noHospitals.
  ///
  /// In en, this message translates to:
  /// **'No hospitals added yet'**
  String get noHospitals;

  /// No description provided for @addHospital.
  ///
  /// In en, this message translates to:
  /// **'Add Hospital'**
  String get addHospital;

  /// No description provided for @registerHospital.
  ///
  /// In en, this message translates to:
  /// **'Register Hospital'**
  String get registerHospital;

  /// No description provided for @hospitalName.
  ///
  /// In en, this message translates to:
  /// **'Hospital Name'**
  String get hospitalName;

  /// No description provided for @locationAcquired.
  ///
  /// In en, this message translates to:
  /// **'Location Acquired'**
  String get locationAcquired;

  /// No description provided for @fetchLocation.
  ///
  /// In en, this message translates to:
  /// **'Fetch Current Location'**
  String get fetchLocation;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @deleteHospital.
  ///
  /// In en, this message translates to:
  /// **'Delete Hospital'**
  String get deleteHospital;

  /// No description provided for @deleteHospitalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete hospital {name}?'**
  String deleteHospitalConfirm(String name);

  /// No description provided for @hospitalRegistered.
  ///
  /// In en, this message translates to:
  /// **'Hospital registered successfully!'**
  String get hospitalRegistered;

  /// No description provided for @fetchLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Please fetch the location first'**
  String get fetchLocationFirst;

  /// No description provided for @hospitalNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Hospital name is required'**
  String get hospitalNameRequired;

  /// No description provided for @hospitalDeleted.
  ///
  /// In en, this message translates to:
  /// **'Hospital deleted'**
  String get hospitalDeleted;

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get selectDestination;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'Distance: {distance} km'**
  String distanceKm(String distance);

  /// No description provided for @estimatedFare.
  ///
  /// In en, this message translates to:
  /// **'Estimated Fare: {fare}'**
  String estimatedFare(String fare);

  /// No description provided for @startTrip.
  ///
  /// In en, this message translates to:
  /// **'Start Trip'**
  String get startTrip;

  /// No description provided for @arrivingNow.
  ///
  /// In en, this message translates to:
  /// **'Arriving now'**
  String get arrivingNow;

  /// No description provided for @minAway.
  ///
  /// In en, this message translates to:
  /// **'{mins} min away'**
  String minAway(String mins);

  /// No description provided for @mAwayTime.
  ///
  /// In en, this message translates to:
  /// **'{meters} m away • {timeStr}'**
  String mAwayTime(String meters, String timeStr);

  /// No description provided for @kmAwayTime.
  ///
  /// In en, this message translates to:
  /// **'{km} km away • {timeStr}'**
  String kmAwayTime(String km, String timeStr);

  /// No description provided for @transportingToHospital.
  ///
  /// In en, this message translates to:
  /// **'Transporting to Hospital!'**
  String get transportingToHospital;

  /// No description provided for @emtOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'EMT is on the way!'**
  String get emtOnTheWay;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @ambulanceWord.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get ambulanceWord;

  /// No description provided for @enRouteTo.
  ///
  /// In en, this message translates to:
  /// **'En Route to {hospitalName}'**
  String enRouteTo(String hospitalName);

  /// No description provided for @emtAcceptedEnRoute.
  ///
  /// In en, this message translates to:
  /// **'EMT Accepted & En Route'**
  String get emtAcceptedEnRoute;

  /// No description provided for @hospitalTripFare.
  ///
  /// In en, this message translates to:
  /// **'Hospital Trip Fare: {price}'**
  String hospitalTripFare(String price);

  /// No description provided for @liveLocationUpdating.
  ///
  /// In en, this message translates to:
  /// **'Live location updating every 5s'**
  String get liveLocationUpdating;

  /// No description provided for @waitingForEmtLocation.
  ///
  /// In en, this message translates to:
  /// **'Waiting for EMT location…'**
  String get waitingForEmtLocation;

  /// No description provided for @emtHasArrived.
  ///
  /// In en, this message translates to:
  /// **'EMT Has Arrived!'**
  String get emtHasArrived;

  /// No description provided for @emtAssessing.
  ///
  /// In en, this message translates to:
  /// **'The EMT is currently assessing the patient and filling out the initial Patient Care Report. Please stand by.'**
  String get emtAssessing;

  /// No description provided for @estimatedInitialFare.
  ///
  /// In en, this message translates to:
  /// **'Estimated Initial Fare (Callout + EMT Travel)'**
  String get estimatedInitialFare;

  /// No description provided for @calculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get calculating;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Status: Pending'**
  String get statusPending;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pending;

  /// No description provided for @pcrTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient Care Report'**
  String get pcrTitle;

  /// No description provided for @nicPassport.
  ///
  /// In en, this message translates to:
  /// **'NIC / Passport No.'**
  String get nicPassport;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @contactNo.
  ///
  /// In en, this message translates to:
  /// **'Contact No.'**
  String get contactNo;

  /// No description provided for @guardianNextOfKin.
  ///
  /// In en, this message translates to:
  /// **'Guardian / Next of Kin'**
  String get guardianNextOfKin;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @guardianContactNo.
  ///
  /// In en, this message translates to:
  /// **'Guardian Contact No.'**
  String get guardianContactNo;

  /// No description provided for @idFront.
  ///
  /// In en, this message translates to:
  /// **'ID Front'**
  String get idFront;

  /// No description provided for @idBack.
  ///
  /// In en, this message translates to:
  /// **'ID Back'**
  String get idBack;

  /// No description provided for @emergencyType.
  ///
  /// In en, this message translates to:
  /// **'Emergency Type'**
  String get emergencyType;

  /// No description provided for @chiefComplaint.
  ///
  /// In en, this message translates to:
  /// **'Chief Complaint / Description'**
  String get chiefComplaint;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @consciousLevel.
  ///
  /// In en, this message translates to:
  /// **'Conscious Level'**
  String get consciousLevel;

  /// No description provided for @painLevel010.
  ///
  /// In en, this message translates to:
  /// **'Pain Level (0 - 10)'**
  String get painLevel010;

  /// No description provided for @aAirway.
  ///
  /// In en, this message translates to:
  /// **'A - Airway'**
  String get aAirway;

  /// No description provided for @airwayManaged.
  ///
  /// In en, this message translates to:
  /// **'Airway Managed?'**
  String get airwayManaged;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @bBreathing.
  ///
  /// In en, this message translates to:
  /// **'B - Breathing'**
  String get bBreathing;

  /// No description provided for @respRate.
  ///
  /// In en, this message translates to:
  /// **'Resp. Rate (/min)'**
  String get respRate;

  /// No description provided for @spo2.
  ///
  /// In en, this message translates to:
  /// **'SpO2 (%)'**
  String get spo2;

  /// No description provided for @breathingAssisted.
  ///
  /// In en, this message translates to:
  /// **'Breathing Assisted?'**
  String get breathingAssisted;

  /// No description provided for @cCirculation.
  ///
  /// In en, this message translates to:
  /// **'C - Circulation'**
  String get cCirculation;

  /// No description provided for @pulseMin.
  ///
  /// In en, this message translates to:
  /// **'Pulse (/min)'**
  String get pulseMin;

  /// No description provided for @bpMmHg.
  ///
  /// In en, this message translates to:
  /// **'BP (mmHg)'**
  String get bpMmHg;

  /// No description provided for @capillaryRefill.
  ///
  /// In en, this message translates to:
  /// **'Capillary Refill'**
  String get capillaryRefill;

  /// No description provided for @bleedingControlled.
  ///
  /// In en, this message translates to:
  /// **'Bleeding Controlled?'**
  String get bleedingControlled;

  /// No description provided for @dDisability.
  ///
  /// In en, this message translates to:
  /// **'D - Disability'**
  String get dDisability;

  /// No description provided for @gcsScore.
  ///
  /// In en, this message translates to:
  /// **'GCS Score:'**
  String get gcsScore;

  /// No description provided for @e14.
  ///
  /// In en, this message translates to:
  /// **'E (1-4)'**
  String get e14;

  /// No description provided for @v15.
  ///
  /// In en, this message translates to:
  /// **'V (1-5)'**
  String get v15;

  /// No description provided for @m16.
  ///
  /// In en, this message translates to:
  /// **'M (1-6)'**
  String get m16;

  /// No description provided for @eExposure.
  ///
  /// In en, this message translates to:
  /// **'E - Exposure'**
  String get eExposure;

  /// No description provided for @temperatureC.
  ///
  /// In en, this message translates to:
  /// **'Temperature (°C)'**
  String get temperatureC;

  /// No description provided for @noVitalsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No vital signs recorded yet.'**
  String get noVitalsRecorded;

  /// No description provided for @timePulseBpSpo2.
  ///
  /// In en, this message translates to:
  /// **'Time: {time} | Pulse: {pulse} | BP: {bp} | SpO2: {spo2}'**
  String timePulseBpSpo2(String time, String pulse, String bp, String spo2);

  /// No description provided for @logCurrentVitals.
  ///
  /// In en, this message translates to:
  /// **'Log Current Vitals'**
  String get logCurrentVitals;

  /// No description provided for @sSignsSymptoms.
  ///
  /// In en, this message translates to:
  /// **'S - Signs & Symptoms'**
  String get sSignsSymptoms;

  /// No description provided for @aAllergies.
  ///
  /// In en, this message translates to:
  /// **'A - Allergies'**
  String get aAllergies;

  /// No description provided for @mMedications.
  ///
  /// In en, this message translates to:
  /// **'M - Medications'**
  String get mMedications;

  /// No description provided for @pPastMedicalHistory.
  ///
  /// In en, this message translates to:
  /// **'P - Past Medical History'**
  String get pPastMedicalHistory;

  /// No description provided for @lLastMeal.
  ///
  /// In en, this message translates to:
  /// **'L - Last Meal'**
  String get lLastMeal;

  /// No description provided for @eEventsLeading.
  ///
  /// In en, this message translates to:
  /// **'E - Events Leading to Illness/Injury'**
  String get eEventsLeading;

  /// No description provided for @knownConditions.
  ///
  /// In en, this message translates to:
  /// **'Known Conditions'**
  String get knownConditions;

  /// No description provided for @interactiveBodyMapPlaceHolder.
  ///
  /// In en, this message translates to:
  /// **'Interactive Body Injury Map Placeholder'**
  String get interactiveBodyMapPlaceHolder;

  /// No description provided for @interactiveBodyMapHint.
  ///
  /// In en, this message translates to:
  /// **'(Tap to add markers for burns, fractures, swelling, etc.)'**
  String get interactiveBodyMapHint;

  /// No description provided for @airwayManagement.
  ///
  /// In en, this message translates to:
  /// **'AIRWAY MANAGEMENT'**
  String get airwayManagement;

  /// No description provided for @o2Flow.
  ///
  /// In en, this message translates to:
  /// **'O2 Flow (L/min)'**
  String get o2Flow;

  /// No description provided for @cardiovascular.
  ///
  /// In en, this message translates to:
  /// **'CARDIOVASCULAR'**
  String get cardiovascular;

  /// No description provided for @immobilization.
  ///
  /// In en, this message translates to:
  /// **'IMMOBILIZATION'**
  String get immobilization;

  /// No description provided for @medicationGiven.
  ///
  /// In en, this message translates to:
  /// **'MEDICATION GIVEN'**
  String get medicationGiven;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @transportType.
  ///
  /// In en, this message translates to:
  /// **'Transport Type'**
  String get transportType;

  /// No description provided for @departureTime.
  ///
  /// In en, this message translates to:
  /// **'Departure Time'**
  String get departureTime;

  /// No description provided for @arrivalTimeExt.
  ///
  /// In en, this message translates to:
  /// **'Arrival Time (Ext.)'**
  String get arrivalTimeExt;

  /// No description provided for @distanceCoveredKm.
  ///
  /// In en, this message translates to:
  /// **'Distance Covered (km)'**
  String get distanceCoveredKm;

  /// No description provided for @doctorNurseName.
  ///
  /// In en, this message translates to:
  /// **'Doctor / Nurse Name'**
  String get doctorNurseName;

  /// No description provided for @handoverTime.
  ///
  /// In en, this message translates to:
  /// **'Handover Time'**
  String get handoverTime;

  /// No description provided for @conditionOnArrival.
  ///
  /// In en, this message translates to:
  /// **'Condition on Arrival'**
  String get conditionOnArrival;

  /// No description provided for @handoverNotes.
  ///
  /// In en, this message translates to:
  /// **'Handover Notes'**
  String get handoverNotes;

  /// No description provided for @submitPcr.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT PATIENT CARE REPORT'**
  String get submitPcr;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully!'**
  String get reportSubmitted;

  /// No description provided for @errorSavingReport.
  ///
  /// In en, this message translates to:
  /// **'Error saving report: {error}'**
  String errorSavingReport(String error);

  /// No description provided for @cancelTrip.
  ///
  /// In en, this message translates to:
  /// **'Cancel Trip'**
  String get cancelTrip;

  /// No description provided for @cancelTripConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this emergency request?'**
  String get cancelTripConfirm;

  /// No description provided for @tripCancelled.
  ///
  /// In en, this message translates to:
  /// **'The trip has been cancelled.'**
  String get tripCancelled;

  /// No description provided for @yesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get yesCancel;

  /// No description provided for @noKeep.
  ///
  /// In en, this message translates to:
  /// **'No, Keep'**
  String get noKeep;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
