import 'package:autocare_carowners/Authentication/widgets/carImage.dart';
import 'package:autocare_carowners/Authentication/widgets/googleButton.dart';
import 'package:autocare_carowners/Authentication/widgets/or.dart';
import 'package:autocare_carowners/Authentication/widgets/texfieldPassword.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:autocare_carowners/Authentication/screens/forgotPassword.dart';
import 'package:autocare_carowners/Authentication/screens/homeScreen.dart';
import 'package:autocare_carowners/Authentication/screens/signup.dart';
import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import 'package:autocare_carowners/Authentication/Widgets/snackBar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../Widgets/button.dart';
import '../Widgets/text_field.dart';

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
        // Navigate to the home screen if email is verified
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        // Inform the user to verify their email
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

  // Handles Google authentication
  Future<void> logInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthenticationMethod().signInWithGoogle();

    if (res == "SUCCESS") {
      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 40),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Auto",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "Care",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.orange, // Different color
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: const Duration(seconds: 3)),
              ),

              // Sign Up Image
              const CarImageWidget(
                      imagePath: 'lib/Authentication/assets/images/car.png')
                  .animate()
                  .fadeIn(duration: const Duration(seconds: 2)),
              // Sign Up Form
              Container(
                height: MediaQuery.of(context).size.height,
                padding: const EdgeInsets.only(top: 50),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),


                  color: Colors.white,
                ),


                child: Column(

                  children: <Widget>[
                    TextFieldInput(
                        icon: Icons.email,
                        textEditingController: emailController,
                        hintText: 'Enter your Email',
                        textInputType: TextInputType.text),
                    TextFieldPassword(
                      icon: Icons.lock,
                      textEditingController: passwordController,
                      hintText: 'Enter your Password',
                      textInputType: TextInputType.text,
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
                              fontSize: 15,
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
                    MyButtons(onTap: loginUser, text: "Log In"),

                    // Sign Up OR
                    SizedBox(height: size.height * 0.02),
                    const Or(),

                    // Sign Up with Google
                    SizedBox(height: size.height * 0.03),
                    GoogleButton(
                      onTap: logInWithGoogle,
                      hintText: 'Log In with Google',
                    ),

                    // Already have an account? Log In

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
                                  // Navigate to LoginScreen
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
              ).animate().slide(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  begin: const Offset(0, 1),
                  end: const Offset(0, 0))
            ],
          ),
        ),
      ),
    );
  }
}
