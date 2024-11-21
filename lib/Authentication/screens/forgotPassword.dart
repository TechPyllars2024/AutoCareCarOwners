import 'dart:ui';

import 'package:autocare_carowners/Authentication/screens/login.dart';
import 'package:autocare_carowners/Authentication/services/authentication_resetpassword.dart';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../Widgets/button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  //reset password function
  Future<void> resetPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      String res = await AuthenticationMethodResetPassword().resetPassword(
        email: emailController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (res == "SUCCESS") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent")),
        );
        Navigator.of(context).pop(); // Navigate back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text("Reset Password", style: TextStyle(fontWeight: FontWeight.w900)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/Authentication/assets/images/forgotpassword.png',
                width: 200,
                height: 200,
              ).animate().fadeIn(duration: const Duration(seconds: 1)),

              const SizedBox(height: 30),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter Your Email Below',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.black,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButtons(
                onTap: resetPassword,
                text: "Reset Password",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
