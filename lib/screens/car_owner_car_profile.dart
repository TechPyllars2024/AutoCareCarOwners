import 'package:flutter/material.dart';

class CarOwnerCarProfile extends StatefulWidget {
  const CarOwnerCarProfile({super.key});

  @override
  State<CarOwnerCarProfile> createState() => _CarOwnerCarProfileState();
}

class _CarOwnerCarProfileState extends State<CarOwnerCarProfile> {
  List<String> cars = List.generate(4, (index) => 'CAR ${index + 1}');

  void _editCar(int index) {
    // This is where you'll handle the edit logic for the specific car.
    // For now, let's just show a dialog as an example.
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${cars[index]}'),
          content: Text('You are editing ${cars[index]}.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
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
        title: Text(
          'CAR PROFILES',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1 / 1),
        itemCount: cars.length,
        itemBuilder: (context, index) => Card(
          color: Colors.orange.shade200,
          child: Stack(
            children: [
              Center(
                child: Text(
                  cars[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(150, 40),
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      _editCar(index);
                    },
                    child: Text(
                      'Edit',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
