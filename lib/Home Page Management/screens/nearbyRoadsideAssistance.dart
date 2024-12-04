import 'package:autocare_carowners/Home%20Page%20Management/widgets/roadSideAssistanceWidget.dart';
import 'package:flutter/material.dart';

class NearbyRoadsideServices extends StatefulWidget {
  const NearbyRoadsideServices({super.key});

  @override
  State<NearbyRoadsideServices> createState() => _NearbyRoadsideServicesState();
}

class _NearbyRoadsideServicesState extends State<NearbyRoadsideServices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Nearby Roadside Assistance',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [

          const Expanded(
            child: RoadSideAssistanceWidget(),
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
