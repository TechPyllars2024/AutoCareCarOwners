import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'dart:ui' as ui;

import '../../Service Directory Management/screens/shop_profile.dart';

class AutomotiveShopsWidget extends StatefulWidget {
  const AutomotiveShopsWidget({super.key});

  @override
  State<AutomotiveShopsWidget> createState() => _AutomotiveShopsWidgetState();
}

class _AutomotiveShopsWidgetState extends State<AutomotiveShopsWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _marker = [];
  final Logger logger = Logger();
  static const IconData localGasStation =
      IconData(0xf5f3, fontFamily: 'MaterialIcons');
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  Future<void> _initializeLocationAndFetchShops() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    final position = await _getUserCurrentLocation();
    if (position != null) {
      _updateMapWithCurrentLocation(position);
      await _getVerifiedShops();
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

  Future<void> _getVerifiedShops() async {
    final firestore = FirebaseFirestore.instance;
    try {
      // Fetching the list of markers
      final querySnapshot = await firestore.collection('markers').get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'No verified automotive shops found.';
        });
        return;
      }

      // Loop through all the documents in the markers collection
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final latitude = data['latitude'];
        final longitude = data['longitude'];
        final serviceProviderUid = data['serviceProviderUid'];
        final snippet = data['snippet'];

        // Fetch additional shop details from the automotiveShops_profile collection
        final shopSnapshot = await firestore
            .collection('automotiveShops_profile')
            .doc(serviceProviderUid)
            .get();

        if (!shopSnapshot.exists ||
            shopSnapshot.data()?['verificationStatus'] != 'Verified') {
          // Skip unverified shops
          continue;
        }

        // Access the shop details
        final shopData = shopSnapshot.data()!;
        final shopName = shopData['shopName'];
        final location = shopData['location'];
        final profileImage = shopData['profileImage'];

        // Create the marker icon
        final customIcon = await iconDataToBitmapDescriptor(localGasStation,
            color: Colors.orange.shade900, size: 120);

        // Add marker to the map
        setState(() {
          _marker.add(Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(latitude, longitude),
            icon: customIcon,
            infoWindow: InfoWindow(
              title: shopName,
              snippet: snippet,
            ),
            onTap: () => _showShopDetails(
                serviceProviderUid, shopName, location, profileImage),
          ));
        });
      }
    } catch (e) {
      logger.e("Error fetching verified automotive shops: $e");
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load verified automotive shops.';
      });
    }
  }

  Future<BitmapDescriptor> iconDataToBitmapDescriptor(IconData iconData,
      {Color color = Colors.orange, double size = 150}) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Customize the icon with a larger size and color
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

  void _showShopDetails(String serviceProviderUid, String shopName,
      String location, String profileImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            shopName,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Center the image
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.network(
                    profileImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Display the location
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    children: [
                      const TextSpan(
                        text: 'Location: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: location,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Navigate to ShopProfile and pass serviceProviderUid
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShopProfile(
                      serviceProviderUid: serviceProviderUid,
                    ),
                  ),
                );
              },
              child: Text('View Shop Profile', style: TextStyle(color: Colors.orange.shade900),), // Button text for viewing details
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Colors.grey[700]),),
            ),
          ],
        );
      },
    );
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
    _initializeLocationAndFetchShops();
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
            child: CircularProgressIndicator(),
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
              onPressed: _initializeLocationAndFetchShops,
              child: const Icon(
                Icons.center_focus_weak_rounded,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
