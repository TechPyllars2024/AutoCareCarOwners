import 'package:autocare_carowners/ProfileManagement/models/car_owner_car_details_model.dart';
import 'package:autocare_carowners/ProfileManagement/services/car_details_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class CarDetails extends StatefulWidget {
  final List<CarDetailsModel> carDetails;

  const CarDetails({super.key, this.carDetails = const []});

  @override
  State<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  late List<CarDetailsModel> carDetails;
  late CarDetailsService carDetailsService;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    carDetails = List.from(widget.carDetails);
    carDetailsService = CarDetailsService();
    _fetchCarDetails();
  }

  Future<void> setDefaultCar(int index, List<CarDetailsModel> cars) async {
    try {
      // Update the local state immediately
      for (int i = 0; i < cars.length; i++) {
        cars[i].isDefault = i == index; // Mark the car at 'index' as default
      }

      // Perform Firestore update in the background
      final snapshot = await carDetailsService.carDetailsCollection.get();
      for (int i = 0; i < snapshot.docs.length; i++) {
        final docId = snapshot.docs[i].id;
        await carDetailsService.carDetailsCollection.doc(docId).update({
          'isDefault': i == index, // Update the 'isDefault' field
        });
      }
    } catch (e) {
      logger.i('Error setting default car: $e');
      throw Exception('Unable to set default car. Please try again.');
    }
  }

  Future<void> _fetchCarDetails() async {
    final fetchedCarDetails = await carDetailsService.fetchCarDetails();
    setState(() {
      carDetails = fetchedCarDetails;
    });
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Delete Car Details'),
          content:
              const Text('Are you sure you want to delete this car detail?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final docId =
                    (await carDetailsService.carDetailsCollection.get())
                        .docs[index]
                        .id;
                await carDetailsService.deleteCarDetails(docId);
                _fetchCarDetails();
              },
              child: Text(
                'Delete',
                style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }
  //Helper function to get color from color name
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'green':
        return Colors.green;
      case 'silver':
        return Colors.grey.shade300;
      case 'yellow':
        return Colors.yellow;
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'blue':
        return Colors.blue;
      case 'brown':
        return Colors.brown;
      case 'gold':
        return const Color(0xFFFFD700);
      case 'grey':
        return Colors.grey;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'purple':
        return Colors.purple;
      case 'tan':
        return const Color(0xFFD2B48C);
      default:
        return Colors.grey; // Default color if no match is found
    }
  }

  void _showCarDetailsDialog({CarDetailsModel? car, int? index}) {
    final brandController = TextEditingController(text: car?.brand ?? '');
    final modelController = TextEditingController(text: car?.model ?? '');
    final yearController =
        TextEditingController(text: car?.year.toString() ?? '');
    String color = car?.color ?? 'Red';
    String transmissionType = car?.transmissionType ?? 'Automatic';
    String fuelType = car?.fuelType ?? 'Gasoline';

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(car == null ? 'Add Car Details' : 'Edit Car Details'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: brandController,
                      decoration: const InputDecoration(labelText: 'Brand'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the brand';
                        } else if (value.length < 2 || value.length > 20) {
                          return 'Not a valid brand';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                        CapitalizeEachWordFormatter()
                      ],
                    ),
                    TextFormField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Model'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the model';
                        } else if (value.length < 2 || value.length > 20) {
                          return 'Not a valid model';
                        }
                        return null;
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                        CapitalizeEachWordFormatter()
                      ],
                    ),
                    TextFormField(
                      controller: yearController,
                      decoration: const InputDecoration(labelText: 'Year'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please fill this section';
                        } else {
                          final year = int.tryParse(value);
                          if (year == null || year < 2000) {
                            return 'Year must be in 20XX';
                          } else if (year > 2025) {
                            return 'No cars beyond this year are available';
                          }
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: color,
                      decoration: const InputDecoration(labelText: 'Color'),
                      items: [
                        'Red',
                        'Black',
                        'White',
                        'Green',
                        'Silver',
                        'Yellow',
                        'Beige',
                        'Blue',
                        'Brown',
                        'Gold',
                        'Grey',
                        'Orange',
                        'Pink',
                        'Purple',
                        'Tan'
                      ].map((colorName) {
                        return DropdownMenuItem(
                          value: colorName,
                          child: Row(
                            children: [
                              Container(
                                width: 24, // Size of the color swatch
                                height: 24,
                                margin: const EdgeInsets.only(
                                    right: 8), // Space between swatch and text
                                decoration: BoxDecoration(
                                  shape: BoxShape
                                      .circle, // Change to BoxShape.rectangle for square
                                  color: _getColorFromName(
                                      colorName), // Get color from helper function
                                ),
                              ),
                              Text(
                                  colorName), // Display color name beside the swatch
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          color = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a color';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: transmissionType,
                      decoration:
                          const InputDecoration(labelText: 'Transmission Type'),
                      items: ['Automatic', 'Manual']
                          .map((transmission) => DropdownMenuItem(
                                value: transmission,
                                child: Text(transmission),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          transmissionType = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a transmission type';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: fuelType,
                      decoration: const InputDecoration(labelText: 'Fuel Type'),
                      items: ['Diesel', 'Gasoline']
                          .map((fuel) => DropdownMenuItem(
                                value: fuel,
                                child: Text(fuel),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          fuelType = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a fuel type';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newCarDetails = CarDetailsModel(
                    brand: brandController.text,
                    model: modelController.text,
                    year: int.parse(yearController.text),
                    color: color,
                    transmissionType: transmissionType,
                    fuelType: fuelType,
                  );

                  if (car == null) {
                    await carDetailsService.addCarDetails(newCarDetails);
                  } else {
                    final docId =
                        (await carDetailsService.carDetailsCollection.get())
                            .docs[index!]
                            .id;
                    await carDetailsService.editCarDetails(
                        docId, newCarDetails);
                  }
                  _fetchCarDetails();
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                car == null ? 'Add' : 'Update',
                style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w900,
                    fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        title: const Text(
          'Car Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: carDetails.isEmpty
          ? const Center(child: Text('No car details. Add a new car.'))
          : ListView.builder(
              itemCount: carDetails.length,
              itemBuilder: (context, index) {
                final car = carDetails[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.orange.shade900,
                        width: 2, // Optional: Set the border width
                      ),
                      borderRadius: BorderRadius.circular(
                          8), // Optional: Add rounded corners
                    ),
                    elevation: 8,
                    child: ListTile(
                      title: Text('${car.brand} ${car.model}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Year: ${car.year}'),
                          Text('Color: ${car.color}'),
                          Text('Transmission: ${car.transmissionType}'),
                          Text('Fuel: ${car.fuelType}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showCarDetailsDialog(car: car, index: index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteConfirmationDialog(index);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              car.isDefault ? Icons.star : Icons.star_border,
                              color: car.isDefault
                                  ? Colors.orange.shade900
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              setState(() {
                                for (int i = 0; i < carDetails.length; i++) {
                                  carDetails[i].isDefault = i == index;
                                }
                              });
                              await carDetailsService.setDefaultCar(
                                  index, carDetails); // Set this car as default
                              _fetchCarDetails(); // Re-fetch car details to update UI
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange.shade900,
        onPressed: () {
          _showCarDetailsDialog();
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
          weight: 20,
        ),
      ),
    );
  }
}
