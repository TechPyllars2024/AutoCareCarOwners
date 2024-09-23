import 'package:autocare_carowners/Authentication/models/car_owner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Widgets/snackBar.dart';

class AuthenticationMethod {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // SIGN UP with Email and Password for Car Owners
  Future<String> signupCarOwner({
    required String name,
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return "Please provide all the fields";
    }
    try {
      // Check if the user already exists in the "users" collection
      DocumentSnapshot existingUserDoc =
          await firestore.collection("users").doc(email).get();

      if (existingUserDoc.exists) {
        UserModel existingUser =
            UserModel.fromMap(existingUserDoc.data() as Map<String, dynamic>);
        if (existingUser.roles.contains('service_provider')) {
          return "You already have an account as a service provider";
        }
      }

      // Register the user with email and password
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create the UserModel for a car owner
      UserModel newUser = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        roles: ['car_owner'], // Set role to car_owner
      );

      // Add the user to Firestore in the "users" collection
      await firestore.collection("users").doc(newUser.uid).set(newUser.toMap());

      return 'SUCCESS';
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // LOG IN with Email and Password
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return "Please provide all the fields";
    }

    try {
      // Logging in user with email and password
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "SUCCESS";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      Utils.showSnackBar("An error occurred while signing out");
    }
  }

  // RESET PASSWORD
  Future<String> resetPassword({
    required String email,
  }) async {
    if (email.isEmpty) {
      return "Please provide an email";
    }

    try {
      // Query Firestore to check if the email exists in the "users" collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Check if any documents were returned
      if (querySnapshot.docs.isEmpty) {
        return "No account found with that email";
      }

      // If email exists, proceed to send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      return "A reset link has been sent.";
    } on FirebaseAuthException catch (e) {
      // Handle specific errors
      if (e.code == 'invalid-email') {
        return "The email address is badly formatted";
      } else if (e.code == 'too-many-requests') {
        return "Too many requests, please try again later";
      } else {
        return e.message ?? "An error occurred";
      }
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // SIGN IN/LOG IN WITH GOOGLE
  Future<String> signInWithGoogleForCarOwner() async {
    try {
      // Initiate Google Sign-In process
      // Initiate Google Sign-In process
      final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: [
            "https://www.googleapis.com/auth/userinfo.profile",
            "https://www.googleapis.com/auth/userinfo.email"
          ]
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return "Google Sign-In aborted";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get the credentials from Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return "Google Sign-In failed";
      }

      // Check if the user already exists as a service provider
      QuerySnapshot existingServiceProvider = await firestore
          .collection("users")
          .where('email', isEqualTo: user.email)
          .where('roles', arrayContains: 'service_provider')
          .get();

      if (existingServiceProvider.docs.isNotEmpty) {
        // Sign out the user from Google Sign-In
        await googleSignIn.signOut();
        return "You already have an account as a service provider. Please sign in with a different account.";
      }

      // Check if the user already exists as a car owner
      QuerySnapshot existingCarOwner = await firestore
          .collection("users")
          .where('email', isEqualTo: user.email)
          .where('roles', arrayContains: 'car_owner')
          .get();

      if (existingCarOwner.docs.isNotEmpty) {
        // Sign out the user from Google Sign-In
        await googleSignIn.signOut();
        return "You already have an account as a car owner. Please sign in with a different account.";
      }

      // Create the CarOwnerModel and store in Firestore
      UserModel newUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? "No Name",
        email: user.email ?? "No Email",
        roles: ['car_owner'],
      );

      await firestore.collection("users").doc(newUser.uid).set(newUser.toMap());

      return 'SUCCESS';
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // Handles Google Log-In and checks user role for Car Owners
  Future<String> logInWithGoogleForCarOwners() async {
    try {
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn(
          scopes: [
            "https://www.googleapis.com/auth/userinfo.profile",
            "https://www.googleapis.com/auth/userinfo.email"
          ]
      ).signIn();
      if (googleUser == null) {
        return "Google Log-In aborted";
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return "Google Log-In failed";
      }

      DocumentSnapshot userDoc = await firestore.collection("users").doc(user.uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        List<dynamic> roles = userData['roles'] ?? [];
        if (roles.contains('car_owner')) {
          return "Car Owner";
        } else {
          return "You are not registered as a car owner";
        }
      } else {
        return "User does not exist. Please register first.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "An unexpected error occurred";
    }
  }
}
