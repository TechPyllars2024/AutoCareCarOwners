import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../widgets/convertCoordinates.dart';
import '../widgets/googleMap.dart';

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
        title: Text('Gasoline Station', style: TextStyle(fontWeight: FontWeight.w900,color: Colors.black),),
      ),
      body: Column(

        children: [
          GoogleMapWidget(),
          ConvertCoordinates(),
        ],

      ),
    );
  }
}
