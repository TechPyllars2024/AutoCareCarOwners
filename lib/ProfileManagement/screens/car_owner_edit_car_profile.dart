import 'package:autocare_carowners/ProfileManagement/services/addresses_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarOwnerCarProfileScreen extends StatefulWidget {
  const CarOwnerCarProfileScreen({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerCarProfileScreen> createState() => _CarOwnerCarProfileScreenState();
}

class _CarOwnerCarProfileScreenState extends State<CarOwnerCarProfileScreen> {
  final carBrandController = TextEditingController();
  final carModelController = TextEditingController();
  final carYearController = TextEditingController();

  List<String> cars = List.generate(4, (index) => 'CAR ${index + 1}');

  void _editCar(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Edit ${cars[index]}'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You are editing ${cars[index]}.'),
                TextField(
                  controller: carBrandController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Brand'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                    CapitalizeEachWordFormatter()
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: carModelController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Model'),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                      CapitalizeEachWordFormatter()
                    ],
                  ),
                ),
                TextField(
                  controller: carYearController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Year'),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text('Save', style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w900, fontSize: 15),),
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
