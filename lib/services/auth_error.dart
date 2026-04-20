import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please enable it in Firebase Console → Authentication → Sign-in method.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'internal-error':
        return 'Firebase internal error. Make sure sign-in methods are enabled in Firebase Console → Authentication.';
      case 'invalid-phone-number':
        return 'Invalid phone number. Use format: +94771234567';
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new one.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
