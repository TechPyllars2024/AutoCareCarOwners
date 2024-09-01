import 'package:flutter/material.dart';

class CarOwnerMessage extends StatefulWidget {
  const CarOwnerMessage({super.key});

  @override
  State<CarOwnerMessage> createState() => _CarOwnerMessageState();
}

class _CarOwnerMessageState extends State<CarOwnerMessage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MESSAGES', style: TextStyle(fontWeight: FontWeight.bold),), backgroundColor: Colors.grey.shade300, ),
      body: Container(
        color: Colors.grey.shade300,
      ),
    );
  }
}
