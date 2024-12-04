import 'package:autocare_carowners/Home%20Page%20Management/widgets/automotiveShopsWidget.dart';
import 'package:flutter/material.dart';
import '../widgets/gasolineShopWidget.dart';

class NearbyServices extends StatefulWidget {
  const NearbyServices({super.key});

  @override
  State<NearbyServices> createState() => _NearbyServicesState();
}

class _NearbyServicesState extends State<NearbyServices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Nearby Automotive Services',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [

          const Expanded(
            child: AutomotiveShopsWidget(),
          ),
          // Fixed height for ConvertCoordinates
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            // child: ConvertCoordinates(),
          ),
        ],
      ),
    );
  }
}
