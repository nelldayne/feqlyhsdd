import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Start Google sign-in process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If the sign-in is canceled, return null
      if (googleUser == null) {
        return null;
      }

      // Get Google authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a credential using the Google ID token and access token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Return the signed-in user
      return userCredential.user;
    } catch (e) {
      print("Error signing in with Google: $e");
      return null; // Handle any errors by returning null
    }
  }

  // Sign out function
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
