import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class ConvertCoordinates extends StatefulWidget {
  const ConvertCoordinates({super.key});

  @override
  State<ConvertCoordinates> createState() => _ConvertCoordinatesState();
}

class _ConvertCoordinatesState extends State<ConvertCoordinates> {

  String convertedAddress = "";
  String getCoordinatesFromTheAddress = "";
  Future<String> getAddressFromTheCoordinates(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    convertedAddress = "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    return convertedAddress;
  }

  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    getCoordinatesFromTheAddress = locations.toString();
    return locations;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(convertedAddress),
              Text(getCoordinatesFromTheAddress),

              GestureDetector(
                onTap: () async {
                  await getAddressFromTheCoordinates(10.7202, 122.5621);
                  await getCoordinatesFromAddress("Iloilo City");
                  setState(() {});
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text('convert coordinates'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
