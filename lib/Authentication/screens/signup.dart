import 'package:autocare_carowners/Authentication/screens/onboarding.dart';
import 'package:autocare_carowners/Authentication/services/authentication_signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../widgets/button.dart';
import '../widgets/snackBar.dart';
import '../Widgets/text_field.dart';
import '../widgets/textfieldPassword.dart';
import '../widgets/validator.dart';
import 'login.dart';
import 'package:autocare_carowners/Authentication/widgets/carImage.dart';
import 'package:autocare_carowners/Authentication/widgets/or.dart';
import 'package:autocare_carowners/Authentication/screens/verifyEmail.dart';
import 'package:autocare_carowners/Authentication/widgets/googleButton.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.child});

  final Widget? child;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool isLoadingGoogle = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  //sign up user
  void signupUser() async {
    final passwordError = passwordValidator(passwordController.text);
    String? confirmPasswordError;

    setState(() {
      isLoading = true;
    });

    if (passwordError != null || confirmPasswordError != null) {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar("Please enter a valid password");
      return;
    }
    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar("Passwords do not match.");
      return;
    }

    String res = await AuthenticationMethodSignIn().signupCarOwner(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res == "SUCCESS") {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.sendEmailVerification();
          setState(() {
            isLoading = false;
          });

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const VerifyEmailScreen(),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          Utils.showSnackBar("Failed to retrieve user.");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Utils.showSnackBar(e.toString());
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar(res);
    }
  }

  //sign in with google
  Future<void> signInWithGoogle() async {
    setState(() {
      isLoadingGoogle = true;
    });

    String res =
        await AuthenticationMethodSignIn().signInWithGoogleForCarOwner();

    if (res == "SUCCESS") {
      setState(() {
        isLoadingGoogle = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Onboarding(),
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
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Sign Up Image
          const CarImageWidget(
            imagePath: 'lib/Authentication/assets/images/repair.jpg',
          ).animate().fadeIn(duration: const Duration(seconds: 2)),

          // Sign Up Form
          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "Auto",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 30,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "Care",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 30,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: const Duration(seconds: 3)),
                      ),
                      TextFieldInput(
                        icon: Icons.email,
                        textEditingController: emailController,
                        hintText: 'Email',
                        textInputType: TextInputType.text,
                        validator: (value) {
                          // Regular expression for validating an email
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

                          // Check if the field is empty
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }

                          // Check if the value matches the email format
                          else if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }

                          // Return null if validation passes
                          return null;
                        },
                      ),
                      TextFieldPassword(
                        icon: Icons.lock,
                        textEditingController: passwordController,
                        hintText: 'Password',
                        textInputType: TextInputType.text,
                        validator: passwordValidator,
                        isPass: true,
                      ),
                      TextFieldPassword(
                        icon: Icons.lock,
                        textEditingController: confirmPasswordController,
                        hintText: 'Confirm Password',
                        textInputType: TextInputType.text,
                        validator: (value) {
                          // First, check if the confirm password field is empty
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }

                          // Check if the password passes the main password validator
                          final passwordError =
                              passwordValidator(passwordController.text);
                          if (passwordError != null) {
                            return 'The password does not meet the required criteria';
                          }

                          // Ensure the confirm password matches the original password
                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }

                          // All conditions passed, return null
                          return null;
                        },
                        isPass: true,
                      ),

                      // Sign Up Button
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: MyButtons(
                          onTap: signupUser,
                          text: "Sign Up",
                          isLoading: isLoading, // Pass the loading state
                        ),
                      ),

                      // Sign Up OR
                      SizedBox(height: size.height * 0.2),
                      // const Or(),
                      //
                      // // Sign Up with Google
                      // SizedBox(height: size.height * 0.03),
                      // GoogleButton(
                      //   onTap: signInWithGoogle,
                      //   hintText: 'Sign Up with Google',
                      //   isGoogleLoading: isLoadingGoogle,
                      // ),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: const TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25)
                    ],
                  ),
                ),
              ),
            ).animate().slide(
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  begin: const Offset(0, 1),
                  end: const Offset(0, 0),
                ),
          ),
        ],
      ),
    );
  }
}
