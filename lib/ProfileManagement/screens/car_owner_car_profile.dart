import 'package:flutter/material.dart';

class CarOwnerCarProfile extends StatefulWidget {
  const CarOwnerCarProfile({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerCarProfile> createState() => _CarOwnerCarProfileState();
}

class _CarOwnerCarProfileState extends State<CarOwnerCarProfile> {
  final carBrandController = TextEditingController();
  final carModelController = TextEditingController();
  final carYearController = TextEditingController();

  List<String> cars = List.generate(4, (index) => 'CAR ${index + 1}');

  void _editCar(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit ${cars[index]}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You are editing ${cars[index]}.'),
                TextField(
                  controller: carBrandController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Brand'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: carModelController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Model'),
                  ),
                ),
                TextField(
                  controller: carYearController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Year'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
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
          'CAR PROFILES',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
        child: GridView.builder(

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1 / 1),
          itemCount: cars.length,
          itemBuilder: (context, index) => Card(
            elevation: 8,
            color: Colors.orange.shade200,
            child: Stack(
              children: [
                Center(
                  child: Text(
                    cars[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
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
                        minimumSize: const Size(150, 40),
                        backgroundColor: Colors.orange.shade900,
                      ),
                      onPressed: () {
                        _editCar(index);
                      },
                      child: const Text(
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
      ),
    );
  }
}
