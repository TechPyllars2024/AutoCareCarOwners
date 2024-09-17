import 'package:flutter/material.dart';

class ShopProfile extends StatefulWidget {


  @override
  State<ShopProfile> createState() => _ShopProfileState();
}

class _ShopProfileState extends State<ShopProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shop Name'),),
    );
  }
}
