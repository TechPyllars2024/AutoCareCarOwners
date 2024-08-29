import 'package:flutter/material.dart';

import 'package:autocare_carowners/Authentication/Widgets/button.dart';
import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import 'login.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
