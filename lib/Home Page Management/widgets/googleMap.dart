import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {

  final Completer<GoogleMapController> _controller = Completer();

  final List<Marker> _marker = [];
  final List<Marker> _markerList = [
    const Marker(markerId: MarkerId("1"),
      position: LatLng(10.7202, 122.5621),
      infoWindow: InfoWindow(title: "IloIlo City"),
    ),
    const Marker(markerId: MarkerId("2"),
      position: LatLng(10.7504, 122.5701),
      infoWindow: InfoWindow(title: "Jaro, Iloilo City"),
    )
  ];

  @override
  void initState() {
    _marker.addAll(_markerList);
    super.initState();
  }

  final CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(10.7202, 122.5621),
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: double.infinity,
      child: GoogleMap(initialCameraPosition: _cameraPosition,
      markers: Set.of(_marker),),
    );
  }
}