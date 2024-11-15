import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationMethodLogIn {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // LOG IN with Email and Password
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return "Please enter both your email and password.";
    }
    try {
      // Logging in user with email and password
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the logged-in user
      User user = userCredential.user!;

      // Check if user document exists in Firestore
      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(user.uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        // Check for "roles" field and if "car_owner" is present
        List<dynamic>? roles = userData['roles'];
        if (roles?.contains('car_owner') ?? false) {
          return "SUCCESS";
        } else {
          return "You are not registered as a car owner. Please use the appropriate account.";
        }
      } else {
        return "No account found. Please register as a car owner.";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No account found with this email. Please check or sign up.";
        case 'wrong-password':
          return "Incorrect password. Please try again.";
        case 'invalid-email':
          return "The email address format is not valid. Please check and try again.";
        case 'user-disabled':
          return "This account has been disabled. Please contact support.";
        case 'invalid-credential':
          return "The entered email/password is invalid. Please check your inputs.";
        default:
          return e.message ?? "An unknown error occurred. Please try again.";
      }
    } catch (e) {
      return "Something went wrong. Please try again later.";
    }
  }

  // Handles Google Log-In and checks user role for Car Owners
  Future<String> logInWithGoogleForCarOwners() async {
    try {
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: [
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://www.googleapis.com/auth/userinfo.email"
      ]).signIn();
      if (googleUser == null) {
        return "Google Log-In was canceled. Please try again.";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return "Failed to log in with Google. Please try again.";
      }

      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(user.uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        List<dynamic> roles = userData['roles'] ?? [];
        if (roles.contains('car_owner')) {
          return "Car Owner";
        } else {
          return "You are not registered as a car owner. Please use the appropriate account.";
        }
      } else {
        return "No account found. Please register as a car owner.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message ??
          "A problem occurred during Google Log-In. Please try again.";
    } catch (e) {
      return "An unexpected error occurred. Please try again later.";
    }
  }
}
