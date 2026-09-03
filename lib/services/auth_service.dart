import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInitialized = false;

  Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  // Email + Password Login
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final UserCredential result =
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  // Register Account
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    final UserCredential result =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return result.user;
  }

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    final GoogleSignInAccount googleUser =
    await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final OAuthCredential credential =
    GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final UserCredential result =
    await _auth.signInWithCredential(credential);

    return result.user;
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();

    try {
      await _initializeGoogleSignIn();
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore if user did not use Google Sign-In.
    }
  }

  // Current logged in user
  User? get currentUser => _auth.currentUser;
}