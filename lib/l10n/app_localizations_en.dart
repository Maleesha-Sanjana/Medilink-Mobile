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
  String get medicalHistory => 'Medical History';

  @override
  String get medicalHistoryHint => 'Past illnesses, surgeries, family history…';

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

  @override
  String get paymentDetails => 'Payment Details';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date (MM/YY)';

  @override
  String get cvv => 'CVV';

  @override
  String get hospitalsTab => 'Hospitals';

  @override
  String get noHospitals => 'No hospitals added yet';

  @override
  String get addHospital => 'Add Hospital';

  @override
  String get registerHospital => 'Register Hospital';

  @override
  String get hospitalName => 'Hospital Name';

  @override
  String get locationAcquired => 'Location Acquired';

  @override
  String get fetchLocation => 'Fetch Current Location';

  @override
  String get register => 'Register';

  @override
  String get deleteHospital => 'Delete Hospital';

  @override
  String deleteHospitalConfirm(String name) {
    return 'Delete hospital $name?';
  }

  @override
  String get hospitalRegistered => 'Hospital registered successfully!';

  @override
  String get fetchLocationFirst => 'Please fetch the location first';

  @override
  String get hospitalNameRequired => 'Hospital name is required';

  @override
  String get hospitalDeleted => 'Hospital deleted';

  @override
  String get selectDestination => 'Select Destination';

  @override
  String distanceKm(String distance) {
    return 'Distance: $distance km';
  }

  @override
  String estimatedFare(String fare) {
    return 'Estimated Fare: $fare';
  }

  @override
  String get startTrip => 'Start Trip';

  @override
  String get arrivingNow => 'Arriving now';

  @override
  String minAway(String mins) {
    return '$mins min away';
  }

  @override
  String mAwayTime(String meters, String timeStr) {
    return '$meters m away • $timeStr';
  }

  @override
  String kmAwayTime(String km, String timeStr) {
    return '$km km away • $timeStr';
  }

  @override
  String get transportingToHospital => 'Transporting to Hospital!';

  @override
  String get emtOnTheWay => 'EMT is on the way!';

  @override
  String get hospital => 'Hospital';

  @override
  String get ambulanceWord => 'Ambulance';

  @override
  String enRouteTo(String hospitalName) {
    return 'En Route to $hospitalName';
  }

  @override
  String get emtAcceptedEnRoute => 'EMT Accepted & En Route';

  @override
  String hospitalTripFare(String price) {
    return 'Hospital Trip Fare: $price';
  }

  @override
  String get liveLocationUpdating => 'Live location updating every 5s';

  @override
  String get waitingForEmtLocation => 'Waiting for EMT location…';

  @override
  String get emtHasArrived => 'EMT Has Arrived!';

  @override
  String get emtAssessing =>
      'The EMT is currently assessing the patient and filling out the initial Patient Care Report. Please stand by.';

  @override
  String get estimatedInitialFare =>
      'Estimated Initial Fare (Callout + EMT Travel)';

  @override
  String get calculating => 'Calculating...';

  @override
  String get statusPending => 'Status: Pending';

  @override
  String get pending => 'PENDING';

  @override
  String get pcrTitle => 'Patient Care Report';

  @override
  String get nicPassport => 'NIC / Passport No.';

  @override
  String get age => 'Age';

  @override
  String get bloodGroup => 'Blood Group';

  @override
  String get contactNo => 'Contact No.';

  @override
  String get guardianNextOfKin => 'Guardian / Next of Kin';

  @override
  String get relationship => 'Relationship';

  @override
  String get guardianContactNo => 'Guardian Contact No.';

  @override
  String get idFront => 'ID Front';

  @override
  String get idBack => 'ID Back';

  @override
  String get emergencyType => 'Emergency Type';

  @override
  String get chiefComplaint => 'Chief Complaint / Description';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get consciousLevel => 'Conscious Level';

  @override
  String get painLevel010 => 'Pain Level (0 - 10)';

  @override
  String get aAirway => 'A - Airway';

  @override
  String get airwayManaged => 'Airway Managed?';

  @override
  String get method => 'Method';

  @override
  String get bBreathing => 'B - Breathing';

  @override
  String get respRate => 'Resp. Rate (/min)';

  @override
  String get spo2 => 'SpO2 (%)';

  @override
  String get breathingAssisted => 'Breathing Assisted?';

  @override
  String get cCirculation => 'C - Circulation';

  @override
  String get pulseMin => 'Pulse (/min)';

  @override
  String get bpMmHg => 'BP (mmHg)';

  @override
  String get capillaryRefill => 'Capillary Refill';

  @override
  String get bleedingControlled => 'Bleeding Controlled?';

  @override
  String get dDisability => 'D - Disability';

  @override
  String get gcsScore => 'GCS Score:';

  @override
  String get e14 => 'E (1-4)';

  @override
  String get v15 => 'V (1-5)';

  @override
  String get m16 => 'M (1-6)';

  @override
  String get eExposure => 'E - Exposure';

  @override
  String get temperatureC => 'Temperature (°C)';

  @override
  String get noVitalsRecorded => 'No vital signs recorded yet.';

  @override
  String timePulseBpSpo2(String time, String pulse, String bp, String spo2) {
    return 'Time: $time | Pulse: $pulse | BP: $bp | SpO2: $spo2';
  }

  @override
  String get logCurrentVitals => 'Log Current Vitals';

  @override
  String get sSignsSymptoms => 'S - Signs & Symptoms';

  @override
  String get aAllergies => 'A - Allergies';

  @override
  String get mMedications => 'M - Medications';

  @override
  String get pPastMedicalHistory => 'P - Past Medical History';

  @override
  String get lLastMeal => 'L - Last Meal';

  @override
  String get eEventsLeading => 'E - Events Leading to Illness/Injury';

  @override
  String get knownConditions => 'Known Conditions';

  @override
  String get interactiveBodyMapPlaceHolder =>
      'Interactive Body Injury Map Placeholder';

  @override
  String get interactiveBodyMapHint =>
      '(Tap to add markers for burns, fractures, swelling, etc.)';

  @override
  String get airwayManagement => 'AIRWAY MANAGEMENT';

  @override
  String get o2Flow => 'O2 Flow (L/min)';

  @override
  String get cardiovascular => 'CARDIOVASCULAR';

  @override
  String get immobilization => 'IMMOBILIZATION';

  @override
  String get medicationGiven => 'MEDICATION GIVEN';

  @override
  String get medication => 'Medication';

  @override
  String get dose => 'Dose';

  @override
  String get route => 'Route';

  @override
  String get time => 'Time';

  @override
  String get transportType => 'Transport Type';

  @override
  String get departureTime => 'Departure Time';

  @override
  String get arrivalTimeExt => 'Arrival Time (Ext.)';

  @override
  String get distanceCoveredKm => 'Distance Covered (km)';

  @override
  String get doctorNurseName => 'Doctor / Nurse Name';

  @override
  String get handoverTime => 'Handover Time';

  @override
  String get conditionOnArrival => 'Condition on Arrival';

  @override
  String get handoverNotes => 'Handover Notes';

  @override
  String get submitPcr => 'SUBMIT PATIENT CARE REPORT';

  @override
  String get reportSubmitted => 'Report submitted successfully!';

  @override
  String errorSavingReport(String error) {
    return 'Error saving report: $error';
  }

  @override
  String get cancelTrip => 'Cancel Trip';

  @override
  String get cancelTripConfirm =>
      'Are you sure you want to cancel this emergency request?';

  @override
  String get tripCancelled => 'The trip has been cancelled.';

  @override
  String get yesCancel => 'Yes, Cancel';

  @override
  String get noKeep => 'No, Keep';
}
