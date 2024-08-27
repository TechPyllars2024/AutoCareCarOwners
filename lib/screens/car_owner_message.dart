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
      appBar: AppBar(title: Text('MESSAGES'),),
      body: Container(
        color: Colors.grey.shade300,
      ),
    );
  }
}
