import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatefulWidget {
  const GoogleMapWidget({super.key});

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) {
      print(error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  final Completer<GoogleMapController> _controller = Completer();

  final List<Marker> _marker = [];
  final List<Marker> _markerList = [
    const Marker(
      markerId: MarkerId("1"),
      position: LatLng(14.5995, 120.9842),
      infoWindow: InfoWindow(title: "Manila"),
    ),
    const Marker(
      markerId: MarkerId("2"),
      position: LatLng(10.3157, 123.8854),
      infoWindow: InfoWindow(title: "Jaro, Iloilo City"),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _marker.addAll(_markerList);
  }

  final CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(7.0736, 125.6110),
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6, // Adjusted height to take more space
        child: Column(
          children: [
            // Wrap the GoogleMap widget with Expanded
            Expanded(
              child: GoogleMap(
                initialCameraPosition: _cameraPosition,
                markers: Set.of(_marker),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                getUserCurrentLocation().then((value) async {
                  print("my current location: $value");
                  setState(() {
                    _marker.add(
                      Marker(
                        markerId: const MarkerId("3"),
                        position: LatLng(value.latitude, value.longitude),
                        infoWindow: const InfoWindow(title: "My Location"),
                      ),
                    );
                  });

                  CameraPosition cameraPosition = CameraPosition(
                    target: LatLng(value.latitude, value.longitude),
                    zoom: 14.0,
                  );
                  final GoogleMapController controller = await _controller.future;
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(cameraPosition),
                  );
                });
              },
              child: const Text('Get Current Location'),
            ),
          ],
        ),
      ),
    );
  }
}
