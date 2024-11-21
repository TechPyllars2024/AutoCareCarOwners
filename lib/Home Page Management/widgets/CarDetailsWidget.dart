import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CarDetailsWidget extends StatefulWidget {
  final Future<Map<String, dynamic>> carDetailsData;
  final VoidCallback navigateToCarDetails;

  const CarDetailsWidget({
    super.key,
    required this.carDetailsData,
    required this.navigateToCarDetails,
  });

  @override
  State<CarDetailsWidget> createState() => _CarDetailsWidgetState();
}

class _CarDetailsWidgetState extends State<CarDetailsWidget> {
  final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.carDetailsData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'No car details data found',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: widget.navigateToCarDetails,
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Add Car Details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade900,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Extract the first car detail to display
        final carDetailsMap = snapshot.data!;
        final firstCarDetail = carDetailsMap.values.first; // Access the first car detail

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Car Details:',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text('Brand: ${firstCarDetail['brand'] ?? 'N/A'}'),
              Text('Model: ${firstCarDetail['model'] ?? 'N/A'}'),
              Text('Year: ${firstCarDetail['year'] ?? 'N/A'}'),
              Text('Fuel Type: ${firstCarDetail['fuelType'] ?? 'N/A'}'),
              Text('Color: ${firstCarDetail['color'] ?? 'N/A'}'),
              Text('Transmission Type: ${firstCarDetail['transmissionType'] ?? 'N/A'}'),
            ],
          ),
        );
      },
    );
  }
}
