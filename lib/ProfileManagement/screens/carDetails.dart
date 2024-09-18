// import 'dart:convert';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_car_details_model.dart';
import 'package:autocare_carowners/ProfileManagement/services/car_details_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class CarDetails extends StatefulWidget {
  final List<CarDetailsModel> carDetails;

  const CarDetails({Key? key, this.carDetails = const []}) : super(key: key);

  @override
  _CarDetailsState createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  late List<CarDetailsModel> carDetails;
  late CarDetailsService carDetailsService;
  // late CollectionReference carDetailsCollection;

  @override
  void initState() {
    super.initState();
    carDetails = List.from(widget.carDetails);
    carDetailsService = CarDetailsService();
    // _initializeFirestore();
    _fetchCarDetails();
  }

  // void _initializeFirestore() {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     carDetailsCollection = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .collection('carDetails');
  //   }
  // }

  Future<void> _fetchCarDetails() async {
    final fetchedCarDetails = await carDetailsService.fetchCarDetails();
    setState(() {
      carDetails = fetchedCarDetails;
    });
  }
  // Future<void> _fetchCarDetails() async {
  //   final snapshot = await carDetailsCollection.get();
  //   setState(() {
  //     carDetails = snapshot.docs.map((doc) => CarDetailsModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  //   });
  // }

  // Future<void> _addCarDetails(CarDetailsModel car) async {
  //   await carDetailsCollection.add(car.toMap());
  //   _fetchCarDetails();
  // }

  // Future<void> _editCarDetails(int index, CarDetailsModel car) async {
  //   final docId = (await carDetailsCollection.get()).docs[index].id;
  //   await carDetailsCollection.doc(docId).update(car.toMap());
  //   _fetchCarDetails();
  // }

  // Future<void> _deleteCarDetails(int index) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Delete Car Details'),
  //         content: const Text('Are you sure you want to delete this car detail?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               final docId = (await carDetailsCollection.get()).docs[index].id;
  //               await carDetailsCollection.doc(docId).delete();
  //               _fetchCarDetails();
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Delete'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Car Details'),
          content:
              const Text('Are you sure you want to delete this car detail?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showCarDetailsDialog({CarDetailsModel? car, int? index}) {
    final brandController = TextEditingController(text: car?.brand ?? '');
    final modelController = TextEditingController(text: car?.model ?? '');
    final yearController =
        TextEditingController(text: car?.year.toString() ?? '');
    String color = car?.color ?? 'Red';
    String transmissionType = car?.transmissionType ?? 'Automatic';
    String fuelType = car?.fuelType ?? 'Petrol';

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(car == null ? 'Add Car Details' : 'Edit Car Details'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: 'Brand'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the brand';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: modelController,
                    decoration: const InputDecoration(labelText: 'Model'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the model';
                      }
                      return null;
                    },
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
                    ]
                        .map((color) => DropdownMenuItem(
                              value: color,
                              child: Text(color),
                            ))
                        .toList(),
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
                    items: ['Petrol', 'Diesel', 'Gasoline', 'Electric']
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
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
              child: Text(car == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Details'),
      ),
      body: carDetails.isEmpty
          ? const Center(child: Text('No car details. Add a new car.'))
          : ListView.builder(
              itemCount: carDetails.length,
              itemBuilder: (context, index) {
                final car = carDetails[index];
                return Card(
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
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCarDetailsDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
