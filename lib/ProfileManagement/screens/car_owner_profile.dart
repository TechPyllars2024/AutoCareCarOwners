import 'package:autocare_carowners/ProfileManagement/models/car_owner_address_model.dart';
import 'package:autocare_carowners/ProfileManagement/models/car_owner_profile_model.dart';
import 'package:autocare_carowners/ProfileManagement/screens/carDetails.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_addresses.dart';
import 'package:autocare_carowners/ProfileManagement/screens/car_owner_edit_profile.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          'PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold),
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                  padding: const EdgeInsets.only(top: 10.0),
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
        
                Text(
                  userEmail ?? 'No available Email',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
        
                // fetching defualt address
              //  const SizedBox(height: 10),
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
                        padding: const EdgeInsets.only(
                            top: 40.0, left: 20, bottom: 50),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 30, color: Colors.orange,),
                            const SizedBox(width: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${defaultAddress.street}, ${defaultAddress.baranggay}, ',
                                  style: const TextStyle(color: Colors.black54, fontSize: 18),
                                ),
                                const SizedBox(height: 4), // Adds some spacing between lines
                                Text(
                                  '${defaultAddress.city}, ${defaultAddress.province}',
                                  style: const TextStyle(color: Colors.black54, fontSize: 18),
                                ),
                              ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      minimumSize: const Size(400, 50),
                      backgroundColor: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          //pushReplacement if you don't want to go back
                          MaterialPageRoute(
                              builder: (context) => const CarOwnerAddress()));
                    },
                    child: const Text('ADDRESS',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      minimumSize: const Size(400, 50),
                      backgroundColor: Colors.grey,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}