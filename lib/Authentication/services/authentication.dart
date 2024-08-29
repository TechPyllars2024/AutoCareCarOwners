import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //SIGN UP
  Future<String> signupUser({
    required String email,
    required String password,
    required String name
  }) async {
    String res = "Unfortunately, some errors occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        //register the user with email and password
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password
        );
        //add the user to firestore database
        await _firestore
            .collection("users")
            .doc(credential.user!.uid)
            .set({'name': name,
              'uid': credential.user!.uid,
              'email': email
            });
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

  //LOG IN
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Unfortunately, some errors occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        //logging in user with email and password
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = "SUCCESS";
      } else {
        res = "Please fill in all fields.";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        res = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        res = 'The email address is badly formatted.';
      } else {
        res = e.message ?? "An unknown error occurred.";
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
}
