import 'dart:convert';
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
  final List<CarDetailsModel> carDetails;

  const CarDetails({Key? key, this.carDetails = const []}) : super(key: key);

  @override
  _CarDetailsState createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  late List<CarDetailsModel> carDetails;

  @override
  void initState() {
    super.initState();
    carDetails = List.from(widget.carDetails);
  }

  void _addCarDetails() {
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
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
                  DropdownButtonFormField<String>(
                    value: color,
                    decoration: const InputDecoration(labelText: 'Color'),
                    items: ['Red', 'Black', 'White', 'Green', 'Silver', 'Yellow', 'Beige', 'Blue', 
                            'Brown', 'Gold', 'Grey', 'Orange', 'Pink', 'Purple', 'Tan']
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
                  ),
                  DropdownButtonFormField<String>(
                    value: transmissionType,
                    decoration: const InputDecoration(labelText: 'Transmission Type'),
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
                    final newCar = CarDetailsModel(
                      brand: brandController.text,
                      model: modelController.text,
                      year: int.parse(yearController.text),
                      color: color,
                      transmissionType: transmissionType,
                      fuelType: fuelType,
                    );
                    carDetails.add(newCar);
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

  void _editCarDetails(int index) {
    final car = carDetails[index];
    final brandController = TextEditingController(text: car.brand);
    final modelController = TextEditingController(text: car.model);
    final yearController = TextEditingController(text: car.year.toString());
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
                  DropdownButtonFormField<String>(
                    value: color,
                    decoration: const InputDecoration(labelText: 'Color'),
                    items: ['Red', 'Black', 'White', 'Green', 'Silver', 'Yellow', 'Beige', 'Blue', 
                            'Brown', 'Gold', 'Grey', 'Orange', 'Pink', 'Purple', 'Tan']
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
                  ),
                  DropdownButtonFormField<String>(
                    value: transmissionType,
                    decoration: const InputDecoration(labelText: 'Transmission Type'),
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
                    car.brand = brandController.text;
                    car.model = modelController.text;
                    car.year = int.parse(yearController.text);
                    car.color = color;
                    car.transmissionType = transmissionType;
                    car.fuelType = fuelType;
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

void main() {
  runApp(MaterialApp(
    home: CarDetails(),
  ));
}