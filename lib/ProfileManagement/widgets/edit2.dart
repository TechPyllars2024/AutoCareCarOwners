// import 'package:autocare_carowners/ProfileManagement/screens/car_owner_profile.dart';
// import 'package:autocare_carowners/ProfileManagement/widgets/edit_profile_image.dart';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';


// class CarOwnerEditProfile extends StatefulWidget {
//   const CarOwnerEditProfile({super.key});

//   @override
//   State<CarOwnerEditProfile> createState() => _CarOwnerEditProfileState();
// }

// class _CarOwnerEditProfileState extends State<CarOwnerEditProfile> {

//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final addressController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold(
//       backgroundColor: Colors.grey.shade300,
//       appBar: AppBar(
//         title: Text(
//           'EDIT PROFILE',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.grey.shade300,
//         actions: [
//           IconButton(
//               onPressed: () => {},
//               icon: Icon(
//                 Icons.settings,
//                 size: 30,
//               )),
//         ],
//       ),

//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const Stack(
//               children: [
//                 // Profile Image
//                 EditProfileImage(),
//               ],
//             ),
//             // Text Fields
//             Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: nameController,
//                         decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                           hintText: 'Edit name'
//                         ),

//                       ),
//                     ],
//                   ),
//                 ),


//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), minimumSize: Size(400, 50), backgroundColor: Colors.grey,),
//                   onPressed: () {
//                     Navigator.push(context,
//                         //pushReplacement if you don't want to go back
//                         MaterialPageRoute(builder: (context) => CarOwnerProfile()));
//                   },
//                   child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
//                 ),         
//               ],
//             ),
        
//           ],
//         ),
//       ),
//     );
//   }
// }
