import 'package:autocare_carowners/Home%20Page%20Management/widgets/noAvailableServicesWidget.dart';
import 'package:flutter/material.dart';

class NoAvailableServices extends StatefulWidget {
  final String responseSuggestedServices;
  const NoAvailableServices(
      {super.key, required this.responseSuggestedServices});

  @override
  State<NoAvailableServices> createState() => _NoAvailableServicesState();
}

class _NoAvailableServicesState extends State<NoAvailableServices> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Nearby Service Providers',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: NoAvailableServicesWidget(
                responseSuggestedServices: widget.responseSuggestedServices),
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
