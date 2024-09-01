import 'package:flutter/material.dart';

class CarOwnerDirectory extends StatefulWidget {
  const CarOwnerDirectory({super.key});

  @override
  State<CarOwnerDirectory> createState() => _CarOwnerDirectoryState();
}

class _CarOwnerDirectoryState extends State<CarOwnerDirectory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('DIRECTORY', style: TextStyle(fontWeight: FontWeight.bold),), backgroundColor: Colors.grey.shade300, ),
      body: Container(
        color: Colors.grey.shade300,

      ),
    );
  }
}
