import 'package:autocare_carowners/ProfileManagement/models/car_owner_address_model.dart';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_profile_model.dart';
import 'package:autocare_carowners/ProfileManagement/screens/carDetails2.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_addresses3.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_edit_profile.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_setting.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class CarOwnerProfile extends StatefulWidget {
  const CarOwnerProfile({super.key});

  @override
  State<CarOwnerProfile> createState() => _CarOwnerProfileState();
}

class _CarOwnerProfileState extends State<CarOwnerProfile> {
  CarOwnerProfileModel? profile;
  CarOwnerAddressModel? defaultAddress;
  String? userEmail;


  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchUserEmail();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          profile = CarOwnerProfileModel.fromDocument(data, user.uid);
        });
      } else {
        setState(() {
          profile = CarOwnerProfileModel(
            uid: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            profileImage: '',
          );
        });
      }
    }
  }

  void _fetchUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          'PROFILE', style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade300,
        actions: [
          IconButton(
              onPressed: () async {
              if (profile != null) {
                final updatedProfile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CarOwnerEditProfile(
                      currentUser: profile!,
                    ),
                  ),
                );
                if (updatedProfile != null) {
                  setState(() {
                    profile = updatedProfile;
                  });
                }
              }
            },
              icon: const Icon(
                Icons.edit,
                size: 30,
              )),
            IconButton(
              onPressed: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const CarOwnerSetting())),
              },
              icon: const Icon(
                Icons.settings,
                size: 30,
              )),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Colors.white,
              backgroundImage: profile?.profileImage.isNotEmpty == true
                  ? NetworkImage(profile!.profileImage)
                  : null,
              child: profile?.profileImage.isEmpty == true
                  ? const Icon(Icons.person, size: 150, color: Colors.black)
                  : null,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Center(
                  child: Text(
                    profile?.name ?? 'No available Name',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // need to fix not appearing after editing profile details
              Text(
                userEmail ?? 'No available Email',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),

              // fetching defualt address
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('addresses')
                    .where('isDefault', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text('Error fetching default address.');
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    final defaultAddress = CarOwnerAddressModel.fromMap(snapshot.data!.docs.first.data() as Map<String, dynamic>);
                    return Padding(
                      padding: const EdgeInsets.only(top: 40.0, left: 20, bottom: 50),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 30),
                          const SizedBox(width: 8), 
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${defaultAddress.street}, ', style: const TextStyle(color: Colors.black54, fontSize: 20)),
                              Text('${defaultAddress.city}, ', style: const TextStyle(color: Colors.black54, fontSize: 20)),
                              Text('${defaultAddress.country}, ', style: const TextStyle(color: Colors.black54, fontSize: 20)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.only(top: 40.0, left: 20, bottom: 50),
                    child: Text('No default address set.'),
                  );
                },
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), minimumSize: const Size(400, 50), backgroundColor: Colors.grey,),
                onPressed: () {
                  Navigator.push(context,
                      //pushReplacement if you don't want to go back
                      MaterialPageRoute(builder: (context) => CarOwnerAddress()));
                },
                child: const Text('ADDRESS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), minimumSize: const Size(400, 50), backgroundColor: Colors.grey,),
                onPressed: () {
                  Navigator.push(context,
                    //pushReplacement if you don't want to go back
                    MaterialPageRoute(builder: (context) => const CarDetails())
                  );
                },
                child: const Text('CAR PROFILE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
