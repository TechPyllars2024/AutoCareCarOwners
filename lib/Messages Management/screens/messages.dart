import 'package:flutter/material.dart';

class CarOwnerMessagesScreen extends StatefulWidget {
  const CarOwnerMessagesScreen({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerMessagesScreen> createState() => _CarOwnerMessagesScreenState();
}

class _CarOwnerMessagesScreenState extends State<CarOwnerMessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Car Owner Messages',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),

      ),
    );
  }
}
//
