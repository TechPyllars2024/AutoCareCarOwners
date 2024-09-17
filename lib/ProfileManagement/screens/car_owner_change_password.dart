import 'package:autocare_carowners/ProfileManagement/screens/car_owner_setting.dart';

import 'package:flutter/material.dart';

class CarOwnerChangePassword extends StatefulWidget {
  const CarOwnerChangePassword({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerChangePassword> createState() => _CarOwnerChangePasswordState();
}

class _CarOwnerChangePasswordState extends State<CarOwnerChangePassword> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Old Password'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'New Password'),
                ),
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: 'Confirm Password'),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CarOwnerSetting()));
                  },
                  child: const Text('Save'))
            ],
          ),
        ),
      ),
    );
  }
}
