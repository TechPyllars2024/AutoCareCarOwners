import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Onboardingpage2 extends StatefulWidget {
  const Onboardingpage2({super.key});

  @override
  State<Onboardingpage2> createState() => _Onboardingpage2State();
}

class _Onboardingpage2State extends State<Onboardingpage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/Authentication/assets/images/ob1.png',
              width: 350,
              height: 350,
              fit: BoxFit.cover,
            ).animate(onPlay: (controller) => controller.repeat())
            .shimmer(delay: 1000.ms, duration: 1400.ms),
            const SizedBox(height: 60),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.0),
              child: Text(
                'Fuel your journey with a well-maintained car!',
                style: TextStyle(
                  fontSize: 24, // Adjust font size if necessary
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
