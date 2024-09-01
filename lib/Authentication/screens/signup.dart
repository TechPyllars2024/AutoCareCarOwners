import 'package:autocare_carowners/Authentication/screens/verifyEmail.dart';
import 'package:autocare_carowners/Authentication/widgets/googleButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:autocare_carowners/Authentication/widgets/carImage.dart';
import 'package:autocare_carowners/Authentication/widgets/or.dart';
import 'package:autocare_carowners/Authentication/widgets/texfieldPassword.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../Widgets/button.dart';
import '../Widgets/snackBar.dart';
import '../Widgets/text_field.dart';
import 'homeScreen.dart';
import 'login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    this.child
  });

  final Widget? child;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
  }

  void signupUser() async {
    setState(() {
      isLoading = true;
    });

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar("Passwords do not match.");
      return;
    }

    String res = await AuthenticationMethod().signupUser(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
    );

    if (res == "success") {
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

  Future<void> signInWithGoogle() async {
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
      body: SafeArea(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color:Colors.white,
                  ),
                ).animate()
                 .fadeIn(duration: const Duration(seconds: 1)),
              ),

              // Sign Up Image
              const SizedBox(height: 10),
              const CarImageWidget(imagePath: 'lib/Authentication/assets/images/welcomecar.png'),
              
              // Sign Up Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: <Widget>[               
                    TextFieldInput(
                        icon: Icons.person,
                        textEditingController: nameController,
                        hintText: 'Enter your Name',
                        textInputType: TextInputType.text),
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
                    TextFieldPassword(
                      icon: Icons.lock,
                      textEditingController: confirmPasswordController,
                      hintText: 'Confirm your Password',
                      textInputType: TextInputType.text,
                      isPass: true,
                    ),
                    
                    // Sign Up Button
                    MyButtons(onTap: signupUser, text: "Sign Up"),
                    
                    // Sign Up OR
                    SizedBox(height: size.height * 0.02),
                    const Or(),

                    // Sign Up with Google
                    SizedBox(height: size.height * 0.03),
                    GoogleButton(
                      onTap: signInWithGoogle,
                      hintText: 'Sign Up with Google',
                    ),
                    
                    // Already have an account? Log In
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        // Handle navigation to login screen
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: const TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Log In',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to LoginScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate()
               .slide(duration: const Duration(milliseconds: 500), 
                      curve: Curves.easeInOut,
                      begin: const Offset(0, 1), 
                      end: const Offset(0, 0)),
            ],
          ),
        ),
      ),
    );
  }
}
