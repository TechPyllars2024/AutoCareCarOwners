import 'package:flutter/material.dart';
import '../widgets/gasolineShopWidget.dart';

class GasolineStation extends StatefulWidget {
  const GasolineStation({super.key});

  @override
  State<GasolineStation> createState() => _GasolineStationState();
}

class _GasolineStationState extends State<GasolineStation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Gasoline Station',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          const Expanded(
            child: GasolineShopsWidget(),
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
