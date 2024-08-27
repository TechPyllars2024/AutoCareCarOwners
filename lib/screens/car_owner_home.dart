import 'package:flutter/material.dart';

class CarOwnerHome extends StatefulWidget {
  const CarOwnerHome({super.key});

  @override
  State<CarOwnerHome> createState() => _CarOwnerHomeState();
}

class _CarOwnerHomeState extends State<CarOwnerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HOME'),),
      body: Container(
        color: Colors.grey.shade300,

      ),
    );
  }
}
