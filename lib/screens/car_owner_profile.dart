import 'package:flutter/material.dart';
import 'package:autocare_carowners/widgets/navbar.dart';

class CarOwnerProfile extends StatefulWidget {
  const CarOwnerProfile({super.key});

  @override
  State<CarOwnerProfile> createState() => _CarOwnerProfileState();
}

class _CarOwnerProfileState extends State<CarOwnerProfile> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PROFILE')),
      body: Container(
        color: Colors.grey.shade300,

      )
    );
  }
}
