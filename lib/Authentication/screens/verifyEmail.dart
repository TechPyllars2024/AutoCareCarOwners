import 'package:autocare_carowners/Navigation%20Bar/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../Widgets/snackBar.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.child});

  final Widget? child;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      isEmailVerified = user.emailVerified;

      if (!isEmailVerified) {
        // Start periodic check for email verification but don't resend automatically
        timer = Timer.periodic(
          const Duration(seconds: 3),
          (_) => checkEmailVerified(),
        );
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Reload user to check the latest email verification status
      setState(() {
        isEmailVerified = user.emailVerified;
      });

      if (isEmailVerified) timer?.cancel();
    }
  }

  Future<void> sendVerificationEmail() async {
    setState(() {
      isLoading = true; // Show loader
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Check if user exists and if it's allowed to resend email
      if (user != null && canResendEmail) {
        // Avoid sending email if it's already verified
        await user.reload();
        if (user.emailVerified) {
          setState(() {
            isEmailVerified = true;
          });
          Utils.showSnackBar("Your email is already verified.");
          return;
        }

        // Send verification email
        await user.sendEmailVerification();

        setState(() {
          canResendEmail = false;
        });

        Utils.showSnackBar("Verification email sent. Please check your inbox.");

        // Cooldown period before allowing another resend
        await Future.delayed(const Duration(seconds: 30));

        setState(() {
          canResendEmail = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        // Handle rate limit error by disabling the resend button longer
        Utils.showSnackBar("Too many requests. Please try again later.");
        setState(() {
          canResendEmail = false;
        });

        // Wait 60 seconds before allowing resend again
        await Future.delayed(const Duration(seconds: 60));

        setState(() {
          canResendEmail = true;
        });
      } else {
        Utils.showSnackBar(e.message ?? "An error occurred.");
      }
    } catch (e) {
      Utils.showSnackBar("An unexpected error occurred.");
    }

    setState(() {
      isLoading = false; // Hide loader
    });
  }


  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const NavBar()
        : Scaffold(
            appBar: AppBar(
              title: const Text('Verify Email'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/Authentication/assets/images/verifyemail.png',
                    width: 300,
                    height: 300,
                  ),
                  const SizedBox(height: 80),
                  const Text(
                    'A Verification Email has been sent!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.8),
                          ),
                          icon: const Icon(Icons.email,
                              size: 32, color: Colors.green),
                          label: const Text('Resend Email',
                              style:
                                  TextStyle(fontSize: 24, color: Colors.green)),
                          onPressed:
                              canResendEmail ? sendVerificationEmail : null,
                        ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
  }
}
