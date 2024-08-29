import 'package:flutter/material.dart';

class CarOwnerEditProfile extends StatefulWidget {
  const CarOwnerEditProfile({super.key});

  @override
  State<CarOwnerEditProfile> createState() => _CarOwnerEditProfileState();
}

class _CarOwnerEditProfileState extends State<CarOwnerEditProfile> {

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
          style: TextStyle(),
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
                  'assets/images/profilePhoto.jpg',
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

            ],
          ),

        ],
      ),
    );
  }
}
