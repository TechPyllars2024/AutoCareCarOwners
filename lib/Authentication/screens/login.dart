import 'package:autocare_carowners/Authentication/widgets/carImage.dart';
import 'package:autocare_carowners/Authentication/widgets/googleButton.dart';
import 'package:autocare_carowners/Authentication/widgets/or.dart';
import 'package:autocare_carowners/Authentication/widgets/texfieldPassword.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:autocare_carowners/Authentication/screens/homeScreen.dart';
import 'package:autocare_carowners/Authentication/screens/signup.dart';
import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import 'package:autocare_carowners/Authentication/Widgets/snackBar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../Widgets/button.dart';
import '../Widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController myController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    myController.dispose();
  }

  // Email and password auth part
  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    // Login user using our auth method
    String res = await AuthenticationMethod().loginUser(
        email: emailController.text, password: passwordController.text);

    setState(() {
      isLoading = false;
    });

    if (res == "SUCCESS") {
      // Navigate to the home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      // Show error
      showSnackBar(context, res);
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
                  "Log In",
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
              const CarImageWidget(imagePath: 'lib/Authentication/assets/images/logincar.png'),
              
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
                    MyButtons(onTap: loginUser, text: "Log In"),
                    
                    // Sign Up OR
                    SizedBox(height: size.height * 0.02),
                    const Or(),

                    // Sign Up with Google
                    SizedBox(height: size.height * 0.03),
                    GoogleButton(
                      textEditingController: myController,
                      isPass: false,
                      hintText: 'Log In with Gmail',
                    ),
                    
                    // Already have an account? Log In
                    const SizedBox(height: 130),
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
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to LoginScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignupScreen()),
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
                      end: const Offset(0, 0))
            ],
          ),
        ),
      ),
    );
  }
}
