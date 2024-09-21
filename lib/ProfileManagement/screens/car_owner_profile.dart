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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(

        title: const Text(
          'PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey.shade100,
        actions: [
          Transform.translate(
            offset: const Offset(-12, 0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade900, // Inner color
                border: Border.all(color: Colors.orange.shade900, width: 2), // Border color and width
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: IconButton(
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
                  color: Colors.white, // Icon color
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
                      style:  TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible, // Ensures text wraps to the next line
                      softWrap: true,
                    ),
                  ),
                ),
        
                Text(
                  userEmail ?? 'No available Email',
                  style:  TextStyle(
                    fontSize: 18,
                    color: Colors.black45,
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
                      final fetchedAddress = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.only(top: 40.0, left: 20, bottom: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                             Icon(Icons.location_on, size: 30, color: Colors.orange.shade900),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Flexible(
                                child: Text(
                                  '${fetchedAddress.street}, ${fetchedAddress.baranggay}, ${fetchedAddress.city}, ${fetchedAddress.province}',
                                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                                  overflow: TextOverflow.visible, // Ensures text wraps to the next line
                                  softWrap: true, // Allows text to wrap
                                ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.pressed)) {
                            return Colors.orange.shade900; // Change to orange when pressed
                          }
                          return Colors.grey.shade100; // Default background color
                        },
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.orange.shade900, width: 2), // Orange border
                        ),
                      ),
                      minimumSize: WidgetStateProperty.all<Size>(Size(400, 50)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CarOwnerAddress()),
                      );
                    },
                    child: Text(
                      'ADDRESS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900, // Orange text when not pressed
                        fontSize: 20,
                      ),
                    ),
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
                      backgroundColor: Colors.deepOrange.shade700,
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