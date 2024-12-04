import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:ui' as ui;

class GasolineShopsWidget extends StatefulWidget {
  const GasolineShopsWidget({super.key});

  @override
  State<GasolineShopsWidget> createState() => _GasolineShopsWidgetState();
}

class _GasolineShopsWidgetState extends State<GasolineShopsWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _marker = [];
  final Logger logger = Logger();
  static const IconData localGasStation =
      IconData(0xe394, fontFamily: 'MaterialIcons');
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  final Set<Polyline> _polyline = {};

  Future<void> _initializeLocationAndFetchStations() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    final position = await _getUserCurrentLocation();
    if (position != null) {
      _updateMapWithCurrentLocation(position);
      await _getNearbyGasStations(position.latitude, position.longitude);
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Unable to fetch your location.';
      });
    }
    setState(() {
      _isLoading = false;
    });
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

  Future<BitmapDescriptor> iconDataToBitmapDescriptor(
    IconData iconData, {
    Color color = Colors.blue,
    double size = 48,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw the icon
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontFamily: iconData.fontFamily,
        fontSize: size,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0.0, 0.0));

    // Convert to image and get bytes
    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> _getNearbyGasStations(double latitude, double longitude) async {
    const apiKey = 'AIzaSyCrbgW2yWOxrm932ZOoVV1_vw1ImfRLMDM';
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=5000&type=gas_station&key=$apiKey');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      logger.i("Nearby gas stations response: $data");

      final results = data['results'];
      if (results != null && results.isNotEmpty) {
        final customIcon = await iconDataToBitmapDescriptor(
          localGasStation,
          color: Colors.orange.shade900,
          size: 96,
        );

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
              icon: customIcon,
              infoWindow: InfoWindow(
                title: name,
                snippet: '📍 Address: $address\n⭐ Rating: $rating',
              ),
              onTap: () => _showNavigationDialog(lat, lng, name),
            ));
          });
        }
      } else {
        logger.i("No gas stations found nearby.");
      }
    } else {
      logger.i('Failed to load nearby gas stations: ${response.statusCode}');
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load nearby gas stations.';
      });
    }
  }

  void _showNavigationDialog(
      double destinationLat, double destinationLng, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Navigate to $name?", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        content: const Text(
            "Do you want to start navigation to this gasoline shop?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _fetchDirectionsAndNavigate(destinationLat, destinationLng);
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;

      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  Future<void> _fetchDirectionsAndNavigate(
      double destinationLat, double destinationLng) async {
    const apiKey = 'AIzaSyCrbgW2yWOxrm932ZOoVV1_vw1ImfRLMDM';

    try {
      // Step 1: Get user's current location
      final currentPosition = await _getUserCurrentLocation();
      if (currentPosition == null) {
        logger.e("Failed to fetch user's current location.");
        return;
      }

      // Step 2: Build API URL
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentPosition.latitude},${currentPosition.longitude}&destination=$destinationLat,$destinationLng&key=$apiKey',
      );

      // Step 3: Fetch directions from API
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Step 4: Parse API response
        final data = json.decode(response.body);

        final routes = data['routes'];
        if (routes != null && routes.isNotEmpty) {
          final polyline = routes[0]['overview_polyline']['points'];
          if (polyline == null || polyline.isEmpty) {
            logger.e("No polyline data found in the API response.");
            return;
          }

          final points = _decodePolyline(polyline);

          // Step 5: Update UI
          setState(() {
            _marker.add(Marker(
              markerId: const MarkerId("destination"),
              position: LatLng(destinationLat, destinationLng),
              infoWindow: const InfoWindow(title: "Destination"),
            ));

            _polyline.add(
              Polyline(
                polylineId: const PolylineId("route"),
                points: points,
                color: Colors.blue,
                width: 5,
              ),
            );
          });

          // Step 6: Start turn-by-turn navigation
          _startTurnByTurnNavigation(points);
        } else {
          logger.e("No routes found in the directions API response.");
        }
      } else {
        logger.e("HTTP error: ${response.statusCode}. Message: ${response.body}");
      }
    } catch (e, stackTrace) {
      logger.e("An error occurred: $e", stackTrace);
    }
  }

  void _startTurnByTurnNavigation(List<LatLng> points) async {
    try {
      final GoogleMapController controller = await _controller.future;

      for (final point in points) {
        await Future.delayed(const Duration(seconds: 2));
        controller.animateCamera(CameraUpdate.newLatLng(point));
      }
      logger.i("Navigation complete.");
    } catch (e, stackTrace) {
      logger.e("Error during navigation: $e", stackTrace);
    }
  }

  Future<Position?> _getUserCurrentLocation() async {
    try {
      await Geolocator.requestPermission();
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      logger.i("Error getting location: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeLocationAndFetchStations();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(0.0, 0.0),
            zoom: 14.0,
          ),
          markers: Set.of(_marker),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
        if (_hasError)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.red.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          bottom: 100,
          right: 8,
          child: SizedBox(
            width: 40,
            height: 40,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _initializeLocationAndFetchStations,
              child: const Icon(
                Icons.center_focus_weak_rounded,
                size: 20,
                color: Colors.grey,
              ), // Adjust icon size
            ),
          ),
        ),
      ],
    );
  }
}
