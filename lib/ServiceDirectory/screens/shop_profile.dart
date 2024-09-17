import 'package:flutter/material.dart';

class ShopProfile extends StatefulWidget {
  final String serviceName; // Accept the serviceName
  final String shopName; // Accept the shopName

  //child: Text('Welcome to ${widget.shopName}'),

  const ShopProfile(
      {super.key, required this.serviceName, required this.shopName});

  @override
  State<ShopProfile> createState() => _ShopProfileState();
}

class _ShopProfileState extends State<ShopProfile> {
  final double coverHeight = 220;
  final double profileHeight = 130;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Keep the AppBar title as the serviceName
          title: Text(widget.serviceName),
        ),
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
              child: ListView(
                padding: EdgeInsets.only(bottom: 8),
                children: [

                ],
              ),
        )));
  }
}
