import 'package:flutter/material.dart';

import 'package:autocare_carowners/Authentication/screens/homeScreen.dart';
import 'package:autocare_carowners/Authentication/screens/signup.dart';
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
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
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
    // double height = MediaQuery.of(context).size.height;
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(
                //   height: height / 2.7,
                //   child: Image.asset('lib/utils/login.jpg'),
                // ),
                TextFieldInput(
                    icon: Icons.email,
                    textEditingController: emailController,
                    hintText: 'Enter your email',
                    textInputType: TextInputType.text),
                TextFieldInput(
                  icon: Icons.lock,
                  textEditingController: passwordController,
                  hintText: 'Enter your password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),

                MyButtons(onTap: loginUser, text: "Log In"),

                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: Colors.black26),
                    ),
                    const Text("  or  "),
                    Expanded(
                      child: Container(height: 1, color: Colors.black26),
                    )
                  ],
                ),
                // Don't have an account? got to signup screen
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "SignUp",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
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
