import 'package:autocare_carowners/Navigation%20Bar/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../widgets/button.dart';
import '../widgets/text_field.dart';
import 'package:autocare_carowners/Authentication/widgets/carImage.dart';
import 'package:autocare_carowners/Authentication/widgets/googleButton.dart';
import 'package:autocare_carowners/Authentication/widgets/or.dart';
import 'package:autocare_carowners/Authentication/widgets/textfieldPassword.dart';
import 'package:autocare_carowners/Authentication/screens/forgotPassword.dart';
import 'package:autocare_carowners/Authentication/screens/signup.dart';
import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import 'package:autocare_carowners/Authentication/Widgets/snackBar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.child});

  final Widget? child;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  // Handles email and password authentication
  void loginUser() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthenticationMethod().loginUser(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res == "SUCCESS") {
      // Check if email is verified
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const NavBar(),
          ),
        );
      } else {
        setState(() {
          isLoading = false;
        });
        Utils.showSnackBar("Please verify your email address.");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar(res);
    }
  }

  /// Handles Google Log-In in the UI for Car Owners
  Future<void> logInWithGoogleForCarOwners() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthenticationMethod().logInWithGoogleForCarOwners();

    setState(() {
      isLoading = false;
    });

    if (res == "Car Owner") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const NavBar(),
        ),
      );
    } else {
      Utils.showSnackBar(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const CarImageWidget(
              imagePath: 'lib/Authentication/assets/images/carBlack.png')
              .animate()
              .fadeIn(duration: const Duration(seconds: 2)),

          // Expanded container that stretches to the bottom of the screen
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Auto",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 50,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "Care",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 50,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: const Duration(seconds: 3)),
                    ),
                    TextFieldInput(
                      icon: Icons.email,
                      textEditingController: emailController,
                      hintText: 'Email',
                      textInputType: TextInputType.text,
                      validator: (value) {
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        } else if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    TextFieldPassword(
                      icon: Icons.lock,
                      textEditingController: passwordController,
                      hintText: 'Password',
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        return null;
                      },
                      isPass: true,
                    ),

                    // Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                              const ForgotPasswordScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Sign Up Button
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: MyButtons(
                        onTap: loginUser,
                        text: "Log In",
                        isLoading: isLoading, // Pass the loading state
                      ),
                    ),

                    // Sign Up OR
                    SizedBox(height: size.height * 0.02),
                    const Or(),

                    // Sign Up with Google
                    SizedBox(height: size.height * 0.03),
                    GoogleButton(
                      onTap: logInWithGoogleForCarOwners, // Google button is always enabled
                      hintText: 'Log In with Google',
                    ),

                    // Already have an account? Log In
                    const SizedBox(height: 50),
                    TextButton(
                      onPressed: () {
                        // Handle navigation to login screen
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Sign Up',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to SignupScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const SignupScreen()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slide(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                begin: const Offset(0, 1),
                end: const Offset(0, 0)),
          ),
        ],
      ),
    );
  }
}
