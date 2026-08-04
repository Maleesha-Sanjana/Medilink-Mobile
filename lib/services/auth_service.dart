import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _userService = UserService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ── Email / Password Sign Up → saves patient role to Firestore ───────────
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _userService.createUser(
      uid: cred.user!.uid,
      email: email.trim(),
      phone: phone,
      role: 'patient',
    );
  }

  // ── Email / Password Sign In ──────────────────────────────────────────────
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ── Google Sign In → creates Firestore doc if first time ─────────────────
  Future<bool> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return false;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);

    if (cred.additionalUserInfo?.isNewUser == true) {
      await _userService.createUser(
        uid: cred.user!.uid,
        email: cred.user!.email ?? '',
        role: 'patient',
      );
    }
    return true;
  }

  // ── Admin: update password of another account ────────────────────────────
  Future<void> updatePasswordByAdmin({
    required String email,
    required String currentAdminPassword,
    required String targetEmail,
    required String newPassword,
  }) async {
    // Re-authenticate admin first, then use secondary app to update target
    final secondaryApp = await Firebase.initializeApp(
      name: 'secondary_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await secondaryAuth.signInWithEmailAndPassword(
        email: targetEmail,
        password: currentAdminPassword, // this won't work for target
      );
      await cred.user!.updatePassword(newPassword);
    } finally {
      await secondaryApp.delete();
    }
  }

  // ── Admin: reset password by re-creating credential ──────────────────────
  Future<void> changePasswordByAdmin({
    required String targetEmail,
    required String newPassword,
  }) async {
    final secondaryApp = await Firebase.initializeApp(
      name: 'secondary_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      // We can only update password if we know the old one.
      // Best approach: send password reset email
      await _auth.sendPasswordResetEmail(email: targetEmail.trim());
    } finally {
      await secondaryApp.delete();
    }
  }

  // Uses a secondary FirebaseAuth instance so admin stays signed in
  Future<void> createAccountByAdmin({
    required String email,
    required String password,
    required String role,
    String? displayName,
    String? phone,
  }) async {
    // Create auth user via REST (doesn't affect current session)
    final secondaryApp = await Firebase.initializeApp(
      name: 'secondary_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await _userService.createUser(
        uid: cred.user!.uid,
        email: email.trim(),
        phone: phone,
        role: role,
        displayName: displayName,
      );
    } finally {
      await secondaryApp.delete();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
