import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import the 'lottie' package

import 'package:autocare_carowners/Authentication/Widgets/button.dart';
import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import 'login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Congratulations\nYou have successfully Login",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            
            Lottie.asset(
              'lib/Authentication/assets/images/Animation - 1724694642875.json',
              height: size.height * 0.25,
            ),
            MyButtons(
              onTap: () async {
                await AuthenticationMethod().signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              text: "Log Out",
            ),
          ],
        ),
      ),
    );
  }
}
