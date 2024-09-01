import 'package:autocare_carowners/Authentication/Widgets/snackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:autocare_carowners/Authentication/Widgets/button.dart';
import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import 'package:lottie/lottie.dart';
import 'login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Congratulations\nYou have successfully logged in",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // Lottie.asset(
            //   'lib/Authentication/assets/images/Animation - 1724694642875.json',
            //   height: size.height * 0.25,
            // ),

            const SizedBox(height: 16),
            const Text(
              "Signed In as",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),

            const SizedBox(height: 8),
            Text(
              user != null ? user.email! : "No email available",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),

            const SizedBox(height: 24),
            MyButtons(
              onTap: () async {
                try {
                  await AuthenticationMethod().signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                } catch (e) {
                 Utils.showSnackBar('Error Signing Out: $e');
                }
              },
              text: "Log Out",
            ),
          ],
        ),
      ),
    );
  }
}
