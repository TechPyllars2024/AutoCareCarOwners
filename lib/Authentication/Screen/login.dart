import 'package:autocare_carowners/Authentication/Widgets/googleButton.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:autocare_carowners/Authentication/Screen/homeScreen.dart';
import 'package:autocare_carowners/Authentication/Screen/signup.dart';
import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import 'package:autocare_carowners/Authentication/Widgets/snackBar.dart';
import '../Widgets/button.dart';
import '../Widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<LoginScreen> {
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

// email and passowrd auth part
  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    // signup user using our authmethod
    String res = await AuthenticationMethod().loginUser(
        email: emailController.text, password: passwordController.text);

    if (res == "SUCCESS") {
      setState(() {
        isLoading = false;
      });
      //navigate to the home screen
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: SafeArea(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
              const Text(
                "Log In",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white
                ),
              ),
              SizedBox(height: size.height * 0.02),
              // image to be updated
              // Image.asset(
              //   'assets/images/logincar.png', 
              //   height: size.height * 0.2,
              // ),
              SizedBox(height: size.height * 0.03),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    TextFieldInput(
                        icon: Icons.email,
                        textEditingController: emailController,
                        hintText: 'Email',
                        textInputType: TextInputType.text),
                    TextFieldInput(
                      icon: Icons.lock,
                      textEditingController: passwordController,
                      hintText: 'Password',
                      textInputType: TextInputType.text,
                      isPass: true,
                    ),

                    // Forgot password
                    SizedBox(height: size.height * 0.001),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            // Forgot password logic
                          },
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),

                    MyButtons(onTap: loginUser, text: "Log In"),

                    SizedBox(height: size.height * 0.03),
                    const Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            color: Colors.black, // Color of the divider
                            thickness: 1, // Thickness of the divider
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OR',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    // Google Button
                    SizedBox(height: size.height * 0.03),
                    GoogleButton(
                      textEditingController: myController,
                      isPass: false,
                      hintText: 'Log In with Gmail',
                    ),

                    // Don't have an account? got to signup screen
                    const SizedBox(height: 50),
                    RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Sign Up',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Navigate to SignupScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),
          )),
    );
  }

  Container socialIcon(image) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFedf0f8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black45,
          width: 2,
        ),
      ),
      child: Image.network(
        image,
        height: 40,
      ),
    );
  }
}
