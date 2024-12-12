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

  Widget _buildDetailRow(String title, String? value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.orange.shade900, size: 20),
        const SizedBox(width: 8),
        Text(
          '$title:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value ?? 'N/A',
            style: const TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey.shade100,
        child: FutureBuilder<Map<String, dynamic>>(
          future: widget.carDetailsData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'No car details data found',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: widget.navigateToCarDetails,
                      icon:
                          const Icon(Icons.add, size: 18, color: Colors.white),
                      label: const Text(
                        'Add Car Details',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade900,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final carData = snapshot.data!;
            logger.i('Car Data:', carData);
            final carDetails =
                carData.entries.first.value as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 45, left: 16, right: 16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Car Details',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: widget.navigateToCarDetails,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade900,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: const Text(
                              'Edit Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 15),
                      _buildDetailRow(
                          'Brand', carDetails['brand'], Icons.directions_car),
                      const SizedBox(height: 15),
                      _buildDetailRow(
                          'Model', carDetails['model'], Icons.model_training),
                      const SizedBox(height: 15),
                      _buildDetailRow('Year', carDetails['year']?.toString(),
                          Icons.calendar_today),
                      const SizedBox(height: 15),
                      _buildDetailRow('Fuel Type', carDetails['fuelType'],
                          Icons.local_gas_station),
                      const SizedBox(height: 15),
                      _buildDetailRow(
                          'Color', carDetails['color'], Icons.color_lens),
                      const SizedBox(height: 15),
                      _buildDetailRow('Transmission',
                          carDetails['transmissionType'], Icons.settings),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
