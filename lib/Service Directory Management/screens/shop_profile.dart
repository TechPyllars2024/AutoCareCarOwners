import 'package:flutter/material.dart';

class ShopProfile extends StatefulWidget {
  final String serviceName; // Accept the serviceName
  final String shopName; // Accept the shopName
  final Widget? child;

  const ShopProfile({super.key, required this.serviceName, required this.shopName, this.child});

  @override
  State<ShopProfile> createState() => _ShopProfileState();
}

class _ShopProfileState extends State<ShopProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Keep the AppBar title as the serviceName
        title: Text(widget.serviceName),
      ),
      body: Center(
        // Display the shop details (here just the name for simplicity)
        child: Text('Welcome to ${widget.shopName}'),
      ),
    );
  }
}
