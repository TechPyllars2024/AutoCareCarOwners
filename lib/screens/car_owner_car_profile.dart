import 'package:flutter/material.dart';

class CarOwnerCarProfile extends StatefulWidget {
  const CarOwnerCarProfile({super.key});

  @override
  State<CarOwnerCarProfile> createState() => _CarOwnerCarProfileState();
}

class _CarOwnerCarProfileState extends State<CarOwnerCarProfile> {

  List<String> cars = List.generate(4, (index) => 'CAR ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CAR PROFILES')),
      body: GridView.builder(

        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(

            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1 / 1),
        itemCount: cars.length,
        itemBuilder: (context, index) => Card(
          color: Colors.orange.shade200,
          child: Center(
            child: Text(cars[index]),
          ),
        ),
      ),

    );
  }
}
