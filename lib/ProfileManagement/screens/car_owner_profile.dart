import 'package:autocare_carowners/ProfileManagement/screens/car_owner_car_profile.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_edit_profile.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_setting.dart';

import 'package:flutter/material.dart';


class CarOwnerProfile extends StatefulWidget {
  const CarOwnerProfile({super.key});

  @override
  State<CarOwnerProfile> createState() => _CarOwnerProfileState();
}
// test
class _CarOwnerProfileState extends State<CarOwnerProfile> {
  String profileName = 'Paul Vincent Lerado';
  String emailAddress = 'paulvincent.lerado@gmail.com';
  String location = 'Jaro, Iloilo City';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text(
          'PROFILE', style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
        actions: [
          IconButton(
              onPressed: () => {
              Navigator.push(context,
              //pushReplacement if you don't want to go back
              MaterialPageRoute(builder: (context) => CarOwnerEditProfile())),
              },
              icon: Icon(
                Icons.edit,
                size: 30,
              )),
          IconButton(
              onPressed: () => {
                Navigator.push(context,
                    //pushReplacement if you don't want to go back
                    MaterialPageRoute(builder: (context) => CarOwnerSetting())),
              },
              icon: Icon(
                Icons.settings,
                size: 30,
              )),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(180),
                child: Image.asset(
                  'assets/images/icons/profilePhoto.jpg',
                  width: 360,
                  height: 360,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Center(
                  child: Text(
                    '${profileName}',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Text(
                '${emailAddress}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0, left: 20, bottom: 50 ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 30,),
                    Text('${location}', style: TextStyle(color: Colors.black54, fontSize: 20),)
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), minimumSize: Size(400, 50), backgroundColor: Colors.grey,),
                onPressed: () {
                  Navigator.push(context,
                      //pushReplacement if you don't want to go back
                      MaterialPageRoute(builder: (context) => CarOwnerCarProfile()));
                },
                child: Text('CAR PROFILE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
