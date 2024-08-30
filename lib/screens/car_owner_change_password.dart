import 'package:flutter/material.dart';

class CarOwnerChangePassword extends StatefulWidget {
  const CarOwnerChangePassword({super.key});

  @override
  State<CarOwnerChangePassword> createState() => _CarOwnerChangePasswordState();
}

class _CarOwnerChangePasswordState extends State<CarOwnerChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold),), backgroundColor: Colors.grey.shade300,),
      backgroundColor: Colors.grey.shade300,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Old Password'
                ),

              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'New Password'
                  ),

                ),
              ),
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Confirm Password'
                ),

              ),

            ],
          ),
        ),
      ),
    );
  }
}