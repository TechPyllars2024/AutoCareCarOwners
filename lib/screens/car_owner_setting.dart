import 'package:flutter/material.dart';

class CarOwnerSetting extends StatefulWidget {
  const CarOwnerSetting({super.key});

  @override
  State<CarOwnerSetting> createState() => _CarOwnerSettingState();
}

class _CarOwnerSettingState extends State<CarOwnerSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(title: Text('SETTINGS'), backgroundColor: Colors.grey.shade300,),
    );
  }
}
