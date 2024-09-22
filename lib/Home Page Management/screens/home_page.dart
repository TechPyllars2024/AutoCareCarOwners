import 'package:flutter/material.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key, this.child});

  final Widget? child;

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title:  Row(
          children: [
             Text(
              'Auto',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: Colors.black),
            ),
            Text(
              'Care',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 40, color: Colors.orange.shade900),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade100,
      ),
    );
  }
}
//
