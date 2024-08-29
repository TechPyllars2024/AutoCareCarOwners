import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // SIGN UP with Email and Password
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Unfortunately, some errors occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        //register the user with email and password
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        //add the user to firestore database
        print(credential.user!.uid);
        await _firestore
            .collection("users")
            .doc(credential.user!.uid)
            .set({'name': name, 'uid': credential.user!.uid, 'email': email});
        res = 'Success!';
      } else {
        res = "Please fill in all fields.";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        res = 'The email address is badly formatted.';
      } else if (e.code == 'weak-password') {
        res = 'The password provided is too weak.';
      } else {
        res = e.message ?? "An unknown error occurred.";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // LOG IN with Email and Password
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Unfortunately, some errors occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //logging in user with email and password
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "SUCCESS";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

//SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // SIGN IN WITH GOOGLE
  Future<String> signInWithGoogle() async {
    String res = "Unfortunately, some errors occurred";
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(credential);

        // Check if the user already exists in the Firestore database
        DocumentSnapshot userDoc = await _firestore.collection("carowners").doc(userCredential.user!.uid).get();

        if (!userDoc.exists) {
          // If the user doesn't exist in the database, create a new entry
          await _firestore.collection("carowners").doc(userCredential.user!.uid).set({
            'name': userCredential.user!.displayName,
            'uid': userCredential.user!.uid,
            'email': userCredential.user!.email,
          });
        }

        res = "SUCCESS";
      } else {
        res = "Google sign-in aborted";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }
}
