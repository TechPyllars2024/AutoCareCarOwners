import 'package:autocare_carowners/ProfileManagement/screens/car_owner_profile.dart';
import 'package:autocare_carowners/ProfileManagement/widgets/edit_profile_image.dart';

import 'package:flutter/material.dart';

class CarOwnerEditProfile extends StatefulWidget {
  const CarOwnerEditProfile({super.key});

  @override
  State<CarOwnerEditProfile> createState() => _CarOwnerEditProfileState();
}

class _CarOwnerEditProfileState extends State<CarOwnerEditProfile> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();

  String profileName = 'Paul Vincent Lerado';
  String emailAddress = 'paulvincent.lerado@gmail.com';
  String location = 'Jaro, Iloilo City';

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text(
          'EDIT PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
        actions: [
          IconButton(
              onPressed: () => {},
              icon: Icon(
                Icons.settings,
                size: 30,
              )),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const Stack(
              children: [
                // Profile Image
                EditProfileImage(),
              ],
            ),
            // Text Fields
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          hintText: 'Enter name'
                        ),

                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Email'
                          ),

                        ),
                      ),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Address'
                        ),

                      ),

                    ],
                  ),
                ),


                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), minimumSize: Size(400, 50), backgroundColor: Colors.grey,),
                  onPressed: () {
                    print(nameController.text);
                    print(emailController.text);
                    print(addressController.text);
                    Navigator.push(context,
                        //pushReplacement if you don't want to go back
                        MaterialPageRoute(builder: (context) => CarOwnerProfile()));
                  },
                  child: Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
                ),
                
              ],
            ),
        
          ],
        ),
      ),
    );
  }
}
