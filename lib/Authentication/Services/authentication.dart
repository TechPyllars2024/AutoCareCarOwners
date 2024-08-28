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
    String res = "Unfortunately, some errors occured";
    try {
      if (email.isNotEmpty || password.isNotEmpty || name.isNotEmpty) {
        //register the user with email and password
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        //add the user to firestore database
        print(credential.user!.uid);
        await _firestore
            .collection("carowners")
            .doc(credential.user!.uid)
            .set({'name': name, 'uid': credential.user!.uid, 'email': email});
        res = 'Success!';
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
}
