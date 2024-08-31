import 'package:flutter/material.dart';

import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import '../Widgets/button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.child
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

  Future<void> resetPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      String res = await AuthenticationMethod().resetPassword(email: emailController.text);

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
  Widget build(BuildContext context) => Scaffold(
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: const Text("Reset Password"),
  ),
    body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Receive an email to \nreset your password',
              textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25),
              ), const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.black,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(),),
                keyboardType: TextInputType.emailAddress
              ),const SizedBox(height: 20),
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