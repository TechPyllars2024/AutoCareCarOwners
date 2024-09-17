import 'package:flutter/material.dart';

class ShopsDirectory extends StatefulWidget {
  final String serviceName; // Accept serviceName as a parameter

  const ShopsDirectory({super.key, required this.serviceName});

  @override
  State<ShopsDirectory> createState() => _ShopsDirectoryState();
}

class _ShopsDirectoryState extends State<ShopsDirectory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName,
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey[800]),), // Use serviceName for the AppBar title
      ),
      body: Center(
        child: Text('Displaying shops for ${widget.serviceName}'),
      ),
    );
  }
}
