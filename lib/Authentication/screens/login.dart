import 'package:autocare_carowners/Authentication/widgets/carImage.dart';
import 'package:autocare_carowners/Authentication/widgets/googleButton.dart';
import 'package:autocare_carowners/Authentication/widgets/texfieldPassword.dart';
import 'package:flutter/gestures.dart';
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
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
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
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                const CarImageWidget(imagePath: 'lib/Authentication/assets/images/logincar.png'),
                
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
                    hintText: 'Email',
                    textInputType: TextInputType.text),
                TextFieldPassword(
                  icon: Icons.lock,
                  textEditingController: passwordController,
                  hintText: 'Password',
                  textInputType: TextInputType.text,
                  isPass: true,
                ),
                MyButtons(onTap: loginUser, text: "Log In"),
                
                SizedBox(height: size.height * 0.02),
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
                      color: Colors.black, // Color of the divider
                      thickness: 1, // Thickness of the divider
                      ),
                    ),
                  ],
                ),

                SizedBox(height: size.height * 0.03),
                  GoogleButton(
                  textEditingController: myController,
                  isPass: false,
                  hintText: 'Log In with Gmail',
                ),
                // Don't have an account? Go to signup screen
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
          ),
        ],     
      ),
    ),
  ),
);}

//   Container socialIcon(image) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 32,
//         vertical: 15,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFedf0f8),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Colors.black45,
//           width: 2,
//         ),
//       ),
//       child: Image.network(
//         image,
//         height: 40,
//       ),
//     );
//   }
}
