import 'package:autocare_carowners/Authentication/Services/authentication.dart';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_address_model.dart';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_profile_model.dart';
import 'package:autocare_carowners/ProfileManagement/screens/carDetails.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_addresses.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_edit_profile.dart';
import 'package:autocare_carowners/Authentication/screens/login.dart';
import 'package:flutter/material.dart';
import '../../Authentication/Widgets/snackBar.dart';
import '../services/profile_service.dart';

class CarOwnerProfile extends StatefulWidget {
  const CarOwnerProfile({super.key, this.child});

  final Widget? child;

  @override
  State<CarOwnerProfile> createState() => _CarOwnerProfileState();
}

class _CarOwnerProfileState extends State<CarOwnerProfile> {
  CarOwnerProfileModel? profile;
  CarOwnerAddressModel? defaultAddress;
  String? userEmail;
  final CarOwnerProfileService _profileService =
      CarOwnerProfileService(); // Instantiate the service

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchUserEmail();
  }

  Future<void> _fetchUserProfile() async {
    final fetchedProfile = await _profileService.fetchUserProfile();
    setState(() {
      profile = fetchedProfile;
    });
  }

  Future<void> _fetchUserEmail() async {
    final email = await _profileService.fetchUserEmail();
    setState(() {
      userEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30),
        ),
        backgroundColor: Colors.grey.shade100,
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
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade900, // Set the background color to orange
                borderRadius: BorderRadius.circular(12.0), // Rounded edges
              ),
              padding: EdgeInsets.all(6.0), // Optional: Add some padding for better aesthetics
              child: Center( // Center the icon
                child: Icon(
                  Icons.edit,
                  color: Colors.white, // Set the icon color to white
                  size: 30,
                ),
              ),
            ),
          ),

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white,
                backgroundImage: profile?.profileImage.isNotEmpty == true
                    ? NetworkImage(profile!.profileImage)
                    : null,
                child: profile?.profileImage.isEmpty == true
                    ? const Icon(Icons.person, size: 100, color: Colors.black)
                    : null,
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Center(
                    child: Text(
                      '${profile?.firstName} ${profile?.lastName}' ?? '',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                       Icon(
                        Icons.phone, // Phone icon
                        size: 20,
                        color: Colors.orange.shade900,
                      ),
                      const SizedBox(
                          width: 10), // Adds space between the icon and text
                      Text(
                        profile?.phoneNumber ?? 'No phone number available',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 10.0, left: 25) ,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                       Icon(
                        Icons.email_rounded, // Email icon
                        size: 20,
                        color: Colors.orange.shade900,
                      ),
                      const SizedBox(
                          width: 10), // Adds space between the icon and text
                      Text(
                        userEmail ?? 'No available Email',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                // fetching defualt address
                StreamBuilder<CarOwnerAddressModel?>(
                  stream: _profileService.getDefaultAddress(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Text('Error fetching default address.');
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      final defaultAddress = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 10, left: 25, right: 25, bottom: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_sharp,
                              size: 20,
                              color: Colors.orange.shade900,
                            ),
                            const SizedBox(width: 8), // Space between icon and text
                            Flexible(
                              child: Text(
                                '${defaultAddress.houseNumberandStreet}, ${defaultAddress.baranggay}, ${defaultAddress.city}, ${defaultAddress.province}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.visible, // Allows text to wrap
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.only(top: 10.0, left: 20, bottom: 50),
                      child: Text('No default address set.'),
                    );
                  },
                ),



                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.orange.shade900), // Set the border color to orange
                      ),
                      minimumSize: const Size(400, 45),
                      backgroundColor: Colors.transparent, // Make the background transparent
                      elevation: 0, // Remove shadow for better transparency effect
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CarOwnerAddress(),
                        ),
                      );
                    },
                    child:  Text(
                      'ADDRESS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.orange.shade900), // Set the border color to orange
                      ),
                      minimumSize: const Size(400, 45),
                      backgroundColor: Colors.transparent, // Make the background transparent
                      elevation: 0, // Remove shadow for better transparency effect
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          //pushReplacement if you don't want to go back
                          MaterialPageRoute(
                              builder: (context) => const CarDetails()));
                    },
                    child:  Text('CAR PROFILE',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                            fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      minimumSize: const Size(400, 45),
                      backgroundColor: Colors.deepOrange.shade700,
                    ),
                    onPressed: () async {
                      try {
                        await AuthenticationMethod().signOut();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      } catch (e) {
                        Utils.showSnackBar('Error Signing Out: $e');
                      }
                    },
                    child: const Text('LOG OUT',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}