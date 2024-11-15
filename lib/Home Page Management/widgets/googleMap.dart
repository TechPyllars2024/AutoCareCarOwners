import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

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
      print("Error requesting location permission: $error");
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

  Future<void> getNearbyGasStations(double latitude, double longitude) async {
    final apiKey = 'AIzaSyCrbgW2yWOxrm932ZOoVV1_vw1ImfRLMDM';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=5000&type=gas_station&key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Nearby gas stations response: $data");

      final results = data['results'];
      if (results != null && results.isNotEmpty) {
        for (var result in results) {
          final location = result['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];
          final name = result['name'];
          final address = result['vicinity'] ?? 'Address not available';
          final rating = result['rating'] != null
              ? result['rating'].toString()
              : 'No ratings';

          setState(() {
            _marker.add(Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: name,
                snippet: 'Address: $address\nRating: $rating',
              ),
            ));
          });
        }
      } else {
        print("No gas stations found nearby.");
      }
    } else {
      print('Failed to load nearby gas stations: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
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
                  print("My current location: $value");
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

                  await getNearbyGasStations(value.latitude, value.longitude);
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
