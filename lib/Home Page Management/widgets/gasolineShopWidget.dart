import 'dart:async';
import 'dart:convert';
import 'package:autocare_carowners/Home%20Page%20Management/widgets/api_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final String assetPath = 'assets/images/gasoline.png';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeLocationAndFetchStations();
  }

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
        final customIcon = await resizeAssetBitmapDescriptor(
          assetPath,
          150,
          150,
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
          final openingHours = result['opening_hours']?['open_now'] == true
              ? 'Open Now'
              : 'Closed';
          final photos = result['photos']?[0]['photo_reference'];
          final priceLevel = result['price_level'] != null
              ? 'Price Level: ${result['price_level']}'
              : 'Price level not available';
          final businessStatus = result['business_status'] ?? 'Unknown';

          setState(() {
            _marker.add(Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              icon: customIcon,
              infoWindow: InfoWindow(
                title: name,
                snippet: '📍 Address: $address',
              ),
              onTap: () => _showDetails(
                name,
                rating,
                address,
                openingHours,
                photos,
                priceLevel,
                businessStatus,
              ),
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

  void _showDetails(
      String name,
      String rating,
      String address,
      String openingHours,
      String? photos,
      String priceLevel,
      String businessStatus) {
    const apiKey = ApiKey.googleApiKey;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (photos != null)
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.network(
                    'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photos&key=$apiKey',
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        // Image fully loaded, return the image
                        return child;
                      } else {
                        // While loading, show a CircularProgressIndicator
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.orange),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback for failed image loading
                      return const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.star, // Use the desired icon
                            color: Colors.orange.shade900,
                            size: 18, // Adjust the size to match the text
                          ),
                          alignment: PlaceholderAlignment
                              .middle, // Aligns the icon with text
                        ),
                        TextSpan(
                          text: ' Rating: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        TextSpan(
                          text: rating,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.orange.shade900,
                            size: 18,
                          ),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(
                          text: ' Address: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        TextSpan(
                          text: address,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.access_time,
                            color: Colors.orange.shade900,
                            size: 18,
                          ),
                          alignment: PlaceholderAlignment.middle,
                        ),
                        TextSpan(
                          text: ' Status: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        TextSpan(
                          text: openingHours,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(
                            Icons.php_rounded,
                            size: 16,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        TextSpan(
                          text: 'Price Level: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        TextSpan(
                          text: priceLevel,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(
                            businessStatus == 'OPERATIONAL'
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: businessStatus == 'OPERATIONAL'
                                ? Colors.orange.shade900
                                : Colors.red,
                          ),
                        ),
                        TextSpan(
                          text: 'Business Status: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                        TextSpan(
                          text: businessStatus,
                          style: TextStyle(
                            color: businessStatus == 'OPEN'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<BitmapDescriptor> resizeAssetBitmapDescriptor(
      String assetPath, int width, int height) async {
    // Load the image from assets
    ByteData data = await rootBundle.load(assetPath);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    final resizedImage = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    // Convert the resized image to BitmapDescriptor
    return BitmapDescriptor.fromBytes(resizedImage!.buffer.asUint8List());
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
