import 'package:autocare_carowners/screens/car_owner_profile.dart';
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
            Stack(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(320),
                      child: Icon(
                        Icons.person,
                        size: 260,
                        color: Colors.black12,
        
                      ),
        
                    ),
        
                  ),
                ),
                Positioned(
                  right: 100,
                  top: 190,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      //borderRadius: BorderRadius.circular(5),
                      child: IconButton(
                          onPressed: () => {

                          },
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                          )),
        
                    ),
        
                  ),
                )
              ],
            ),
            Column(
              children: [

        
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          hintText: 'Enter name'
                        ),

                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Email'
                          ),

                        ),
                      ),
                      TextField(
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
