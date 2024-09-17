import 'package:autocare_carowners/ProfileManagement/screens/car_owner_change_password.dart';

import 'package:flutter/material.dart';

class CarOwnerSetting extends StatefulWidget {
  const CarOwnerSetting({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerSetting> createState() => _CarOwnerSettingState();
}

class _CarOwnerSettingState extends State<CarOwnerSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: const Size(400, 50),
                  backgroundColor: Colors.grey,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const CarOwnerChangePassword()));
                },
                child: const Text('Change Password',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
