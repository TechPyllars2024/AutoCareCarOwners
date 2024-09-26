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
              icon: const Icon(
                Icons.edit,
                size: 30,
              )),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white,
              backgroundImage: profile?.profileImage.isNotEmpty == true
                  ? NetworkImage(profile!.profileImage)
                  : null,
              child: profile?.profileImage.isEmpty == true
                  ? const Icon(Icons.person, size: 80, color: Colors.black)
                  : null,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.phone, // Phone icon
                    size: 25,
                    color: Colors.black54,
                  ),
                  const SizedBox(
                      width: 10), // Adds space between the icon and text
                  Text(
                    profile?.phoneNumber ?? 'No phone number available',
                    style: const TextStyle(
                      fontSize: 25,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.email, // Email icon
                    size: 25,
                    color: Colors.black54,
                  ),
                  const SizedBox(
                      width: 10), // Adds space between the icon and text
                  Text(
                    userEmail ?? 'No available Email',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                ],
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
                      padding:
                          const EdgeInsets.only(top: 25, left: 20, bottom: 50),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 40),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${defaultAddress.houseNumberandStreet}, ${defaultAddress.baranggay}',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 20),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${defaultAddress.city}, ${defaultAddress.province}',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 20),
                              ),
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

              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20), // Adjust the padding value as needed
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(400, 50),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CarOwnerAddress(),
                      ),
                    );
                  },
                  child: const Text(
                    'ADDRESS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(400, 50),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        //pushReplacement if you don't want to go back
                        MaterialPageRoute(
                            builder: (context) => const CarDetails()));
                  },
                  child: const Text('CAR PROFILE',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20)),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    minimumSize: const Size(400, 50),
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
    );
  }
}