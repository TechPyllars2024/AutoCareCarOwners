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

  final CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(7.0736, 125.6110),
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _marker.addAll(_markerList);
    _initializeLocationAndFetchStations();
  }

  Future<void> _initializeLocationAndFetchStations() async {
    final position = await _getUserCurrentLocation();
    if (position != null) {
      _updateMapWithCurrentLocation(position);
      await _getNearbyGasStations(position.latitude, position.longitude);
    }
  }

  Future<Position?> _getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  void _updateMapWithCurrentLocation(Position position) async {
    setState(() {
      _marker.add(
        Marker(
          markerId: const MarkerId("3"),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: "My Location"),
        ),
      );
    });

    final GoogleMapController controller = await _controller.future;
    final cameraPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.0,
    );

    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<void> _getNearbyGasStations(double latitude, double longitude) async {
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
        height: MediaQuery.of(context).size.height * 1,
        child: GoogleMap(
          initialCameraPosition: _cameraPosition,
          markers: Set.of(_marker),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
