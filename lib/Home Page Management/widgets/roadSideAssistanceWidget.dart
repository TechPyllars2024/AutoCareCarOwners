import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'dart:ui' as ui;
import '../../Service Directory Management/screens/shop_profile.dart';

class RoadSideAssistanceWidget extends StatefulWidget {
  const RoadSideAssistanceWidget({super.key});

  @override
  State<RoadSideAssistanceWidget> createState() =>
      _RoadSideAssistanceWidgetState();
}

class _RoadSideAssistanceWidgetState extends State<RoadSideAssistanceWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _marker = [];
  final Logger logger = Logger();
  final assetPath = 'assets/images/roadsideAssisstance.png';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeLocationAndFetchShops();
  }

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
      // Fetching the list of markers from the 'markers' collection
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

        // Fetch additional shop details from the 'automotiveShops_profile' collection
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
        final operationTime = shopData['operationTime'];

        // Check if the shop has "Roadside Assistance Services" in its serviceSpecialization
        final serviceSpecialization =
            List<String>.from(shopData['serviceSpecialization']);
        if (!serviceSpecialization.contains("Roadside Assistance Services")) {
          // Skip this shop if it does not provide Roadside Assistance Services
          continue;
        }

        // Create the marker icon
        final customIcon = await resizeAssetBitmapDescriptor(
          assetPath,
          150,
          150,
        );

        // Add marker to the map
        setState(() {
          _marker.add(Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(latitude, longitude),
            icon: customIcon,
            infoWindow: InfoWindow(
              title: shopName,
              snippet: operationTime,
            ),
            onTap: () => _showShopDetails(serviceProviderUid, shopName,
                location, profileImage, operationTime),
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

  void _showShopDetails(String serviceProviderUid, String shopName,
      String location, String profileImage, String operationTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            shopName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // CircularProgressIndicator for loading
                      const CircularProgressIndicator(),
                      // Image widget with loadingBuilder
                      Image.network(
                        profileImage,
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            // Image fully loaded, return the image
                            return child;
                          } else {
                            // While loading, keep showing progress indicator
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
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
                    ],
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
                      WidgetSpan(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.orange.shade900,
                          size: 16,
                        ),
                      ),
                      TextSpan(
                        text: 'Location: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      TextSpan(
                        text: location,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                    children: [
                      WidgetSpan(
                        child: Icon(
                          Icons.schedule,
                          color: Colors.orange.shade900,
                          size: 16,
                        ),
                      ),
                      TextSpan(
                        text: 'Operation Time: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                      TextSpan(
                        text: operationTime,
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
                      serviceProviderUid:
                          serviceProviderUid, // Passing UID to the ShopProfile
                    ),
                  ),
                );
              },
              child: Text(
                'View Shop Profile',
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.grey[700]),
              ),
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
