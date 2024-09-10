import 'dart:convert';

import 'package:autocare_carowners/ProfileManagement/services/car_profile_color.dart';
import 'package:autocare_carowners/ProfileManagement/services/car_profile_fuel_type.dart';
import 'package:autocare_carowners/ProfileManagement/services/car_profile_transmission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarDetailsModel {
  String brand;
  String model;
  int year;
  String color;
  String transmissionType;
  String fuelType;

  CarDetailsModel({
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.transmissionType,
    required this.fuelType,
  });
}

class CarDetails extends StatefulWidget {
  const CarDetails({Key? key}) : super(key: key);

  @override
  _CarDetailsState createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  final List<CarDetailsModel> carDetails = [
    CarDetailsModel(
      brand: 'Toyota',
      model: 'Corolla',
      year: 2020,
      color: 'White',
      transmissionType: 'Automatic',
      fuelType: 'Petrol',
    ),
  ];

  List<dynamic> carData = [];
  String brand = '';
  String model = '';
  List<String> models = [];

   @override
  void initState() {
    super.initState();
    loadCarData();
  }

  Future<void> loadCarData() async {
    final String response = await rootBundle.loadString('lib/ProfileManagement/assets/car_models.json');
    final data = await json.decode(response);
    setState(() {
      carData = data['brands'];
    });
  }

  void _editCarDetails(int index) {
    final car = carDetails[index];
    final brandController = TextEditingController(text: car.brand);
    final modelController = TextEditingController(text: car.model);
    final yearController = TextEditingController(text: car.year.toString());
    final colorController = TextEditingController(text: car.color);
    final transmissionTypeController = TextEditingController(text: car.transmissionType);
    final fuelTypeController = TextEditingController(text: car.fuelType);

    brand = car.brand;
    model = car.model;
    models = carData.firstWhere((b) => b['name'] == brand)['models'].cast<String>();
    String color = car.color;
    String transmissionType = car.transmissionType;
    String fuelType = car.fuelType; 

    
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Car Details'),
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
                        return 'Please fill this section';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: modelController,
                    decoration: const InputDecoration(labelText: 'Model'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill this section';
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
                  ColorDropdown(
                    value: car.color,
                    onChanged: (newValue) {
                      color = newValue!;
                    }
                  ),
                  TransmissionDropdown(
                    value: transmissionType,
                    onChanged: (newValue) {
                      setState(() {
                        transmissionType = newValue!;
                      });
                    },
                  ),
                  FuelTypeDropdown(
                    value: fuelType,
                    onChanged: (newValue) {
                      fuelType = newValue!;
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    carDetails[index] = CarDetailsModel(
                      brand: brandController.text,
                      model: modelController.text,
                      year: int.parse(yearController.text),
                      color: colorController.text,
                      transmissionType: transmissionTypeController.text,
                      fuelType: fuelTypeController.text,
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCarDetails(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Car Details'),
          content: const Text('Are you sure you want to delete these car details?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  carDetails.removeAt(index);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _addCarDetails() {
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final colorController = TextEditingController();
    final transmissionTypeController = TextEditingController();
    final fuelTypeController = TextEditingController();

    String color = 'Red';
    String transmissionType = 'Automatic';
    String fuelType = 'Petrol';

    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Car Details'),
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
                        return 'Please fill this section';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: modelController,
                    decoration: const InputDecoration(labelText: 'Model'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please fill this section';
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
                  ColorDropdown(
                    value: color,
                    onChanged: (newValue) {
                      color = newValue!;
                    }
                  ),
                  TransmissionDropdown(
                    value: transmissionType,
                    onChanged: (newValue) {
                      setState(() {
                        transmissionType = newValue!;
                      });
                    },
                  ),
                  FuelTypeDropdown(
                    value: fuelType,
                    onChanged: (newValue) {
                      fuelType = newValue!;
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    carDetails.add(CarDetailsModel(
                      brand: brandController.text,
                      model: modelController.text,
                      year: int.parse(yearController.text),
                      color: colorController.text,
                      transmissionType: transmissionTypeController.text,
                      fuelType: fuelTypeController.text,
                    ));
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
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
      body: ListView.builder(
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
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Edit') {
                    _editCarDetails(index);
                  } else if (value == 'Delete') {
                    _deleteCarDetails(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCarDetails,
        child: const Icon(Icons.add),
      ),
    );
  }
}