import 'package:flutter/material.dart';

class Onboardingpage2 extends StatefulWidget {
  const Onboardingpage2({super.key});

  @override
  State<Onboardingpage2> createState() => _Onboardingpage2State();
}

class _Onboardingpage2State extends State<Onboardingpage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset(
              'lib/Authentication/assets/images/onboard2.png',
              width: 400,
              height: 400,
              fit: BoxFit.cover,
            ),
           const SizedBox(height: 20),
            const Padding(
              padding:  EdgeInsets.symmetric(horizontal: 50.0),
              child: Text(
                'Fuel your journey with a well-maintained vehicle!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Customize your text style
                textAlign: TextAlign.center, // Center align the text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
