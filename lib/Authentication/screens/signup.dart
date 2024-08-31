import 'package:autocare_carowners/Authentication/Widgets/googleButton.dart';
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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController myController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    myController.dispose();
  }

  void signupUser() async {
    // set is loading to true.
    setState(() {
      isLoading = true;
    });
    // signup user using our authmethod
    String res = await AuthenticationMethod().signupUser(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text);
    // if string return is success, user has been created and navigate to next screen otherwise show error.
    if (res == "success") {
      setState(() {
        isLoading = false;
      });
      //navigate to the next screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      // show error
      showSnackBar(context, res);
    }
  }

  // This method handles google sign in
  Future<void> signUpWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          // Navigate to home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        }
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
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
              SizedBox(height: size.height * 0.02),
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

                    // Sign Up Button
                    MyButtons(onTap: signupUser, text: "Sign Up"),
                    
                    // Sign Up OR
                    SizedBox(height: size.height * 0.02),
                    const Or(),

                    // Sign Up with Google
                    SizedBox(height: size.height * 0.03),
                    GoogleButton(
                      textEditingController: myController,
                      isPass: false,
                      hintText: 'Sign Up with Gmail',
                    ),
                    
                    // Already have an account? Log In
                    const SizedBox(height: 50),
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
