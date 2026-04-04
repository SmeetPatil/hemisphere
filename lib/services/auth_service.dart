import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Singleton service wrapping Firebase Authentication.
///
/// Provides email/password, Google Sign-In, and phone OTP authentication.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? 'demo-web-client-id.apps.googleusercontent.com'
        : null,
  );

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// Real-time stream of auth state changes (login / logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in user, or `null` if not signed in.
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => currentUser != null;

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------

  /// Create a new account with email and password.
  /// Throws [FirebaseAuthException] on failure.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign in with email and password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Sign in with Google. Returns `null` if the user cancelled the flow.
  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Ensure we have tokens
    if (googleAuth.accessToken == null && googleAuth.idToken == null) {
      throw Exception('No auth tokens received from Google Sign-In');
    }

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    return await _auth.signInWithCredential(credential);
  }

  // ---------------------------------------------------------------------------
  // Phone / SMS OTP
  // ---------------------------------------------------------------------------

  /// Send an SMS verification code to [phoneNumber].
  ///
  /// [onCodeSent] is called with the verification ID when the SMS is sent.
  /// [onVerificationCompleted] is called on Android when auto-verification
  /// completes (the phone number is automatically verified).
  /// [onError] is called when verification fails.
  Future<void> verifyPhone({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(PhoneAuthCredential credential)
        onVerificationCompleted,
    required void Function(FirebaseAuthException error) onError,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onError,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
      timeout: const Duration(seconds: 60),
    );
  }

  /// Confirm the OTP code and sign in.
  Future<UserCredential> confirmPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ---------------------------------------------------------------------------
  // Account Management
  // ---------------------------------------------------------------------------

  /// Sign out of all providers.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Delete the current user's account. Requires recent authentication.
  Future<void> deleteAccount() async {
    await currentUser?.delete();
  }

  /// Update the display name of the current user.
  Future<void> updateDisplayName(String name) async {
    await currentUser?.updateDisplayName(name);
    await currentUser?.reload();
  }

  /// A user-friendly error message from a [FirebaseAuthException].
  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'The OTP code is invalid. Please try again.';
      case 'invalid-phone-number':
        return 'Please enter a valid phone number with country code.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
