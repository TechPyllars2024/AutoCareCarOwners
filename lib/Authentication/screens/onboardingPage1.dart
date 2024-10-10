import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


class Onboardingpage1 extends StatefulWidget {
  const Onboardingpage1({super.key});

  @override
  State<Onboardingpage1> createState() => _Onboardingpage1State();
}

class _Onboardingpage1State extends State<Onboardingpage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(1.0), // Set the height of the AppBar
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.orange.shade900,
        ),
      ),
      backgroundColor: Colors.orange.shade900,
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/Authentication/assets/images/ob2.png',
                width: 350,
                height: 350,
                fit: BoxFit.cover,
              ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(delay: 1000.ms, duration: 1400.ms),
              const SizedBox(height: 30),
              const Positioned(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: Text(
                    'Experience hassle-free connections to the car services you need!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]
        ), // Fixed closing parenthesis
      ),
    );
  }
}
