// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '/lib/ProfileManagement/services/carDetails.dart';

// void _editCarDetails(int index) {
//     final car = carDetails[index];
//     final brandController = TextEditingController(text: car.brand);
//     final modelController = TextEditingController(text: car.model);
//     final yearController = TextEditingController(text: car.year.toString());
//     final colorController = TextEditingController(text: car.color);
//     final transmissionTypeController = TextEditingController(text: car.transmissionType);
//     final fuelTypeController = TextEditingController(text: car.fuelType);

//     final _formKey = GlobalKey<FormState>();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Edit Car Details'),
//           content: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   TextFormField(
//                     controller: brandController,
//                     decoration: const InputDecoration(labelText: 'Brand'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please fill this section';
//                       }
//                       return null;
//                     },
//                   ),
//                   TextFormField(
//                     controller: modelController,
//                     decoration: const InputDecoration(labelText: 'Model'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please fill this section';
//                       }
//                       return null;
//                     },
//                   ),
//                   TextFormField(
//                     controller: yearController,
//                     decoration: const InputDecoration(labelText: 'Year'),
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(4),
//                     ],
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please fill this section';
//                       }
//                       return null;
//                     },
//                   ),
//                   TextFormField(
//                     controller: colorController,
//                     decoration: const InputDecoration(labelText: 'Color'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please fill this section';
//                       }
//                       return null;
//                     },
//                   ),
//                   TextFormField(
//                     controller: transmissionTypeController,
//                     decoration: const InputDecoration(labelText: 'Transmission Type'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please fill this section';
//                       }
//                       return null;
//                     },
//                   ),
//                   TextFormField(
//                     controller: fuelTypeController,
//                     decoration: const InputDecoration(labelText: 'Fuel Type'),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please fill this section';
//                       }
//                       return null;
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   setState(() {
//                     carDetails[index] = CarDetailsModel(
//                       brand: brandController.text,
//                       model: modelController.text,
//                       year: int.parse(yearController.text),
//                       color: colorController.text,
//                       transmissionType: transmissionTypeController.text,
//                       fuelType: fuelTypeController.text,
//                     );
//                   });
//                   Navigator.of(context).pop();
//                 }
//               },
//               child: const Text('Save'),
//             ),
//           ],
//         );
//       },
//     );
//   }